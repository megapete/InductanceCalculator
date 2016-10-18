//
//  AppDelegate.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-27.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Testing Bluebook functions
        
        
        /*
        var lvRect = NSMakeRect(19.72 / 2.0 * 25.4/1000.0, 2.6 * 25.4/1000.0, 1.913 * 25.4/1000.0, 35.454 * 25.4/1000.0)
        var hvRect = NSMakeRect(25.639 / 2.0 * 25.4/1000.0, 2.6 * 25.4/1000.0, 1.913 * 25.4/1000.0, 35.454 * 25.4/1000.0)
        
        var J = 209.0 * 300.0 / Double(lvRect.size.width * lvRect.size.height)
        
        var lv = PCH_DiskSection(diskRect: lvRect, N: 209, J: -J , windHt: 1.08, coreRadius: 0.225)
        var hv = PCH_DiskSection(diskRect: hvRect, N: 209, J: J, windHt: 1.08, coreRadius: 0.225)
        
        var L1 = lv.SelfInductance()
        var L2 = hv.SelfInductance()
        var M12 = lv.MutualInductanceTo(hv)
        
        // Simplified calculation for transformers where N1 = N2
        var lkInd = L1 + L2 - 2.0 * M12
        
        DLog("Leakage reactance (ohms): \(lkInd * 2.0 * π * 60.0)")

*/
/*
        let lvRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, 2.965 * 25.4/1000.0, 0.296 * 25.4/1000.0, 32.065 * 25.4/1000)
        let lv = PCH_DiskSection(diskRect: lvRect, N: 16.0, J: -16.0 * 481.13 / Double(lvRect.size.width * lvRect.size.height), windHt: 1.1, coreRadius: 0.141, secData:PCH_SectionData(sectionID: "LV"))
        let hvRect = NSMakeRect(25.411 / 2.0 * 25.4/1000.0, 2.75 * 25.4/1000.0, 5.148 * 25.4/1000.0, 32.495 * 25.4/1000)
        let hv = PCH_DiskSection(diskRect: hvRect, N: 3200.0, J: 3200.0 * 2.4056 / Double(hvRect.size.width * hvRect.size.height), windHt: 1.1, coreRadius: 0.141, secData:PCH_SectionData(sectionID: "HV"))
        
        let L1 = lv.SelfInductance()
        let L2 = hv.SelfInductance()
        let M12 = lv.MutualInductanceTo(hv)
        let M21 = hv.MutualInductanceTo(lv)
        
        // The actual calculation for two-winding transformers (exactly right!!!)
        // This is the leakage inductance looking from the L1 (in this case LV) side
        let lkInd = L1 + gsl_pow_2(16.0 / 3200.0) * L2 - 2.0 * (16.0 / 3200.0) * M12
        
        DLog("Leakage reactance (ohms): \(lkInd * 2.0 * π * 60.0)")
*/
        // Test FFT
        /*
        var testArray = [Double](repeating: 0.0, count: 8)
        testArray[0] = 1.0
        let fftTest = GetFFT(testArray)
        
        for i in 0..<8
        {
            DLog("FFT[\(i)]: \(fftTest[i])")
        }
        */
        
        /*
        var lvRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, (2.25 + 1.913/2.0) * 25.4/1000.0, 0.296 * 25.4/1000.0, 32.065 * 25.4/1000)
        let lv = PCH_DiskSection(coilRef: 0, diskRect: lvRect, N: 16.0, J: 481.125 * 16.0 / Double(lvRect.size.width * lvRect.size.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData:PCH_SectionData(sectionID: "LV", serNum:0, inNode:0, outNode:1))
        var hvRect = NSMakeRect(25.411 / 2.0 * 25.4/1000.0, 2.75 * 25.4/1000.0, 5.148 * 25.4/1000.0, 32.495 * 25.4/1000)
        let hv = PCH_DiskSection(coilRef:1, diskRect: hvRect, N: 3200.0, J: 3200.0 * 2.406 / Double(hvRect.size.width * hvRect.size.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData:PCH_SectionData(sectionID: "HV", serNum:1, inNode:2, outNode:3))
        
        let L1 = lv.SelfInductance()
        let L2 = hv.SelfInductance()
        let M12 = lv.MutualInductanceTo(hv)
        
        let lkInd = L2 + gsl_pow_2(3200.0 / 16.0) * L1 - 2.0 * (3200.0 / 16.0) * M12
        // var magEnergy = lkInd * 481.125 * 481.125 / 2.0
        
        
        DLog("Leakage reactance (ohms): \(lkInd * 2.0 * π * 60.0)")
        */
        
        // Create the special "ground" section. By convention, it has a serial number of -1.
        let gndSection = PCH_DiskSection(coilRef: -1, diskRect: NSMakeRect(0, 0, 0, 0), N: 0, J: 0, windHt: 0, coreRadius: 0, secData: PCH_SectionData(sectionID: "GND", serNum: -1, inNode:-1, outNode:-1))
        
        // Now we try again but split each coil into sections. 
        // NOTE: To get this to work with SPICE, it is necessary to increase RELTOL to 0.025 (LTSpice)
        // let lvCoilSections = 16
        // let hvCoilSections = 60
        
        // New stuff (to make things more "general")
        
        // NOTE: To get this to work with SPICE, it may be necessary to increase RELTOL to as high as 0.025 (LTSpice)
        
        let windowHeight = 1.56
        let coreRadius = 0.51562 / 2.0
        
        // Overly simplistic way to take care of eddy losses at higher frequencies (the 3000 comes from the Bluebook)
        let resFactor = 2000.0 // 3000.0
        
        // Set the index numbers for the three coils we'll be modeling. NOTE: The coil index numbers MUST be in order from closest-to-core (0) to furthest-from-core.
        let lvCoil = 0
        let hvCoil = 1
        let rvCoil = 2
        
        let numCoils = 3
        
        let numCoilSections = [98, 66, 80]
        
        // This works with the following LTSpice settings: Method = Gear, abstol = 1E-6, reltol = 0.03, trtol = 7
        // (with inspiration from from: http://www.intusoft.com/articles/converg.pdf)
        let useNumCoilSections = [2, 66, 80]
        
        let zBot = [2.5 * 25.4/1000.0, 2.5 * 25.4/1000.0, 7.792 * 25.4/1000.0]
        let zHt = [50.944 * 25.4/1000.0, 51.055 * 25.4/1000.0, 40.465 * 25.4/1000.0]
        let zInterDisk = [0.15 * 0.98 * 25.4/1000.0, 0.22 * 0.98 * 25.4/1000.0, 0.15 * 0.98 * 25.4/1000.0]
        
        var zSection = [Double](repeatElement(0.0, count: numCoils))
        for i in 0..<numCoils
        {
            zSection[i] = (zHt[i] - zInterDisk[i] * Double(useNumCoilSections[i] - 1)) / Double(useNumCoilSections[i])
        }
        
        let Irms = [113.636, 72.169, 36.084]
        
        let N = [579, 912, 182]
        
        let innerRadius = [22.676 / 2.0 * 25.4/1000.0, 31.582 / 2.0 * 25.4/1000.0, 41.802 / 2.0 * 25.4/1000.0]
        let outerRadius = [26.482 / 2.0 * 25.4/1000.0, 36.302 / 2.0 * 25.4/1000.0, 42.483 / 2.0 * 25.4/1000.0]
        let identification = ["LV", "HV", "RV"]
        let resistancePerSection = [0.424257 / Double(numCoilSections[lvCoil]) * resFactor, 1.361154 / Double(numCoilSections[hvCoil]) * resFactor, 0.649376 / Double(numCoilSections[rvCoil]) * resFactor]
        
        // The capacitances are a bit more complicated to set up. The series capacitances can change within a coil (partial interleaving, static rings) and there are usually multiple shunt capacitances from any given coil section (to other coil sections, ground, etc). This is all further complicated by the fact that we may not be modelling every disk.
        
        // We'll set up three different arrays for the series capacitances. The LV and RV are simple but the HV has an interleaved section.
        var lvSeriesCaps = [Double](repeatElement(0.0, count: numCoilSections[lvCoil]))
        var hvSeriesCaps = [Double](repeatElement(0.0, count: numCoilSections[hvCoil]))
        var rvSeriesCaps = [Double](repeatElement(0.0, count: numCoilSections[rvCoil]))
        
        // first (bottommost) LV disk + static ring
        lvSeriesCaps[0] = 6.498E-10
        
        // normal disks
        for i in 1..<numCoilSections[lvCoil]-1
        {
            lvSeriesCaps[i] = 8.007E-10
        }
        
        // last (topmost) LV disk with static ring
        lvSeriesCaps[numCoilSections[lvCoil]-1] = 6.498E-10
        
        // The bottommost HV disk does not have a static ring
        hvSeriesCaps[0] = 2.643E-10
        
        // The top disks are interleaved, so we'll set a simple variable for use in the rest of the HV series caps
        let topInterleavedDisks = 12
        
        let lastNonInterleavedDisk = numCoilSections[hvCoil] - topInterleavedDisks
        for i in 1..<lastNonInterleavedDisk
        {
            hvSeriesCaps[i] = 8.093E-10
        }
        
        // now the interleaved disks (except the top one, which also has a static ring)
        if topInterleavedDisks != 0
        {
            for i in lastNonInterleavedDisk..<numCoilSections[hvCoil]-1
            {
                hvSeriesCaps[i] = 6.186E-9
            }
        }
        
        // and now the top HV disk with its static ring
        hvSeriesCaps[numCoilSections[hvCoil]-1] = (topInterleavedDisks != 0 ? 6.158E-9 : 7.846E-10)
        
        // And we finish with the regulating winding
        // first (bottommost) RV disk
        rvSeriesCaps[0] = 9.404E-10
        
        // normal disks
        for i in 1..<numCoilSections[rvCoil]-1
        {
            rvSeriesCaps[i] = 5.509E-10
        }
        
        // last (topmost) RV disk with static ring
        rvSeriesCaps[numCoilSections[rvCoil]-1] = 5.081E-10
        
        // Now create an array of arrays for the series capacitances
        let seriesCapacitances = [lvSeriesCaps, hvSeriesCaps, rvSeriesCaps]
        
        // Shunt capacitances are by far the most challenging to define (but probably easiest to calculate, ie: capacitance of concentric cylinders). The innermost coil will have a "total" capacitance to ground (core) and similarly, the outermost coil will have a ground capacitance to the tank. Other coils will all have total capactiances to adjacent coils, which must be distributed to the number of sections we're using. This should be easy, except not all coils are of the same height (ie: regulating windings). 
        
        // We store the full "radial capacitance" inside each coil (to the previous coil). Note that the core and the tank are considered the first and last coils in this array.
        let radialCapacitances = [2.071E-9, 1.157E-9, 1.145E-9, 1.0E-12]
        
        // We set up an array of arrays to hold each of the coil's sections.
        var coils = [[PCH_DiskSection]]()
        
        var sectionSerialNumber = 0
        var nodeSerialNumber = 0

        // We start by setting up the geometric, series-capacitance, self-inductances and resistance data for the coils. We'll take care of shunt capacitances and mutual inductances later.
        for currentCoil in 0..<numCoils
        {
            // set up some loop variables
            var currentZ = CGFloat(zBot[currentCoil])
            let currentRB = CGFloat(outerRadius[currentCoil]-innerRadius[currentCoil])
            let currentID = identification[currentCoil]
            let ir = CGFloat(innerRadius[currentCoil])
            let secHt = CGFloat(zSection[currentCoil])
            let zStep = secHt + CGFloat(zInterDisk[currentCoil])
            let currentResistance = resistancePerSection[currentCoil] * Double(numCoilSections[currentCoil]) / Double(useNumCoilSections[currentCoil])
            
            let disksPerSection = Double(numCoilSections[currentCoil]) / Double(useNumCoilSections[currentCoil])
            let turnsPerSection = Double(N[currentCoil]) / Double(useNumCoilSections[currentCoil])
            
            var currentCoilSections = [PCH_DiskSection]()
            
            for currentSection in 0..<useNumCoilSections[currentCoil]
            {
                let nextSectionRect = NSMakeRect(ir, currentZ, currentRB, secHt)
                
                var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", currentID, currentSection+1), serNum:sectionSerialNumber, inNode:nodeSerialNumber, outNode:nodeSerialNumber+1)
                
                // Save the resistance for the section
                nextSectionData.resistance = currentResistance
                
                // Calculate and save the series capacitance for the section. This could be optimized for the case where the number of sections is equal to the number of disks.
                let firstDisk = Int(round(Double(currentSection) * disksPerSection))
                let lastDisk = Int(round(Double(currentSection+1) * disksPerSection))
                
                var sumOfInverses = 0.0
                for nextDisk in firstDisk..<lastDisk
                {
                    sumOfInverses += 1.0 / seriesCapacitances[currentCoil][nextDisk]
                }
                
                nextSectionData.seriesCapacitance = 1.0 / sumOfInverses
                
                let nextSection = PCH_DiskSection(coilRef: currentCoil, diskRect: nextSectionRect, N: turnsPerSection, J: turnsPerSection * Irms[currentCoil] / Double(nextSectionRect.width * nextSectionRect.height), windHt: windowHeight, coreRadius: coreRadius, secData: nextSectionData)
                
                // Calculate and save the self-inductance for the section
                nextSection.data.selfInductance = nextSection.SelfInductance()
                
                currentCoilSections.append(nextSection)

                sectionSerialNumber += 1
                nodeSerialNumber += 1
                
                currentZ += zStep
            }
            
            coils.append(currentCoilSections)
            nodeSerialNumber += 1
        }
        
        // Testing blueBook functions
        // The disks to test
        let testDisk = coils[hvCoil][65]
        let testDisk2 = coils[rvCoil][70]
        
        for n in [1,2,3,4,5,10,15,20,25,50,100,150,200]
        {
            DLog("With n = \(n)")
            
            let m = Double(n) * π / (testDisk.windHtFactor * testDisk.windHt)
            
            let r1 = Double(testDisk.diskRect.origin.x)
            let r2 = r1 + Double(testDisk.diskRect.size.width)
            let r3 = Double(testDisk2.diskRect.origin.x)
            let r4 = r3 + Double(testDisk2.diskRect.size.width)
            let rc = testDisk.coreRadius
            
            let x1 = m * r1
            let x2 = m * r2
            let x3 = m * r3
            let x4 = m * r4
            let xc = m * rc
            
            // let integralTI1 = IntegralOf_tI1_from(x1, toB: x2)
            // let integralTK1 = IntegralOf_tK1_from(x1, toB: x2)
            
            // Old Way
            let oldWay = (testDisk2.C(n) * IntegralOf_tI1_from(x1, toB: x2) + testDisk2.D(n) * IntegralOf_tK1_from(x1, toB: x2))
            let CnOld = testDisk2.C(n)
            let CnNew = exp(-x3) * ScaledIntegralOf_tK1_from(x3, toB: x4)
            let firstTermOldWay = testDisk2.C(n) * IntegralOf_tI1_from(x1, toB: x2)
            let firstTermNewWay = exp(-x3+x1) * ScaledIntegralOf_tK1_from(x3, toB: x4) * ScaledIntegralOf_tI1_from(x1, toB: x2)
            
            let outerExp = exp(2.0 * xc - x3 - x1)
            let innerExp = exp(-2.0 * xc + 2.0 * x1)
            
            let firstProduct = ScaledIntegralOf_tK1_from(x3, toB: x4) * ScaledIntegralOf_tI1_from(x1, toB: x2)
            let secondProduct = testDisk2.ScaledD(n) * ScaledIntegralOf_tK1_from(x1, toB: x2)
            let insideTerm = innerExp * firstProduct + secondProduct
            let newWay = outerExp * insideTerm
            
            
            
            // let newWay = mult * exp(x1) * scaledI1 - (π / 2.0) *  IntI1TermUnscaled + exp(exponent) * (scaledFn * scaledTK1)
            
            DLog("Old: \(oldWay), New: \(newWay)")
            
        }
        
        
        
        // Now we'll set up the shunt capacitances.
        // TODO: Make the radial capacitive distibution more realistic for coils of unequal heights (eg: tapping windings)
        
        // The first "inner section" is the core, which is represented by a "coil" with one section
        var numInnerCoilSections = 1
        var currentInnerCoilSections = [gndSection]
        
        // We set up the loop to go "one over" to take care of the final coil's capacitance to the tank
        for i in 0...numCoils
        {
            // The radial capacitance will be distrbuted to a finite number of capacitances, where the number is the max number of sections in the two coils currently being considered..
            var maxSections = 1
            var numCurrentCoilSections = 0
            var currentCoilSections:[PCH_DiskSection]
            if (i != numCoils)
            {
                numCurrentCoilSections = useNumCoilSections[i]
                currentCoilSections = coils[i]
                maxSections = max(numInnerCoilSections, numCurrentCoilSections)
            }
            else // take care of the final capacitance (to the tank)
            {
                // This will work even if numInnerCoilSections is equal to 1
                maxSections = numInnerCoilSections
                numCurrentCoilSections = 1
                currentCoilSections = [gndSection]
            }
            
            // Distribute the radial capacitance
            let capPerSection = radialCapacitances[i] / Double(maxSections)
            
            // We initialize both section indices to 0 to start the distribution
            var leftSectionIndex = 0
            var rightSectionIndex = 0
            
            for j in 0..<maxSections
            {
                // We copy the shunt capacitances into each of the coil sections - we need to make sure we do not double up these capacitances when we create the Spice file
                currentInnerCoilSections[leftSectionIndex].data.shuntCaps[currentCoilSections[rightSectionIndex]] = capPerSection
                currentCoilSections[rightSectionIndex].data.shuntCaps[currentInnerCoilSections[leftSectionIndex]] = capPerSection
                
                leftSectionIndex = Int(Double(j+1) * (Double(numInnerCoilSections) / Double(maxSections)))
                rightSectionIndex = Int(Double(j+1) * (Double(numCurrentCoilSections) / Double(maxSections)))
            }
            
            // Set the inner data for the next loop
            numInnerCoilSections = numCurrentCoilSections
            currentInnerCoilSections = currentCoilSections
            
        }
        
        // And finally, mutual inductances
        var cArray = [PCH_DiskSection]()
        for nextSections in coils
        {
            cArray.append(contentsOf: nextSections)
        }
        
        DLog("Calculating mutual inductances")
        while cArray.count > 0
        {
            let nDisk = cArray.remove(at: 0)
            
            for otherDisk in cArray
            {
                let mutInd = fabs(nDisk.MutualInductanceTo(otherDisk))
                
                let mutIndCoeff = mutInd / sqrt(nDisk.data.selfInductance * otherDisk.data.selfInductance)
                if (mutIndCoeff < 0.0 || mutIndCoeff > 1.0)
                {
                    DLog("Illegal Mutual Inductance:\(mutInd); this.SelfInd:\(nDisk.data.selfInductance); that.SelfInd:\(otherDisk.data.selfInductance)")
                }
                
                nDisk.data.mutualInductances[otherDisk.data.sectionID] = mutInd
                otherDisk.data.mutualInductances[nDisk.data.sectionID] = mutInd
                
                // This ends up being the important thing to do
                nDisk.data.mutInd[otherDisk] = mutInd
                otherDisk.data.mutInd[nDisk] = mutInd
                
                nDisk.data.mutIndCoeff[otherDisk.data.sectionID] = mutIndCoeff
                otherDisk.data.mutIndCoeff[nDisk.data.sectionID] = mutIndCoeff
                
            }
        }
        
        /*
        var lvSectionArray = [PCH_DiskSection]()
        // do the lv first
        var lvZ = (2.25 + 1.913/2.0) * 25.4/1000.0
        let lvZStep = 32.065 / Double(lvCoilSections) * 25.4/1000
        let lvI = 481.125
        let lvN = 16.0 / Double(lvCoilSections)
        let lvcoilID = "LV"
        let lvResPerSection = 1.3909E-3 * lvN * resFactor
        let lvSerCapPerSection = 1.8072E-10 / lvN
        let lvShuntCapPerSection = (3.9534E-11 + 3.2097E-11) * lvN
        
        
        for i in 0 ..< lvCoilSections
        {
            let nextSectionRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, CGFloat(lvZ), 0.296 * 25.4/1000.0, CGFloat(lvZStep))
            
            var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", lvcoilID, i+1), serNum:sectionSerialNumber, inNode:nodeSerialNumber, outNode:nodeSerialNumber+1)
            
            sectionSerialNumber += 1
            nodeSerialNumber += 1
            
            nextSectionData.resistance = lvResPerSection
            nextSectionData.seriesCapacitance = lvSerCapPerSection
            nextSectionData.shuntCapacitances["0"] = lvShuntCapPerSection
            nextSectionData.shuntCaps[gndSection] = lvShuntCapPerSection
            
            let nextSection = PCH_DiskSection(diskRect: nextSectionRect, N: lvN, J: lvN * lvI / Double(nextSectionRect.width * nextSectionRect.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData: nextSectionData)
            
            nextSection.data.selfInductance = nextSection.SelfInductance()
            
            coilSections.append(nextSection)
            lvSectionArray.append(nextSection)
            
            lvZ += lvZStep
        }
        
        nodeSerialNumber += 1
        // And now the HV
        var hvZ = 2.75 * 25.4/1000.0
        let hvZStep = 32.495 / Double(hvCoilSections) * 25.4/1000
        let hvI = 2.406
        let hvN = 3200.0 / Double(hvCoilSections)
        let hvSections = 60.0 / Double(hvCoilSections)
        let hvcoilID = "HV"
        let hvResPerSection = 0.19727 * hvSections * resFactor
        let hvSerCapPerSection = 1.6185E-9 / hvSections
        let hvShuntCapPerSection = (6.5814E-12 + 1.0259E-22) * hvSections
        
        var hvSectionArray = [PCH_DiskSection]()
        for i in 0 ..< hvCoilSections
        {
            let nextSectionRect = NSMakeRect(25.411 / 2.0 * 25.4/1000.0, CGFloat(hvZ), 5.148 * 25.4/1000.0, CGFloat(hvZStep))
            
            var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", hvcoilID, i+1), serNum:sectionSerialNumber, inNode:nodeSerialNumber, outNode:nodeSerialNumber+1)
            sectionSerialNumber += 1
            nodeSerialNumber += 1
            
            nextSectionData.resistance = hvResPerSection
            nextSectionData.seriesCapacitance = hvSerCapPerSection
            nextSectionData.shuntCapacitances["0"] = hvShuntCapPerSection
            nextSectionData.shuntCaps[gndSection] = hvShuntCapPerSection
            
            let nextSection = PCH_DiskSection(diskRect: nextSectionRect, N: hvN, J: hvN * hvI / Double(nextSectionRect.width * nextSectionRect.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData: nextSectionData)
            
            nextSection.data.selfInductance = nextSection.SelfInductance()
            
            coilSections.append(nextSection)
            hvSectionArray.append(nextSection)
            
            hvZ += hvZStep
        }
        
        
        
         
        // Create the inductance matrix, resistance matrix, and capacitance (base) matrix
        
        // We start by defining a couple of somewhat obvious constants (this is for future reference to see what the strategy is for defining the number of sections and nodes).
        let sectionCount = lvCoilSections + hvCoilSections
        let nodeCount = (lvCoilSections + 1) + (hvCoilSections + 1)
        
        let M = PCH_Matrix(numRows: sectionCount, numCols: sectionCount, matrixPrecision: PCH_Matrix.precisions.doublePrecision, matrixType: PCH_Matrix.types.positiveDefinite)
        
        let R = PCH_Matrix(numRows: sectionCount, numCols: sectionCount, matrixPrecision: PCH_Matrix.precisions.doublePrecision, matrixType: PCH_Matrix.types.diagonalMatrix)
        
        // B could be defined as a banded matrix, but at the time of this writing, multiplication has not yet been implemented for banded matrices in PCH_Matrix.
        let B = PCH_Matrix(numRows: sectionCount, numCols: nodeCount, matrixPrecision: PCH_Matrix.precisions.doublePrecision, matrixType: PCH_Matrix.types.generalMatrix)
        
        // A could also be defined as banded, see the comment above for matrix B
        let A = PCH_Matrix(numRows: nodeCount, numCols: sectionCount, matrixPrecision: PCH_Matrix.precisions.doublePrecision, matrixType: PCH_Matrix.types.generalMatrix)
        
        let Cbase = PCH_Matrix(numRows: nodeCount, numCols: nodeCount, matrixPrecision: PCH_Matrix.precisions.doublePrecision, matrixType: PCH_Matrix.types.generalMatrix)
        
        let lvNodeBase = 0
        let hvNodeBase = lvCoilSections + 1
        
        let startNodes = [lvNodeBase, hvNodeBase]
        let endNodes = [lvCoilSections, hvNodeBase + hvCoilSections]
        
        // we need to keep track of the previous section for the capacitance matrix
        var prevSection:PCH_DiskSection? = nil
        
        for sectionIndex in 0..<coilSections.count
        {
            let nextSection = coilSections[sectionIndex]
            
            if (startNodes.contains(nextSection.data.nodes.inNode))
            {
                prevSection = nil
            }
            
            let currentSectionNumber = nextSection.data.serialNumber
            
            // start with the inductance matrix
            M[currentSectionNumber, currentSectionNumber] = nextSection.data.selfInductance
            
            for (section, mutInd) in nextSection.data.mutInd
            {
                // only add the mutual inductances once (the matrix is symmetric)
                if (section.data.serialNumber > currentSectionNumber)
                {
                    M[currentSectionNumber, section.data.serialNumber] = mutInd
                    // M[section.data.serialNumber, currentSectionNumber] = mutInd
                }
            }
            
            // Now we do the resistance matrix
            R[currentSectionNumber, currentSectionNumber] = nextSection.data.resistance
            
            // And the B matrix
            B[currentSectionNumber, nextSection.data.nodes.inNode] = 1.0
            B[currentSectionNumber, nextSection.data.nodes.outNode] = -1.0
            
            // We will adopt the ATP style of dividing the shunt capacitances in two for each section and applying it out of each node (and thus to each node) of the connected section.
            
            // We need to take care of the bottommost and topmost nodes of each coil
            var Cj = 0.0
            var sumKip = 0.0
            if (prevSection != nil)
            {
                Cj = prevSection!.data.seriesCapacitance
                
                for (section, shuntC) in prevSection!.data.shuntCaps
                {
                    sumKip += shuntC / 2.0
                    
                    // we don't include ground nodes in this part
                    if (section.data.sectionID != "GND")
                    {
                        Cbase[prevSection!.data.nodes.outNode, section.data.nodes.outNode] = -shuntC / 2.0
                    }
                }
                
                Cbase[nextSection.data.nodes.inNode, prevSection!.data.nodes.inNode] = -Cj
                
                A[nextSection.data.nodes.inNode, sectionIndex-1] = 1
            }
            
            let Cj1 = nextSection.data.seriesCapacitance
            
            for (section, shuntC) in nextSection.data.shuntCaps
            {
                sumKip += shuntC / 2.0
                
                if (section.data.sectionID != "GND")
                {
                    Cbase[nextSection.data.nodes.inNode, section.data.nodes.inNode] += -shuntC / 2.0
                }
            }
            
            Cbase[nextSection.data.nodes.inNode, nextSection.data.nodes.inNode] = Cj + Cj1 + sumKip
            
            /* taken care of above
            if (prevSection != nil)
            {
                Cbase[nextSection.data.nodes.inNode, prevSection!.data.nodes.inNode] = -Cj
            }
            */
            
            Cbase[nextSection.data.nodes.inNode, nextSection.data.nodes.outNode] = -Cj1
            
            /* taken care of above
            if (prevSection != nil)
            {
                A[nextSection.data.nodes.inNode, sectionIndex-1] = 1
            }
            */
            
            // DLog("Total Kip for this node: \(sumKip)")
            
            // take care of the final node
            if (endNodes.contains(nextSection.data.nodes.outNode))
            {
                sumKip = 0.0
                for (section, shuntC) in nextSection.data.shuntCaps
                {
                    sumKip += shuntC / 2.0
                    
                    if (section.data.sectionID != "GND")
                    {
                        // Cbase[nextSection.data.nodes.outNode, section.data.nodes.inNode] += -shuntC / 2.0
                        Cbase[nextSection.data.nodes.outNode, section.data.nodes.outNode] += -shuntC / 2.0
                    }
                }
                
                Cj = Cj1
                
                Cbase[nextSection.data.nodes.outNode, nextSection.data.nodes.outNode] = Cj + sumKip
                
                Cbase[nextSection.data.nodes.outNode, nextSection.data.nodes.inNode] = -Cj
                
                A[nextSection.data.nodes.outNode, sectionIndex] = 1
            }
            
            A[nextSection.data.nodes.inNode, sectionIndex] = -1
            
            prevSection = nextSection
        }
        
        
        
        //let test = PCH_Matrix(sourceMatrix: M, newMatrixType: PCH_Matrix.types.generalMatrix)?.Inverse()
        
        // DLog("C: \(Cbase)")
        // DLog("M: \(M)")
        // DLog("A: \(A)")
        // DLog("B: \(B)")
        // DLog("R: \(R)")
        
        // At this point, all the matrices are filled. All we need to do is adjust the C matrix to take into account the nodes that are either connected to ground or to our voltage source. Note that other circuit modifications can also be done, per section 13 of the Bluebook, 2E (see formulae 13.81 to 13.83). Also note that most modifications made here will cause an adjustment to be made in the AI matrix as well.
        
        let C = PCH_Matrix(sourceMatrix: Cbase)!
        
        // We set the grounded nodes so that dV/dt at that node is zero. To do that, we set the row of the node 'i' to all zeros, except entry [i,i], which we set to 1. We will then set the i-th row in the vector AI to 0 below. We also do the same thing for the "shot" node, except that its derivative will be calculated at each time step.
        
        var lvBottomRow = [Double](repeating: 0.0, count: C.numCols)
        lvBottomRow[lvNodeBase] = 1.0
        C.SetRow(lvNodeBase, buffer: lvBottomRow)
        
        var lvTopRow = [Double](repeating: 0.0, count: C.numCols)
        lvTopRow[lvCoilSections] = 1.0
        C.SetRow(lvCoilSections, buffer: lvTopRow)
        
        var hvBottomRow = [Double](repeating: 0.0, count: C.numCols)
        hvBottomRow[hvNodeBase] = 1.0
        C.SetRow(hvNodeBase, buffer: hvBottomRow)
        
        var hvTopRow = [Double](repeating: 0.0, count: C.numCols)
        hvTopRow[hvNodeBase + hvCoilSections] = 1.0
        C.SetRow(hvNodeBase + hvCoilSections, buffer: hvTopRow)
        
        // DLog("Adjusted C: \(C)")
        
        // For the shot terminal, we use the old standard formula, V0 * (e^(-at) - e^(-bt)). The constants are k1 = 14400 and k2 = 3E6
        // The derivative of this function with respect to t is: dV/dt = V0 * (be^(-bt) - ae^(-at)).
        let V0 = 550.0E3 * 1.03
        
        
        // All right, we now set the starting conditions for our Runge-Kutta implementation. This is quite simple because at time 0, everything is 0, and PCH_Matrix initializes all values to 0
        
        var I = PCH_Matrix(numVectorElements: coilSections.count, vectorPrecision: PCH_Matrix.precisions.doublePrecision)
        var V = PCH_Matrix(numVectorElements: hvNodeBase + hvCoilSections + 1, vectorPrecision: PCH_Matrix.precisions.doublePrecision)
        
        // Set the time step. For debugging, we're going somewhat coarse.
        let h = 10.0E-9
        // The overall time that the simulation will run
        let maxTime = -1.0
        // The current time
        var simTime = 0.0
        
        while simTime <= maxTime
        {
            let AI = (A * I)!
            
            // We will start with the solution of dV/dt to set the V vector. We're going to use a fourth-order Runge-Kutta algorithm (plenty of websites, see http://lpsa.swarthmore.edu/NumInt/NumIntFourth.html or http://www.myphysicslab.com/runge_kutta.html for details)
            
            // Get the derivative dV/dt at the current simulation time. Note that in this case, the derivative is not actually a function of V. Therefore, the only thing we do is calculate the derivative of teh "shot terminal" according to the voltage formula we're using (at current time, current time + h/2, and current time + h, as required by 4th order Runge-Kutta), and set all the grounded node derivatives to zero.
            
            AI[lvNodeBase, 0] = 0.0
            AI[lvCoilSections, 0] = 0.0
            AI[hvNodeBase, 0] = 0.0
            
            AI[hvNodeBase + hvCoilSections, 0] = derivativeOfBIL(V0, t:simTime)
            // DLog("AI: \(AI)")
            
            let an = C.SolveWith(AI)!
            // DLog("AI: \(AI)")
            
            AI[hvNodeBase + hvCoilSections, 0] = derivativeOfBIL(V0, t:simTime + h/2)
            // DLog("AI: \(AI)")
            let bn = C.SolveWith(AI)!
            let cn = bn
            // DLog("bn: \(bn)")
            
            AI[hvNodeBase + hvCoilSections, 0] = derivativeOfBIL(V0, t:simTime + h)
            let dn = C.SolveWith(AI)!
            // DLog("dn: \(dn)")
            
            let newV = V + h/6.0 * (an + 2.0 * bn + 2.0 * cn + dn)
            
            // DLog("Old V: \(V)")
            // DLog("New V: \(newV)")
            
            let BV = (B * newV)!
            let RI = (R * I)!
            
            var rtSide = BV - RI
            
            // The current derivative dI/dt _is_ a function of I, so this is a more "traditional" calculation using Runge-Kutta.
            let aan = M.SolveWith(rtSide)!
            
            var newI = I + (h/2.0 * aan)
            rtSide = BV - (R * newI)!
            let bbn = M.SolveWith(rtSide)!
            
            newI = I + (h/2.0 * bbn)
            rtSide = BV - (R * newI)!
            let ccn = M.SolveWith(rtSide)!
            
            newI = I + (h * ccn)
            rtSide = BV - (R * newI)!
            let ddn = M.SolveWith(rtSide)!
            
            newI = I + h/6.0 * (aan + 2.0 * bbn + 2.0 * ccn + ddn)
            
            I = newI
            V = newV
            simTime += h
        }
        
        DLog("V: \(V)")
        DLog("I: \(I)")
        */
        
        // NSApplication.sharedApplication().terminate(self)

        // inductance check (debugging)
        // We have confirmed that the self-inductances are correct when comparing the value calculated with each coil as a whole with the value calculated from the individual disk self- and mutual-inductances. We now check the leakage inductance between the coils (from the HV point of view).
        /*
        var L = [Double]()
        var sumL = 0.0
        var M = [Double]()
        var sumM = 0.0
        let turnsRatio = 3200.0 / 16.0
        var lvHVMuts = [Double]()
        
        for var i=0; i<coilSections.count; i++
        {
            let nextSection = coilSections[i]
            
            L.append(nextSection.data.selfInductance)
            
            let sID = nextSection.data.sectionID
            
            var useTurnsRatio = 1.0
            if (sID.substringWithRange(Range<String.Index>(start:sID.startIndex, end:sID.startIndex.advancedBy(2))) != "HV")
            {
                useTurnsRatio = turnsRatio
            }
            
            sumL += useTurnsRatio * useTurnsRatio * nextSection.data.selfInductance
            
            for nextMutInd in nextSection.data.mutualInductances
            {
                let key = nextMutInd.0
                
                var useMratio = useTurnsRatio
                
                if (key.substringWithRange(Range<String.Index>(start:key.startIndex, end: key.startIndex.advancedBy(2))) != sID.substringWithRange(Range<String.Index>(start:sID.startIndex, end:sID.startIndex.advancedBy(2))))
                {
                    useMratio = -turnsRatio
                    M.append(nextMutInd.1)
                    sumM += useMratio * nextMutInd.1
                }
                else
                {
                    // The LV coil self-inductance includes the LV disk-disk mutual inductances in its calculation, so their mutual inductances must also be multiplied by the square of the turns ratio
                    useMratio *= useMratio
                    lvHVMuts.append(nextMutInd.1)
                    L.append(nextMutInd.1)
                    sumL += useMratio * nextMutInd.1
                }
            }
            
        }
        
        var testL = 0.0
        for nextValue in lvHVMuts
        {
            testL += nextValue
        }
        for nextValue in L
        {
            testL += nextValue
        }
        
        DLog("LV self-inductance: \(gsl_pow_2(3200.0 / 16.0) * L1)")
        DLog("HV self-inductance: \(L2)")
        DLog("Sum of self inductances: \(L2 + gsl_pow_2(3200.0 / 16.0) * L1)")
        DLog("LV-HV Mutual Inductance: \(3200.0 / 16.0 * M12)")
        
        DLog("Leakage Inductance: \(lkInd)")
        DLog("SumL: \(sumL); SumM: \(sumM); Lcalc: \(sumL + sumM)")
        DLog("Diff: \(lkInd - (sumM + sumL))")
        
        */
        
        // return
        
        /*
        var lvRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, (2.25 + 1.913/2.0) * 25.4/1000.0, 0.296 * 25.4/1000.0, 32.065 / 2.0 * 25.4/1000)
        let lv1 = PCH_DiskSection(diskRect: lvRect, N: 8.0, J: 481.125 * 8.0 / Double(lvRect.size.width * lvRect.size.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData:PCH_SectionData(sectionID: "LV001"))
        lvRect = lvRect.offsetBy(dx: 0.0, dy: 32.065 / 2.0 * 25.4 / 1000.0)
        let lv2 = PCH_DiskSection(diskRect: lvRect, N: 8.0, J: 481.125 * 8.0 / Double(lvRect.size.width * lvRect.size.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData:PCH_SectionData(sectionID: "LV002"))
        
        var hvRect = NSMakeRect(25.411 / 2.0 * 25.4/1000.0, 2.75 * 25.4/1000.0, 5.148 * 25.4/1000.0, 32.495 / 2.0 * 25.4/1000.0)
        let hv1 = PCH_DiskSection(diskRect: hvRect, N: 1600.0, J: 1600 * 2.406 / Double(hvRect.size.width * hvRect.size.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData:PCH_SectionData(sectionID: "HV001"))
        hvRect = hvRect.offsetBy(dx: 0.0, dy: 32.495 / 2.0 * 25.4/1000.0)
        let hv2 = PCH_DiskSection(diskRect: hvRect, N: 1600.0, J: 1600 * 2.406 / Double(hvRect.size.width * hvRect.size.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData:PCH_SectionData(sectionID: "HV002"))
        
        let resFactor = 3000.0
        
        lv1.data.resistance = 1.3909E-3 * 8.0 * resFactor
        lv1.data.selfInductance = lv1.SelfInductance()
        lv1.data.seriesCapacitance = 1.8072E-10 / 8.0
        lv1.data.shuntCapacitances["0"] = (3.9534E-11 + 3.2097E-11) * 8.0
        
        lv2.data.resistance = 1.3909E-3 * 8.0 * resFactor
        lv2.data.selfInductance = lv2.SelfInductance()
        lv2.data.seriesCapacitance = 1.8072E-10 / 8.0
        lv2.data.shuntCapacitances["0"] = (3.9534E-11 + 3.2097E-11) * 8.0
        
        hv1.data.resistance = 0.19727 * 30.0 * resFactor
        hv1.data.selfInductance = hv1.SelfInductance()
        hv1.data.seriesCapacitance = 1.6185E-9 / 30.0
        hv1.data.shuntCapacitances["0"] = (6.5814E-12 + 1.0259E-22) * 30.0
        
        hv2.data.resistance = 0.19727 * 30.0 * resFactor
        hv2.data.selfInductance = hv2.SelfInductance()
        hv2.data.seriesCapacitance = 1.6185E-9 / 30.0
        hv2.data.shuntCapacitances["0"] = (6.5814E-12 + 1.0259E-22) * 30.0
        
        lv1.data.mutualInductances[lv2.data.sectionID] = lv1.MutualInductanceTo(lv2)
        lv1.data.mutIndCoeff[lv2.data.sectionID] = lv1.data.mutualInductances[lv2.data.sectionID]! / sqrt(lv1.data.selfInductance * lv2.data.selfInductance)
        
        lv1.data.mutualInductances[hv1.data.sectionID] = lv1.MutualInductanceTo(hv1)
        lv1.data.mutIndCoeff[hv1.data.sectionID] = lv1.data.mutualInductances[hv1.data.sectionID]! / sqrt(lv1.data.selfInductance * hv1.data.selfInductance)
        
        lv1.data.mutualInductances[hv2.data.sectionID] = lv1.MutualInductanceTo(hv2)
        lv1.data.mutIndCoeff[hv2.data.sectionID] = lv1.data.mutualInductances[hv2.data.sectionID]! / sqrt(lv1.data.selfInductance * hv2.data.selfInductance)
        
        lv2.data.mutualInductances[hv1.data.sectionID] = lv2.MutualInductanceTo(hv1)
        lv2.data.mutIndCoeff[hv1.data.sectionID] = lv2.data.mutualInductances[hv1.data.sectionID]! / sqrt(lv2.data.selfInductance * hv1.data.selfInductance)
        
        lv2.data.mutualInductances[hv2.data.sectionID] = lv2.MutualInductanceTo(hv2)
        lv2.data.mutIndCoeff[hv2.data.sectionID] = lv2.data.mutualInductances[hv2.data.sectionID]! / sqrt(lv2.data.selfInductance * hv2.data.selfInductance)
        
        hv1.data.mutualInductances[hv2.data.sectionID] = hv1.MutualInductanceTo(hv2)
        hv1.data.mutIndCoeff[hv2.data.sectionID] = hv1.data.mutualInductances[hv2.data.sectionID]! / sqrt(hv1.data.selfInductance * hv2.data.selfInductance)
        
        let coilSections = [lv1,lv2,hv1,hv2]
*/
        // SPICE-FILE STUFF FROM HERE ON
        
        var fString = "Job 2201 - HV Shot in tap position 1 (highest voltage)\n"
        var mutSerNum = 1
        var dSections = [String]()
        
        cArray = [PCH_DiskSection]()
        for nextSections in coils
        {
            cArray.append(contentsOf: nextSections)
        }
        
        for nextDisk in cArray
        {
            // Separate the disk ID into the coil name and the disk number
            let nextSectionID = nextDisk.data.sectionID
            dSections.append(nextSectionID)
            
            let coilName = PCH_StrLeft(nextSectionID, length: 2)
            
            // Next line was broken by Swift 3, but for something a lot less ugly
            // let diskNum = nextSectionID[nextSectionID.indices.suffix(from: nextSectionID.characters.index(nextSectionID.startIndex, offsetBy: 2))]
            
            // Swift 3 rewrite (untested)
            // let dNumIndex = nextSectionID.index(nextSectionID.startIndex, offsetBy: 2)
            // let diskNum = nextSectionID.substring(from: dNumIndex)
            let diskNum = PCH_StrRight(nextSectionID, length: 3)
            
            let nextDiskNum = String(format: "%03d", Int(diskNum)! + 1)
            
            let inNode = coilName + "I" + diskNum
            let outNode = coilName + "I" + nextDiskNum
            let midNode = coilName + "M" + diskNum
            let resName = "R" + nextSectionID
            let selfIndName = "L" + nextSectionID
            let indParResName = "RPL" + nextSectionID
            let seriesCapName = "CS" + nextSectionID
            
            fString += String(format: "* Definitions for section: %@\n", nextSectionID)
            fString += selfIndName + " " + inNode + " " + midNode + String(format: " %.4E\n", nextDisk.data.selfInductance)
            // Calculate the resistance that we need to put in parallel with the inductance to reducing ringing (according to ATPDraw: ind * 2.0 * 7.5 * 1000.0 / 1E9). Note that the model still rings in LTSpice, regardless of how low I set this value.
            fString += indParResName + " " + inNode + " " + midNode + String(format: " %.4E\n", nextDisk.data.selfInductance * 2.0 * 7.5 * 100.0 / 1.0E-9)

            fString += resName + " " + midNode + " " + outNode + String(format: " %.4E\n", nextDisk.data.resistance)
            fString += seriesCapName + " " + inNode + " " + outNode + String(format: " %.4E\n", nextDisk.data.seriesCapacitance)
            
            var shuntCapSerialNum = 1
            for nextShuntCap in nextDisk.data.shuntCaps
            {
                // We ignore inner coils because they've already been done (note that we need to consider the core, though)
                if ((nextShuntCap.key.coilRef < nextDisk.coilRef) && (nextShuntCap.key.coilRef != -1))
                {
                    continue
                }
                
                let nsName = String(format: "CP%@%03d", nextSectionID, shuntCapSerialNum)
                
                /*
                let shuntID = nextShuntCap.0
                
                // make sure that this capacitance is not already done
                if dSections.contains(shuntID)
                {
                    continue
                }
                 */
                
                var shuntNode = String()
                if (nextShuntCap.key.coilRef == -1)
                {
                    shuntNode = "0"
                }
                else
                {
                    shuntNode = identification[nextShuntCap.key.coilRef]
                    shuntNode += "I"
                    let nodeNum = PCH_StrRight(nextShuntCap.key.data.sectionID, length: 3)
                    shuntNode += nodeNum
                }
                
                fString += nsName + " " + inNode + " " + shuntNode + String(format: " %.4E\n", nextShuntCap.value)
                
                shuntCapSerialNum += 1
            }
            
            for nextMutualInd in nextDisk.data.mutIndCoeff
            {
                let miName = String(format: "K%05d", mutSerNum)
                
                let miID = nextMutualInd.0
                
                if (dSections.contains(miID))
                {
                    continue
                }
                
                fString += miName + " " + selfIndName + " L" + miID + String(format: " %.4E\n", nextMutualInd.1)
                
                mutSerNum += 1
            }
        }
        
        // We connect the coil ends and centers to their nodes using very small resistances
        fString += "\n* Coil ends and centers\n"
        for i in 0..<numCoils
        {
            let nextID = identification[i]
            
            fString += "R" + nextID + "BOT " + nextID + "BOT " + nextID + "I001 1.0E-9\n"
            fString += "R" + nextID + "CEN " + nextID + "CEN " + nextID + String(format: "I%03d 1.0E-9\n", coils[i].count / 2 + 1)
            fString += "R" + nextID + "TOP " + nextID + "TOP " + nextID + String(format: "I%03d 1.0E-9\n", coils[i].count + 1)
        }
        
        
        // TODO: Add code for the connection that interests us
        fString += "\n* Connections\n\n"
        
        // The shot
        fString += "* Impulse shot\nVBIL HVTOP 0 EXP(0 555k 0 2.2E-7 1.0E-6 7.0E-5)\n\n"
        
        // Options required to make this work most of the time
        fString += "* options for LTSpice\n.OPTIONS reltol=0.02 trtol=7 abstol=1e-6 vntol=1e-4 method=gear\n\n"
        
        fString += ".TRAN 1.0ns 100us\n\n.END"
        
        self.saveFileWithString(fString)
        
        // End of main function
    }
    
    func derivativeOfBIL(_ V:Double, t:Double) -> Double
    {
        let k1 = 14285.0
        let k2 = 3.333333E6
        
        return V * (k2 * exp(-k2 * t) - k1 * exp(-k1 * t))
        
    }
    
    func saveFileWithString(_ fileString:String)
    {
        let saveFilePanel = NSSavePanel()
        
        saveFilePanel.title = "Save Spice data"
        saveFilePanel.canCreateDirectories = true
        saveFilePanel.allowedFileTypes = ["cir", "txt"]
        saveFilePanel.allowsOtherFileTypes = false
        
        if (saveFilePanel.runModal() == NSFileHandlingPanelOKButton)
        {
            guard let newFileURL = saveFilePanel.url
                else
            {
                DLog("Bad file name")
                return
            }
            
            do {
                try fileString.write(to: newFileURL, atomically: true, encoding: String.Encoding.utf8)
            }
            catch {
                ALog("Could not write file!")
            }
            
            DLog("Finished writing file")
        }
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

