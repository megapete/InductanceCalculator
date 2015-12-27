//
//  PCH_BlueBookFunctions.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

/// This is basically an interface file which defines the functions we need to use Rabin's method for inductance calculations

import Foundation

func IntegralOf_tL1_from0_to(b:Double) -> Double
{
    return (-b * M0(b)) - (b * b / π) + IntegralOf_M0_from0_to(b) + IntegralOf_tI1_from0_to(b)
}

func IntegralOf_tL1_from(a:Double, toB:Double) -> Double
{
    return IntegralOf_tL1_from0_to(toB) - IntegralOf_tL1_from0_to(a)
}

func IntegralOf_tI1_from0_to(b:Double) -> Double
{
    let I0 = gsl_sf_bessel_I0(b)
    let I1 = gsl_sf_bessel_I1(b)
    
    return (π / 2.0) * b * (M1(b) * I0 - M0(b) * I1)
}

func IntegralOf_tI1_from(a:Double, toB:Double) -> Double
{
    return IntegralOf_tI1_from0_to(toB) - IntegralOf_tI1_from0_to(a)
}

func IntegralOf_tK1_from0_to(b:Double) -> Double
{
    return (π / 2.0) * (1.0 - b * (M1(b) * gsl_sf_bessel_K0(b) + M0(b) * gsl_sf_bessel_K1(b)))
}

func IntegralOf_tK1_from(a:Double, toB:Double) -> Double
{
    return IntegralOf_tK1_from0_to(toB) - IntegralOf_tK1_from0_to(a)
}

func L0(x:Double) -> Double
{
    return gsl_sf_bessel_I0(x) - M0(x)
}

func L1(x:Double) -> Double
{
    return gsl_sf_bessel_I1(x) - M1(x)
}


func M0X_integrand(theta:Double, params:UnsafeMutablePointer<Void>) -> Double
{
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params)
    let x:Double = dpParams.memory
    
    return exp(-x * cos(theta))
}

func M0(x:Double) -> Double
{
    var iError:Double = 0.0
    var iNumEvals:Int = 0
    var result:Double = 0.0
    
    var params = x
    
    var integrand:gsl_function = gsl_function(function: M0X_integrand, params: &params)
    
    let fRes = gsl_integration_qng(&integrand, 0.0, π / 2.0, 0.0, 1.0E-8, &result, &iError, &iNumEvals)
    
    if (fRes > 0)
    {
        ALog("Error calling integration routine")
        return 0.0
    }
    
    return result / (π / 2.0)
}

func M1X_integrand(theta:Double, params:UnsafeMutablePointer<Void>) -> Double
    {
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params)
    let x:Double = dpParams.memory
    
    return exp(-x * cos(theta)) * cos(theta)
}


func M1(x:Double) -> Double
{
    var iError:Double = 0.0
    var iNumEvals:Int = 0
    var result:Double = 0.0
    
    var params = x
    
    var integrand:gsl_function = gsl_function(function: M1X_integrand, params: &params)
    
    let fRes = gsl_integration_qng(&integrand, 0.0, π / 2.0, 0.0, 1.0E-8, &result, &iError, &iNumEvals)
    
    if (fRes > 0)
    {
        ALog("Error calling integration routine")
        return 0.0
    }
    
    return (1.0 - result) / (π / 2.0)
}

func IntM0T_integrand(theta:Double, params:UnsafeMutablePointer<Void>) -> Double
{
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params)
    let x:Double = dpParams.memory

    return (1.0 - exp(-x * cos(theta))) / cos(theta)
}

func IntegralOf_M0_from0_to(b:Double) -> Double
{
    var iError:Double = 0.0
    var iNumEvals:Int = 0
    var result:Double = 0.0
    
    var params = b
    
    var integrand:gsl_function = gsl_function(function: IntM0T_integrand, params: &params)
    
    let fRes = gsl_integration_qng(&integrand, 0.0, π / 2.0, 0.0, 1.0E-8, &result, &iError, &iNumEvals)
    
    if (fRes > 0)
    {
        ALog("Error calling integration routine")
        return 0.0
    }
    
    return result / (π / 2.0)
}