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
func GetFFT(_ waveForm:[Double]) -> [Complex]
{
    // Get the number of points in the signal
    let arrayN = waveForm.count
    
    
    return [Complex(real: 0,imag: 0)]
}
