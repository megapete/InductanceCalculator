//
//  PCH_DiskSection.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

fileprivate let ConvergenceIterations = 300
fileprivate let WindowHtFactor = 3.0

fileprivate struct CoilRadialConstants
{
    var ScaledC:[Double] = Array(repeating: 0.0, count: ConvergenceIterations)
    var ScaledE:[Double] = Array(repeating: 0.0, count: ConvergenceIterations)
    var ScaledD:[Double] = Array(repeating: 0.0, count: ConvergenceIterations)
    var ScaledF:[Double] = Array(repeating: 0.0, count: ConvergenceIterations)
    var PartialScaledIntL1:[(Double, Double)] = Array(repeating: (0.0, 0.0), count: ConvergenceIterations)
    var ScaledIntI1:[Double] = Array(repeating: 0.0, count: ConvergenceIterations)
    
    init(r1:Double, r2:Double, rc:Double, windHt:Double)
    {
        for n in 1...ConvergenceIterations
        {
            let useWindht = WindowHtFactor * windHt
            let m = Double(n) * π / useWindht
            
            let x1 = m * r1
            let x2 = m * r2
            let xc = m * rc
            
            let Ri0 = gsl_sf_bessel_I0_scaled(xc)
            let Rk0 = gsl_sf_bessel_K0_scaled(xc)
            
            ScaledC[n-1] = ScaledIntegralOf_tK1_from(x1, toB: x2)
            ScaledD[n-1] = Ri0 / Rk0 * ScaledC[n-1]
            ScaledE[n-1] = ScaledIntegralOf_tK1_from0_to(x2)
            ScaledF[n-1] = (ScaledD[n-1] - exp(2.0 * (x1 - xc)) * ScaledIntegralOf_tI1_from0_to(x1))
            
            PartialScaledIntL1[n-1] = PartialScaledIntegralOf_tL1_from(x1, toB: x2)
            
            // ScaledIntegralOf_tI1_from
            ScaledIntI1[n-1] = ScaledIntegralOf_tI1_from(x1, toB: x2)
    
        }
        
    }
}

class PCH_DiskSection:NSObject, NSCoding, NSCopying {

    /// A reference number to the coil that "owns" the section.
    let coilRef:Int
    
    /// The number of turns in the section
    let N:Double
    
    /// The current density on the section
    var J:Double
    
    /// The window height of the core that holds the section
    let windHt:Double
    
    /// The core radius
    let coreRadius:Double
    
    /// The rectangle that the disk occupies
    let diskRect:NSRect
    
    /// A factor for "fudging" some calculations. The BlueBook says that a factor of three gives better results.
    // let windHtFactor = 3.0
    
    /// The electrical data associated with the section
    var data:PCH_SectionData
    
    fileprivate static var coilRadialConstants:[Int : CoilRadialConstants] = [:]
    
    /// Data dump for the section
    override var description: String
    {
        var result:String = "Section: \(self.data.sectionID), Serial No: \(self.data.serialNumber)\n"
        result += "In-node: \(self.data.nodes.inNode), Out-node: \(self.data.nodes.outNode)\n"
        result += "Turns: \(self.N), J: \(self.J)\n"
        result += "Rectangle: \(self.diskRect)\n"
        result += "Series Cap: \(self.data.seriesCapacitance), Total Shunt Cap: \(self.data.totalShuntCapacitance)\n"
        result += "Resistance: \(self.data.resistance), Self Inductance: \(self.data.selfInductance)\n"
        
        return result
    }
    
    /**
        Designated initializer
        
        - parameter N: The nuber of turns in the section
        - parameter J: The current density on the section
        - parameter windHt: The window height of the core
        - parameter coreRadius: The core radius

    */
    init(coilRef:Int, diskRect:NSRect, N:Double, J:Double, windHt:Double, coreRadius:Double, secData:PCH_SectionData)
    {
        self.coilRef = coilRef
        self.diskRect = diskRect
        self.N = N
        self.J = J
        self.windHt = windHt
        self.coreRadius = coreRadius
        self.data = secData
        
        if coilRef >= 0 && PCH_DiskSection.coilRadialConstants[coilRef] == nil
        {
            PCH_DiskSection.coilRadialConstants[coilRef] = CoilRadialConstants(r1: Double(diskRect.origin.x), r2: Double(diskRect.origin.x + diskRect.width), rc: coreRadius, windHt: windHt)
        }
    }
    
    // Required initializer for archiving
    convenience required init?(coder aDecoder: NSCoder)
    {
        let coilRef = aDecoder.decodeInteger(forKey: "CoilRef")
        let diskRect = aDecoder.decodeRect(forKey: "DiskRect")
        let N = aDecoder.decodeDouble(forKey: "Turns")
        let J = aDecoder.decodeDouble(forKey: "CurrentDensity")
        let windHt = aDecoder.decodeDouble(forKey: "WindowHeight")
        let coreRadius = aDecoder.decodeDouble(forKey: "CoreRadius")
        let data = aDecoder.decodeObject(forKey: "Data") as! PCH_SectionData
        
        self.init(coilRef:coilRef, diskRect:diskRect, N:N, J:J, windHt:windHt, coreRadius:coreRadius, secData:data)
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = PCH_DiskSection(coilRef: self.coilRef, diskRect: self.diskRect, N: self.N, J: self.J, windHt: self.windHt, coreRadius: self.coreRadius, secData: self.data)
        
        return copy
    }
 
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.coilRef, forKey:"CoilRef")
        aCoder.encode(self.diskRect, forKey:"DiskRect")
        aCoder.encode(self.N, forKey:"Turns")
        aCoder.encode(self.J, forKey:"CurrentDensity")
        aCoder.encode(self.windHt, forKey:"WindowHeight")
        aCoder.encode(self.coreRadius, forKey:"CoreRadius")
        aCoder.encode(self.data, forKey:"Data")
    }
    
    func ResetCoilRadialConstants()
    {
        PCH_DiskSection.coilRadialConstants.removeAll()
    }
    
    /// BlueBook function J0
    func J0(_ windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        
        return self.J * Double(self.diskRect.size.height) / useWindht
    }
    
    /// BlueBook function Jn
    func J(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        // let useOriginY = (useWindht - self.windHt) / 2.0 + Double(self.diskRect.origin.y)
        let useOriginY = Double(self.diskRect.origin.y)
        
        return (2.0 * self.J / (Double(n) * π)) * (sin(Double(n) * π * (useOriginY + Double(self.diskRect.size.height)) / useWindht) - sin(Double(n) * π * useOriginY / useWindht));
    }
    
    /// BlueBook function Cn
    func C(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return IntegralOf_tK1_from(x1, toB: x2)
    }
    
    /// BlueBook function Dn
    func D(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let xc = (Double(n) * π / useWindht) * self.coreRadius
        
        // Alternate method from BlueBook 2nd Ed., page 267
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        let eBase = exp(2.0 * xc)
        
        let result = eBase * (Ri0 / Rk0) * self.C(n, windHtFactor:windHtFactor)
    
        return result
        
        /* old way
        
        let I0 = gsl_sf_bessel_I0(xc)
        let K0 = gsl_sf_bessel_K0(xc)
        
        return I0 / K0 * self.C(n)
        */
    }
    
    func ScaledD(_ n:Int, windHtFactor:Double) -> Double
    {
        // returns Rd where D = exp(2.0 * xc - x1) * Rd (xc and x1 are functions of n)
        
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = (Double(n) * π / useWindht) * self.coreRadius
        
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        
        let ScaledCn = ScaledIntegralOf_tK1_from(x1, toB: x2)
        
        return Ri0 / Rk0 * ScaledCn
    }
    
    func AlternateD(_ n:Int, windHtFactor:Double) -> Double
    {
        // The Dn function, using scaled methods
        
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = (Double(n) * π / useWindht) * self.coreRadius
        
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        
        let ScaledCn = ScaledIntegralOf_tK1_from(x1, toB: x2)
        
        return exp(2.0 * xc - x1) * Ri0 / Rk0 * ScaledCn
    }
    
    func ScaledC(_ n:Int, windHtFactor:Double) -> Double
    {
        // return IntCn where the actual integral = exp(-x1) * IntCn, where x1 = n * π / useWindht * self.diskRect.origin.x
        
        let useWindht = windHtFactor * self.windHt
        let m = Double(n) * π / useWindht
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return ScaledIntegralOf_tK1_from(x1, toB: x2)
    }
    
    /// BlueBook function En
    func E(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let x2 = (Double(n) * π / useWindht) * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return IntegralOf_tK1_from0_to(x2)
    }
    
    /*
    func ScaledE(_ n:Int, windHtFactor:Double) -> Double
    {
        // return Re where the actual integral = π / 2.0 * (1.0 - exp(-x2) * Re)
        let useWindht = windHtFactor * self.windHt
        let x2 = (Double(n) * π / useWindht) * Double(self.diskRect.origin.x + self.diskRect.size.width)
        
        return ScaledIntegralOf_tK1_from0_to(x2)
    }
 */
    
    /// BlueBook function Fn
    func F(_ n:Int, windHtFactor:Double) -> Double
    {
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        
        // Old way
        // let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        // let xc = m * self.coreRadius
        
        // Alternate method from BlueBook 2nd Ed., page 267
        // let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        // let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        // let eBase = exp(2.0 * xc)
 
        let result = AlternateD(n, windHtFactor:windHtFactor) - IntegralOf_tI1_from0_to(x1)
        
        return result
        
        // OLD return eBase * (Ri0 / Rk0) * IntegralOf_tK1_from(x1, toB: x2) - IntegralOf_tI1_from0_to(x1)
    }
    
    func AlternateF(_ n:Int, windHtFactor:Double) -> Double
    {
        // Best method of calculating F (uses scaling techniques)
        
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let xc = m * self.coreRadius
        
        let exponent = 2.0 * xc - x1
        
        let result = exp(exponent) * (ScaledD(n, windHtFactor:windHtFactor) - exp(x1 - exponent) * ScaledIntegralOf_tI1_from0_to(x1))
        
        return result
    }
    
    func ScaledF(_ n:Int, windHtFactor:Double) -> Double
    {
        // return Rf where F = exp(2.0 * xc - x1) * Rf (xc and x1 are functions of n)
        
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let xc = m * self.coreRadius
        
        let exponent = 2.0 * xc - x1
        
        let result = (ScaledD(n, windHtFactor:windHtFactor) - exp(x1 - exponent) * ScaledIntegralOf_tI1_from0_to(x1))
        
        return result
        
    }
    
    /// BlueBook function Gn
    func G(_ n:Int, windHtFactor:Double) -> Double
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
    
    func ScaledG(_ n:Int, windHtFactor:Double) -> Double
    {
        // return Rg where Gn = e(x1) * Rg
        
        let useWindht = windHtFactor * self.windHt
        let m = (Double(n) * π / useWindht)
        
        let x1 = m * Double(self.diskRect.origin.x)
        let x2 = m * Double(self.diskRect.origin.x + self.diskRect.size.width)
        let xc = m * self.coreRadius
        
        let Ri0 = gsl_sf_bessel_I0_scaled(xc)
        let Rk0 = gsl_sf_bessel_K0_scaled(xc)
        let RtK = ScaledIntegralOf_tK1_from(x1, toB: x2)
        let RtI = ScaledIntegralOf_tI1_from(x1, toB: x2)
        
        let exponent = 2.0 * xc - 2.0 * x1
        
        let Rg = e(exponent) * (Ri0 / Rk0) * RtK + RtI
        
        return Rg
    }
    
    /// Rabins' method for calculating self-inductance
    func SelfInductance(_ windHtFactor:Double) -> Double
    {
        let I1 = self.J * Double(self.diskRect.size.width * self.diskRect.size.height) / self.N
        
        let N1 = self.N
        
        let r1 = Double(self.diskRect.origin.x)
        let r2 = r1 + Double(self.diskRect.size.width)
        let rc = self.coreRadius
        
        var result = (π * µ0 * N1 * N1 / (6.0 * windHtFactor * self.windHt)) * (gsl_pow_2(r2 + r1) + 2.0 * gsl_pow_2(r1))
        
        let multiplier = π * µ0 * windHtFactor * self.windHt * N1 * N1 / gsl_pow_2(N1 * I1)
        
        let convergenceIterations = ConvergenceIterations
        
        let addQueue = DispatchQueue(label: "com.huberistech.selfinductance.addition")
        
        // for var n = 1; n <= 200 /* fabs((lastValue-currentValue) / lastValue) > epsilon */; n++
        DispatchQueue.concurrentPerform(iterations: convergenceIterations)
        {
            (i:Int) -> Void in // this is the way to specify one of those "dangling" closures
                
            let n = i + 1
            
            let m = Double(n) * π / (windHtFactor * self.windHt)
            let mPow4 = m * m * m * m
            
            let x1 = m * r1;
            let x2 = m * r2;
            let xc = m * rc;
            
            // The scaled version of Fn returns the remainder Rf where Fn = exp(2.0 * xc - x1) * Rf
            // let scaledFn = self.ScaledF(n, windHtFactor:windHtFactor)
            let scaledFn = PCH_DiskSection.coilRadialConstants[self.coilRef]!.ScaledF[i]
            
            // the exponent after combining the two scaled remainders of Cn and Dn is (2.0 * xc - 2.0 * x1)
            let exponentCnDn = 2.0 * (xc - x1)
            
            // This is ScaledCn
            // let scaledTK1 = ScaledIntegralOf_tK1_from(x1, toB: x2)
            let scaledCn = PCH_DiskSection.coilRadialConstants[self.coilRef]!.ScaledC[i]
            
            // let (IntI1TermUnscaled, scaledI1) = PartialScaledIntegralOf_tL1_from(x1, toB: x2)
            let (IntL1TermUnscaled, scaledI1) = PCH_DiskSection.coilRadialConstants[self.coilRef]!.PartialScaledIntL1[i]
            
            // let mult = PCH_DiskSection.coilRadialConstants[self.coilRef]!.E[i] - π / 2.0
            let scaledEn = PCH_DiskSection.coilRadialConstants[self.coilRef]!.ScaledE[i]
            
            // var newWay = mult * exp(x1) * scaledI1
            var newWay = π / 2.0 * exp(x1 - x2) * (-scaledEn) * scaledI1
            newWay -= (π / 2.0) *  IntL1TermUnscaled
            newWay += exp(exponentCnDn) * (scaledFn * scaledCn)
            
            addQueue.sync {
                result += multiplier * (gsl_pow_2(self.J(n, windHtFactor:windHtFactor)) / mPow4) * newWay
            }
            
        }
        
        return result
    }
    
    /// Rabins' methods for mutual inductances
    func MutualInductanceTo(_ otherDisk:PCH_DiskSection) -> Double
    {
        /// If the inner radii of the two sections differ by less than 1mm, we assume that they are in the same radial position
        let isSameRadialPosition = fabs(Double(self.diskRect.origin.x - otherDisk.diskRect.origin.x)) <= 0.001
        
        let I1 = self.J * Double(self.diskRect.size.width * self.diskRect.size.height) / self.N
        let I2 = otherDisk.J * Double(otherDisk.diskRect.size.width * otherDisk.diskRect.size.height) / otherDisk.N
        
        let N1 = self.N
        let N2 = otherDisk.N
        
        let r1 = Double(self.diskRect.origin.x)
        let r2 = r1 + Double(self.diskRect.size.width)
        let r3 = Double(otherDisk.diskRect.origin.x)
        // let r4 = r3 + Double(otherDisk.diskRect.size.width)
        let rc = self.coreRadius
        
        var result:Double
        
        if (isSameRadialPosition)
        {
            result = (π * µ0 * N1 * N2 / (6.0 * WindowHtFactor * self.windHt)) * (gsl_pow_2(r2 + r1) + 2.0 * gsl_pow_2(r1))
        }
        else
        {
            result = (π * µ0 * N1 * N2 / (3.0 * WindowHtFactor * self.windHt)) * (gsl_pow_2(r1) + r1 * r2 + gsl_pow_2(r2))
        }
        
        let multiplier = π * µ0 * WindowHtFactor * self.windHt * N1 * N2 / ((N1 * I1) * (N2 * I2))
        
        // After testing, I've decided to go with the BlueBook recommendation to simply execute the summation 200 times insead of stopping after some informal definition of "convergence". [Subsequently changed to 300 times)
        
        let convergenceIterations =  300
        
        let addQueue = DispatchQueue(label: "com.huberistech.mutualinductance.addition")
        
        // for i in 0..<convergenceIterations
        DispatchQueue.concurrentPerform(iterations: convergenceIterations)
        {
            (i:Int) -> Void in // this is the way to specify one of those "dangling" closures
            
            let n = i + 1
            
            let m = Double(n) * π / (WindowHtFactor * self.windHt)
            let mPow4 = m * m * m * m
            
            let x1 = m * r1;
            let x2 = m * r2;
            let x3 = m * r3
            // let x4 = m * r4
            let xc = m * rc;
            
            if (isSameRadialPosition)
            {
                // This uses the same "scaled" version of the iteration step as the SelfInductance() function above. See there for more comments.
                
                // The scaled version of Fn returns the remainder Rf where Fn = exp(2.0 * xc - x1) * Rf
                let scaledFn = PCH_DiskSection.coilRadialConstants[self.coilRef]!.ScaledF[i]
                
                // the exponent after combining the two scaled remainders of Cn and Dn is (2.0 * xc - 2.0 * x1)
                let exponentCnDn = 2.0 * (xc - x1)
                
                let scaledCn = PCH_DiskSection.coilRadialConstants[self.coilRef]!.ScaledC[i]
                
                let (IntL1TermUnscaled, scaledI1) = PCH_DiskSection.coilRadialConstants[self.coilRef]!.PartialScaledIntL1[i]
                
                let scaledEn = PCH_DiskSection.coilRadialConstants[self.coilRef]!.ScaledE[i]
                
                // var newWay = mult * exp(x1) * scaledI1
                var newWay = π / 2.0 * exp(x1 - x2) * (-scaledEn) * scaledI1
                newWay -= (π / 2.0) *  IntL1TermUnscaled
                newWay += exp(exponentCnDn) * (scaledFn * scaledCn)
                
                addQueue.sync {
                    result += multiplier * ((self.J(n, windHtFactor:WindowHtFactor) * otherDisk.J(n, windHtFactor:WindowHtFactor)) / mPow4) * newWay
                }
            }
            else
            {
                let firstProduct = PCH_DiskSection.coilRadialConstants[otherDisk.coilRef]!.ScaledC[i] * PCH_DiskSection.coilRadialConstants[self.coilRef]!.ScaledIntI1[i]
                
                let secondProduct = PCH_DiskSection.coilRadialConstants[otherDisk.coilRef]!.ScaledD[i] * PCH_DiskSection.coilRadialConstants[self.coilRef]!.ScaledC[i]
                
                let newWay = exp(x1 - x3) * firstProduct + exp(2.0 * xc - x1 - x3) * secondProduct

                addQueue.sync {
                    result += multiplier * ((self.J(n, windHtFactor:WindowHtFactor) * otherDisk.J(n, windHtFactor:WindowHtFactor)) / mPow4) * newWay
                }
            }
        }
        
        return result
    }

} // end class declaration
