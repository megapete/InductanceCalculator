//
//  PCH_DiskSection.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

/// The == function must be defined for Hashable types
internal func ==(lhs:PCH_DiskSection, rhs:PCH_DiskSection) -> Bool
{
    return (lhs.data.serialNumber == rhs.data.serialNumber)
}

class PCH_DiskSection:Hashable {
    
    internal var hashValue: Int {
        return self.data.serialNumber
    }

    /// The number of turns in the section
    let N:Double
    
    /// The current density on the section
    let J:Double
    
    /// The window height of the core that holds the section
    let windHt:Double
    
    /// The core radius
    let coreRadius:Double
    
    /// The rectangle that the disk occupies
    let diskRect:NSRect
    
    /// A factor for "fudging" some calculations. The BlueBook says that a factor of three gives better results, but so far, my tests show that a factor closer to 1 is better (closer to Andersen) so that's what I'm using (for now).
    let windHtFactor = 3.0
    
    /// The electrical data associated with the section
    var data:PCH_SectionData
    
    /**
        Designated initializer
        
        - parameter N: The nuber of turns in the section
        - parameter J: The current density on teh section
        - parameter windHt: The window height of the core
        - parameter coreRadius: The core radius

    */
    init(diskRect:NSRect, N:Double, J:Double, windHt:Double, coreRadius:Double, secData:PCH_SectionData)
    {
        self.diskRect = diskRect
        self.N = N
        self.J = J
        self.windHt = windHt
        self.coreRadius = coreRadius
        self.data = secData
    }
    
    /// BlueBook function J0
    func J0() -> Double
    {
        let useWindht = self.windHtFactor * self.windHt
        
        return self.J * Double(self.diskRect.size.height) / useWindht
    }
    
    /// BlueBook function Jn
    func J(n:Int) -> Double
    {
        let useWindht = self.windHtFactor * self.windHt
        // let useOriginY = (useWindht - self.windHt) / 2.0 + Double(self.diskRect.origin.y)
        let useOriginY = Double(self.diskRect.origin.y)
        
        return (2.0 * self.J / (Double(n) * π)) * (sin(Double(n) * π * (useOriginY + Double(self.diskRect.size.height)) / useWindht) - sin(Double(n) * π * useOriginY / useWindht));
    }
    
    /// BlueBook function Cn
    func C(n:Int) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return IntegralOf_tK1_from(x1, toB: x2)
    }
    
    /// BlueBook function Dn
    func D(n:Int) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let xc = (Double(n) * π / useWindht) * self.coreRadius
        
        // Alternate method from BlueBook 2nd Ed., page 267
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        let eBase = exp(2.0 * xc)
        
        return eBase * (Ri0 / Rk0) * self.C(n)
        
        /* old way
        
        let I0 = gsl_sf_bessel_I0(xc)
        let K0 = gsl_sf_bessel_K0(xc)
        
        return I0 / K0 * self.C(n)
        */
    }
    
    /// BlueBook function En
    func E(n:Int) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let x2 = (Double(n) * π / useWindht) * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return IntegralOf_tK1_from0_to(x2)
    }
    
    /// BlueBook function Fn
    func F(n:Int) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = m * self.coreRadius
        
        // Alternate method from BlueBook 2nd Ed., page 267
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        let eBase = exp(2.0 * xc)
        
        return eBase * (Ri0 / Rk0) * IntegralOf_tK1_from(x1, toB: x2) - IntegralOf_tI1_from0_to(x1)
    }
    
    /// BlueBook function Gn
    func G(n:Int) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = m * self.coreRadius
        
        // Alternate method from BlueBook 2nd Ed., page 267
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        let eBase = exp(2.0 * xc)
        
        return eBase * (Ri0 / Rk0) * IntegralOf_tK1_from(x1, toB: x2) + IntegralOf_tI1_from(x1, toB: x2)
    }
    
    /// Rabins' method for calculating self-inductance
    func SelfInductance() -> Double
    {
        let I1 = self.J * Double(self.diskRect.size.width * self.diskRect.size.height) / self.N
        
        let N1 = self.N
        
        let r1 = Double(self.diskRect.origin.x)
        let r2 = r1 + Double(self.diskRect.size.width)
        
        var result = (π * µ0 * N1 * N1 / (6.0 * windHtFactor * self.windHt)) * (gsl_pow_2(r2 + r1) + 2.0 * gsl_pow_2(r1))
        
        
        let multiplier = π * µ0 * windHtFactor * self.windHt * N1 * N1 / gsl_pow_2(N1 * I1)
        
        let convergenceIterations = 200
        let loopQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        var currVal = [Double](count: convergenceIterations, repeatedValue: 0.0)
        
        // for var n = 1; n <= 200 /* fabs((lastValue-currentValue) / lastValue) > epsilon */; n++
        dispatch_apply(convergenceIterations, loopQueue)
        {
            (i:Int) -> Void in // this is the way to specify one of those "dangling" closures
                
            let n = i + 1
            
            let m = Double(n) * π / (self.windHtFactor * self.windHt)
            
            let x1 = m * r1;
            let x2 = m * r2;
            
            currVal[i] = multiplier * (gsl_pow_2(self.J(n)) / gsl_pow_4(m) * (self.E(n) * IntegralOf_tI1_from(x1, toB: x2) + self.F(n) * IntegralOf_tK1_from(x1, toB: x2) - π / 2.0 * IntegralOf_tL1_from(x1, toB: x2)))
        }
        
        // cool way to get the sum of the values in an array
        result += currVal.reduce(0.0, combine: +)
        
        return result
    }
    
    /// Rabins' methods for mutual inductances
    func MutualInductanceTo(otherDisk:PCH_DiskSection) -> Double
    {
        /// If the inner radii of the two sections differ by less than 1mm, we assume that they are in the same radial position
        let isSameRadialPosition = fabs(Double(self.diskRect.origin.x - otherDisk.diskRect.origin.x)) <= 0.001
        
        let I1 = self.J * Double(self.diskRect.size.width * self.diskRect.size.height) / self.N
        let I2 = otherDisk.J * Double(otherDisk.diskRect.size.width * otherDisk.diskRect.size.height) / otherDisk.N
        
        let N1 = self.N
        let N2 = otherDisk.N
        
        // let testI1 = self.J0() * Double(self.diskRect.size.width) * windHtFactor * self.windHt / self.N
        
        let r1 = Double(self.diskRect.origin.x)
        let r2 = r1 + Double(self.diskRect.size.width)
        
        var result:Double
        
        if (isSameRadialPosition)
        {
            result = (π * µ0 * N1 * N2 / (6.0 * windHtFactor * self.windHt)) * (gsl_pow_2(r2 + r1) + 2.0 * gsl_pow_2(r1))
        }
        else
        {
            result = (π * µ0 * N1 * N2 / (3.0 * windHtFactor * self.windHt)) * (gsl_pow_2(r1) + r1 * r2 + gsl_pow_2(r2))
        }
        
        let multiplier = π * µ0 * windHtFactor * self.windHt * N1 * N2 / ((N1 * I1) * (N2 * I2))
        
        
        // After testing, I've decided to go with the BlueBook recommendation to simply execute the sumation 200 times insead of stopping after some informal definition of "convergence".
        // More testing: putting this in a simple for-loop with 16 LV sections and 60 HV sections took around 20 seconds in the time profiler. Using dispatch_apply(0 reduce this to around 6 seconds !!!
        
        let convergenceIterations = 200
        let loopQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        var currVal = [Double](count: convergenceIterations, repeatedValue: 0.0)
        
        // for i in 0..<convergenceIterations
        dispatch_apply(convergenceIterations, loopQueue)
        {
            (i:Int) -> Void in // this is the way to specify one of those "dangling" closures
            
            let n = i + 1
            
            let m = Double(n) * π / (self.windHtFactor * self.windHt)
            
            let x1 = m * r1;
            let x2 = m * r2;
            
            if (isSameRadialPosition)
            {
                currVal[i] = multiplier * ((self.J(n) * otherDisk.J(n)) / gsl_pow_4(m) * (self.E(n) * IntegralOf_tI1_from(x1, toB: x2) + self.F(n) * IntegralOf_tK1_from(x1, toB: x2) - π / 2.0 * IntegralOf_tL1_from(x1, toB: x2)))
            }
            else
            {
                // let termValueNew = [(self.J(n) * otherDisk.J(n)) / gsl_pow_4(m), otherDisk.C(n), IntegralOf_tI1_from(x1, toB: x2), otherDisk.D(n), IntegralOf_tK1_from(x1, toB: x2)]
                
                currVal[i] = multiplier * ((self.J(n) * otherDisk.J(n)) / gsl_pow_4(m) * (otherDisk.C(n) * IntegralOf_tI1_from(x1, toB: x2) + otherDisk.D(n) * IntegralOf_tK1_from(x1, toB: x2)))
                
                // termValue = termValueNew
            }
            
            
        }
        
        // cool way to get the sum of the values in an array
        result += currVal.reduce(0.0, combine: +)
        
        return result
    }

} // end class declaration
