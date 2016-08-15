//
//  PCH_BlueBookFunctions.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

/// This is basically an interface file which defines the functions we need to use Rabin's method for inductance calculations

import Foundation

func IntegralOf_tL1_from0_to(_ b:Double) -> Double
{
    return (-b * M0(b)) - (b * b / π) + IntegralOf_M0_from0_to(b) + IntegralOf_tI1_from0_to(b)
}

func IntegralOf_tL1_from(_ a:Double, toB:Double) -> Double
{
    return IntegralOf_tL1_from0_to(toB) - IntegralOf_tL1_from0_to(a)
}

func IntegralOf_tI1_from0_to(_ b:Double) -> Double
{
    // Alternate method from BlueBook 2nd Ed., page 267
    let Ri0 = gsl_sf_bessel_I0_scaled(b)
    let Ri1 = gsl_sf_bessel_I1_scaled(b)
    let eBase = exp(b)
    
    return (π / 2.0) * b * eBase * (M1(b) * Ri0 - M0(b) * Ri1)
}

func IntegralOf_tI1_from(_ a:Double, toB:Double) -> Double
{
    return IntegralOf_tI1_from0_to(toB) - IntegralOf_tI1_from0_to(a)
}

func IntegralOf_tK1_from0_to(_ b:Double) -> Double
{
    // Alternate method from BlueBook 2nd Ed., page 267
    let Rk0 = gsl_sf_bessel_K0_scaled(b)
    let Rk1 = gsl_sf_bessel_K1_scaled(b)
    let eBase = exp(-b)
    
    return (π / 2.0) * (1.0 - b * eBase * (M1(b) * Rk0 + M0(b) * Rk1))
}

func IntegralOf_tK1_from(_ a:Double, toB:Double) -> Double
{
    return IntegralOf_tK1_from0_to(toB) - IntegralOf_tK1_from0_to(a)
}

/* Unused functions
func L0(x:Double) -> Double
{
    return gsl_sf_bessel_I0(x) - M0(x)
}

func L1(x:Double) -> Double
{
    return gsl_sf_bessel_I1(x) - M1(x)
}
*/

func M0X_integrand(_ theta:Double, params:UnsafeMutablePointer<Void>?) -> Double!
{
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params!)
    let x:Double = dpParams.pointee
    
    return exp(-x * cos(theta))
}

func M0(_ x:Double) -> Double
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
    
    return result * 2.0 / π
}

func M1X_integrand(_ theta:Double, params:UnsafeMutablePointer<Void>) -> Double
    {
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params)
    let x:Double = dpParams.pointee
    
    return exp(-x * cos(theta)) * cos(theta)
}


func M1(_ x:Double) -> Double
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
    
    return (1.0 - result) * 2.0 / π
}

func IntM0T_integrand(_ theta:Double, params:UnsafeMutablePointer<Void>) -> Double
{
    // first we have to convert the params pointer to a Double
    let dpParams = UnsafeMutablePointer<Double>(params)
    let x:Double = dpParams.pointee

    return (1.0 - exp(-x * cos(theta))) / cos(theta)
}

func IntegralOf_M0_from0_to(_ b:Double) -> Double
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
    
    return result * 2.0 / π
}
