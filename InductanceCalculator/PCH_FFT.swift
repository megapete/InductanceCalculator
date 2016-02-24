//
//  PCH_FFT.swift
//  InductanceCalculator
//
//  Created by Peter Huber on 2016-02-23.
//  Copyright © 2016 Peter Huber. All rights reserved.
//
// Swift wrappers around Apple's somewhat horribly-documented FFT functions

import Foundation
import Accelerate

/**
    This function takes an array of doubles that represent the waveform we want to change from the time domain to the frequency domain. It returns the transform as an array of Complex numbers.
 
    - parameter waveForm: The digitized signal, in the form of an array of amplitudes. Note that it is probably better if waveForm is an integer power of 2.
*/
func GetFFT(waveForm:[Double]) -> [Complex]
{
    // Get the number of points in the signal
    let arrayN = waveForm.count
    
    // We need to pass the base-2 logarithm of the number of points, so calculate it here (this is the reason it's better to have the point count be a multiple of 2)
    let logN:vDSP_Length = vDSP_Length(ceil(log2(Double(arrayN))))
    
    // Get the actual number of points we'll be passing to the DSP routines
    let N = Int(1 << logN)
    
    // Copy waveForm into a DSPDoubleComplex array
    var waveDC = [DSPDoubleComplex](count: N, repeatedValue: DSPDoubleComplex(real: 0.0, imag: 0.0))
    
    for i in 0..<arrayN
    {
        waveDC[i].real = waveForm[i]
    }
    
    // Create the opaque setup structure we'll be using
    let fftSetup = vDSP_create_fftsetupD(logN, FFTRadix(kFFTRadix2))
    
    // The result type for the FFT call is a structre called a "DSPDoubleSplitComplex", which is made up of two arrays, one for the real parts and one for the complex parts. We initialize both arrays to zero
    var fftResult = DSPDoubleSplitComplex(realp: UnsafeMutablePointer<Double>([Double](count: N, repeatedValue: 0.0)), imagp: UnsafeMutablePointer<Double>([Double](count: N, repeatedValue: 0.0)))
    
    var tstResult = withUnsafePointer(&fftResult) {(pointer:UnsafePointer<DSPDoubleSplitComplex>) -> ([Complex]) in
        
            vDSP_ctozD(waveDC, 2, pointer, 1, vDSP_Length(N))
        
        }
    // Set the real values of the struct
    vDSP_ctozD(waveDC, 2, [fftResult], 1, vDSP_Length(N))
    
    // This is some of the worst Swift-wrapping of C calls I've found so far (evidently, Accelerate is late to the Swift party). You can't actually cast or create an UnsafePointer<DSPDoubleSplitComplex> in any coherent way, so I'm trying to pass an array with one value in it (the DSPDoubleSplitComplex). I got this idea from Apple's documentation ("Using Swift with Cocoa and Objective-C") on UnsafePointer (Swift 2.1).
    vDSP_fft_zripD(fftSetup, [fftResult], 1, logN, FFTDirection(kFFTDirection_Forward))
    
    vDSP_ztocD([fftResult], 1, &waveDC, 2, vDSP_Length(N))
    
    // At this point, fftResult holds the signal after transformation. Convert it to a Complex and return that
    
    var result = [Complex](count: N, repeatedValue: Complex(real:0.0, imag:0.0))
    
    for i in 0..<N
    {
        result[i].real = waveDC[i].real
        result[i].imag = waveDC[i].imag
    }

    return result
}