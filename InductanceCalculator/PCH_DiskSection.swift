//
//  PCH_DiskSection.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

class PCH_DiskSection {

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
    let windHtFactor = 1.0
    
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
        let useOriginY = (useWindht - self.windHt) / 2.0 + Double(self.diskRect.origin.y)
        
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
        
        return gsl_sf_bessel_I0(xc) / gsl_sf_bessel_K0(xc) * self.C(n)
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
        
        return gsl_sf_bessel_I0(xc) / gsl_sf_bessel_K0(xc) * IntegralOf_tK1_from(x1, toB: x2) - IntegralOf_tI1_from0_to(x1)
    }
    
    /// BlueBook function Gn
    func G(n:Int) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = m * self.coreRadius
        
        return gsl_sf_bessel_I0(xc) / gsl_sf_bessel_K0(xc) * IntegralOf_tK1_from(x1, toB: x2) - IntegralOf_tI1_from(x1, toB: x2)
    }
    
    /// Rabins' method for calculating self-inductance
    func SelfInductance() -> Double
    {
        let I1 = self.J * Double(self.diskRect.size.width * self.diskRect.size.height) / self.N
        
        let N1 = self.N
        
        let r1 = Double(self.diskRect.origin.x)
        let r2 = r1 + Double(self.diskRect.size.width)
        
        let firstTerm = (π * µ0 * N1 * N1 / (6.0 * 1.0 * self.windHt)) * (gsl_pow_2(r2 + r1) + 2.0 * gsl_pow_2(r1))
        
        let epsilon = 1.0E-8; // this will decide when we stop the summation
        
        var lastValue = -1.0;
        var currentValue = firstTerm;
        let multiplier = π * µ0 * 1.0 * self.windHt * N1 * N1 / gsl_pow_2(N1 * I1)
        
        if (fabs((lastValue-currentValue) / lastValue) < epsilon)
        {
            ALog("Bad starting values for loop")
            return 0.0
        }
        
        for var n = 1; fabs((lastValue-currentValue) / lastValue) > epsilon; n++
        {
            lastValue = currentValue;
            
            let m = Double(n) * π / (1.0 * self.windHt)
            
            let x1 = m * r1;
            let x2 = m * r2;
            
            currentValue += multiplier * (gsl_pow_2(J(n)) / gsl_pow_4(m) * (E(n) * IntegralOf_tI1_from(x1, toB: x2) + F(n) * IntegralOf_tK1_from(x1, toB: x2) - π / 2.0 * IntegralOf_tL1_from(x1, toB: x2)))
        }
        
        return currentValue
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
        
        let r1 = Double(self.diskRect.origin.x)
        let r2 = r1 + Double(self.diskRect.size.width)
        
        var firstTerm:Double
        
        if (isSameRadialPosition)
        {
            firstTerm = (π * µ0 * N1 * N2 / (6.0 * 1.0 * self.windHt)) * (gsl_pow_2(r2 + r1) + 2.0 * gsl_pow_2(r1))
        }
        else
        {
            firstTerm = (π * µ0 * N1 * N2 / (3.0 * 1.0 * self.windHt)) * (gsl_pow_2(r1) + r1 * r2 + gsl_pow_2(r2))
        }
        
        let epsilon = 1.0E-8; // this will decide when we stop the summation
        
        var lastValue = -1.0;
        var currentValue = firstTerm;
        let multiplier = π * µ0 * 1.0 * self.windHt * N1 * N2 / ((N1 * I1) * (N2 * I2))
        
        if (fabs((lastValue-currentValue) / lastValue) < epsilon)
        {
            ALog("Bad starting values for loop")
            return 0.0
        }
        
        for var n = 1; fabs((lastValue-currentValue) / lastValue) > epsilon; n++
        {
            lastValue = currentValue;
            
            let m = Double(n) * π / (1.0 * self.windHt)
            
            let x1 = m * r1;
            let x2 = m * r2;
            
            if (isSameRadialPosition)
            {
                currentValue += multiplier * ((self.J(n) * otherDisk.J(n)) / gsl_pow_4(m) * (E(n) * IntegralOf_tI1_from(x1, toB: x2) + F(n) * IntegralOf_tK1_from(x1, toB: x2) - π / 2.0 * IntegralOf_tL1_from(x1, toB: x2)))
            }
            else
            {
                currentValue += multiplier * ((self.J(n) * otherDisk.J(n)) / gsl_pow_4(m) * (otherDisk.C(n) * IntegralOf_tI1_from(x1, toB: x2) + otherDisk.D(n) * IntegralOf_tK1_from(x1, toB: x2)))
            }
        }
        
        return currentValue
    }

}
