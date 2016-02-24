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
*/
func GetFFT(waveForm:[Double]) -> [Complex]
{
    let arrayN = waveForm.count
    
    let logN:vDSP_Length = vDSP_Length(ceil(log2(Double(arrayN))))
    
    let N = Int(1 << logN)
    
    let fftSetup = vDSP_create_fftsetupD(logN, FFTRadix(kFFTRadix2))
    
    let fftResult = DSPDoubleSplitComplex(realp: UnsafeMutablePointer<Double>([Double](count: N, repeatedValue: 0.0)), imagp: UnsafeMutablePointer<Double>([Double](count: N, repeatedValue: 0.0)))
    
    for i in 0..<arrayN
    {
        fftResult.realp[i] = waveForm[i]
    }
    
    let tstPtr = UnsafePointer<DSPDoubleSplitComplex>(bitPattern: &fftResult)
    
    vDSP_fft_zripD(fftSetup, UnsafePointer<DSPDoubleSplitComplex>(&fftResult), 1, logN, kFFTDirection_Forward)
    
}