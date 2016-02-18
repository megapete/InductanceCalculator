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


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
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

        
        var lvRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, (2.25 + 1.913/2.0) * 25.4/1000.0, 0.296 * 25.4/1000.0, 32.065 * 25.4/1000)
        let lv = PCH_DiskSection(diskRect: lvRect, N: 16.0, J: 481.125 * 16.0 / Double(lvRect.size.width * lvRect.size.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData:PCH_SectionData(sectionID: "LV", serNum:0, inNode:0, outNode:1))
        var hvRect = NSMakeRect(25.411 / 2.0 * 25.4/1000.0, 2.75 * 25.4/1000.0, 5.148 * 25.4/1000.0, 32.495 * 25.4/1000)
        let hv = PCH_DiskSection(diskRect: hvRect, N: 3200.0, J: 3200.0 * 2.406 / Double(hvRect.size.width * hvRect.size.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData:PCH_SectionData(sectionID: "HV", serNum:1, inNode:2, outNode:3))
        
        let L1 = lv.SelfInductance()
        let L2 = hv.SelfInductance()
        let M12 = lv.MutualInductanceTo(hv)
        
        let lkInd = L2 + gsl_pow_2(3200.0 / 16.0) * L1 - 2.0 * (3200.0 / 16.0) * M12
        // var magEnergy = lkInd * 481.125 * 481.125 / 2.0
        
        
        DLog("Leakage reactance (ohms): \(lkInd * 2.0 * π * 60.0)")
        
        
        // Create the special "ground" section. By convention, it has a serial number of -1.
        let gndSection = PCH_DiskSection(diskRect: NSMakeRect(0, 0, 0, 0), N: 0, J: 0, windHt: 0, coreRadius: 0, secData: PCH_SectionData(sectionID: "GND", serNum: -1, inNode:-1, outNode:-1))
        
        // Now we try again but split each coil into sections. 
        let lvCoilSections = 4
        let hvCoilSections = 4
        
        var coilSections = [PCH_DiskSection]()
        
        // Overly simplistic way to take care of eddy losses at higher frequencies (the 3000 comes from the Bluebook)
        let resFactor = 3000.0
        
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
        
        var sectionSerialNumber = 0
        var nodeSerialNumber = 0
        
        for var i=0; i<lvCoilSections; i++
        {
            let nextSectionRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, CGFloat(lvZ), 0.296 * 25.4/1000.0, CGFloat(lvZStep))
            
            var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", lvcoilID, i+1), serNum:sectionSerialNumber, inNode:nodeSerialNumber, outNode:nodeSerialNumber+1)
            
            sectionSerialNumber++
            nodeSerialNumber++
            
            nextSectionData.resistance = lvResPerSection
            nextSectionData.seriesCapacitance = lvSerCapPerSection
            nextSectionData.shuntCapacitances["0"] = lvShuntCapPerSection
            
            let nextSection = PCH_DiskSection(diskRect: nextSectionRect, N: lvN, J: lvN * lvI / Double(nextSectionRect.width * nextSectionRect.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData: nextSectionData)
            
            nextSection.data.selfInductance = nextSection.SelfInductance()
            
            coilSections.append(nextSection)
            lvSectionArray.append(nextSection)
            
            lvZ += lvZStep
        }
        
        nodeSerialNumber++
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
        for var i=0; i<hvCoilSections; i++
        {
            let nextSectionRect = NSMakeRect(25.411 / 2.0 * 25.4/1000.0, CGFloat(hvZ), 5.148 * 25.4/1000.0, CGFloat(hvZStep))
            
            var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", hvcoilID, i+1), serNum:sectionSerialNumber, inNode:nodeSerialNumber, outNode:nodeSerialNumber+1)
            sectionSerialNumber++
            nodeSerialNumber++
            
            nextSectionData.resistance = hvResPerSection
            nextSectionData.seriesCapacitance = hvSerCapPerSection
            nextSectionData.shuntCapacitances["0"] = hvShuntCapPerSection
            
            let nextSection = PCH_DiskSection(diskRect: nextSectionRect, N: hvN, J: hvN * hvI / Double(nextSectionRect.width * nextSectionRect.height), windHt: 1.1, coreRadius: 0.282 / 2.0, secData: nextSectionData)
            
            nextSection.data.selfInductance = nextSection.SelfInductance()
            
            coilSections.append(nextSection)
            hvSectionArray.append(nextSection)
            
            hvZ += hvZStep
        }
        
        
        
        var cArray = coilSections
        
        DLog("Calculating mutual inductances")
        while cArray.count > 0
        {
            let nDisk = cArray.removeAtIndex(0)
            
            for otherDisk in cArray
            {
                let mutInd = fabs(nDisk.MutualInductanceTo(otherDisk))
                
                let mutIndCoeff = mutInd / sqrt(nDisk.data.selfInductance * otherDisk.data.selfInductance)
                if (mutIndCoeff < 0.0 || mutIndCoeff > 1.0)
                {
                    DLog("Fuck, fuck, fuck!")
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
            
            if (prevSection != nil)
            {
                Cbase[nextSection.data.nodes.inNode, prevSection!.data.nodes.inNode] = -Cj
            }
            
            Cbase[nextSection.data.nodes.inNode, nextSection.data.nodes.outNode] = -Cj1
            
            if (prevSection != nil)
            {
                A[nextSection.data.nodes.inNode, sectionIndex-1] = 1
            }
            
            if (endNodes.contains(nextSection.data.nodes.outNode))
            {
                A[nextSection.data.nodes.outNode, sectionIndex] = 1
            }
            
            A[nextSection.data.nodes.inNode, sectionIndex] = -1
            
        
            
            prevSection = nextSection
        }
        
        // DLog("C: \(Cbase)")
        // DLog("M: \(M)")
        // DLog("A: \(A)")
        // DLog("B: \(B)")
        // DLog("R: \(R)")
        
        // At this point, all the matrices are filled. All we need to do is adjust the C matrix to take into account the nodes that are either connected to ground or to our voltage source. Note that other circuit modifications can also be done, per section 13 of the Bluebook, 2E (see formulae 13.81 to 13.83). Also note that most modifications made here will cause an adjustment to be made in the AI matrix as well.
        
        let C = PCH_Matrix(sourceMatrix: Cbase)!
        
        // We set the grounded nodes so that dV/dt at that node is zero. To do that, we set the row of the node 'i' to all zeros, except entry [i,i], which we set to 1. We will then set the i-th row in the vector AI to 0 below. We also do the same thing for the "shot" node, except that its derivative will be calculated at each time step.
        
        var lvBottomRow = [Double](count: C.numCols, repeatedValue: 0.0)
        lvBottomRow[lvNodeBase] = 1.0
        C.SetRow(lvNodeBase, buffer: lvBottomRow)
        
        var lvTopRow = [Double](count: C.numCols, repeatedValue: 0.0)
        lvTopRow[lvCoilSections] = 1.0
        C.SetRow(lvCoilSections, buffer: lvTopRow)
        
        var hvBottomRow = [Double](count: C.numCols, repeatedValue: 0.0)
        hvBottomRow[hvNodeBase] = 1.0
        C.SetRow(hvNodeBase, buffer: hvBottomRow)
        
        var hvTopRow = [Double](count: C.numCols, repeatedValue: 0.0)
        hvTopRow[hvNodeBase + hvCoilSections] = 1.0
        C.SetRow(hvNodeBase + hvCoilSections, buffer: hvTopRow)
        
        DLog("Adjusted C: \(C)")
        
        // For the shot terminal, we use the old standard formula, V0 * (e^(-at) - e^(-bt)). The constants are k1 = 14400 and k2 = 3E6
        // The derivative of this function with respect to t is: dV/dt = V0 * (be^(-bt) - ae^(-at))
        let V0 = 550.0 * 1.03
        
        
        // All right, we now set the starting conditions for our Runge-Kutta implementation. This is quite simple because at time 0, everything is 0, and PCH_Matrix initializes all values to 0
        
        var I = PCH_Matrix(numVectorElements: coilSections.count, vectorPrecision: PCH_Matrix.precisions.doublePrecision)
        var V = PCH_Matrix(numVectorElements: hvNodeBase + hvCoilSections + 1, vectorPrecision: PCH_Matrix.precisions.doublePrecision)
        
        // Set the time step. For debugging, we're going somewhat coarse.
        let h = 10.0E-9
        // The overall time that the simulation will run
        let maxTime = 1.2E-6
        // The current time
        var simTime = 0.0
        
        while simTime <= maxTime
        {
            // Set the right-size vectors:
            // var BV = B * V
            // var RI = R * I
            var AI = (A * I)!
            
            // We will start with the solution of dV/dt to set the V vector. We're going to use a fourth-order Runge-Kutta algorithm (plenty of websites, see http://lpsa.swarthmore.edu/NumInt/NumIntFourth.html or http://www.myphysicslab.com/runge_kutta.html for details)
            // first solution
            // fix AI
            AI[lvNodeBase, 0] = 0.0
            AI[lvCoilSections, 0] = 0.0
            AI[hvNodeBase, 0] = 0.0
            
            // get the derivative at the current simulation time
            AI[hvNodeBase + hvCoilSections, 0] = derivativeOfBIL(V0, t:simTime)
            DLog("AI: \(AI)")
            
            let an = C.SolveWith(AI)!
            DLog("an: \(an)")
            
            AI[hvNodeBase + hvCoilSections, 0] = derivativeOfBIL(V0, t:simTime + h/2)
            DLog("AI: \(AI)")
            let bn = C.SolveWith(AI)!
            let cn = bn
            DLog("bn: \(bn)")
            
            AI[hvNodeBase + hvCoilSections, 0] = derivativeOfBIL(V0, t:simTime + h)
            let dn = C.SolveWith(AI)!
            DLog("dn: \(dn)")
            
            let newV = V + h/6.0 * (an + 2.0 * bn + 2.0 * cn + dn)
            
            DLog("Old V: \(V)")
            DLog("New V: \(newV)")
            
            var BV = (B * newV)!
            var RI = (R * I)!
            
            var rtSide = BV - RI
            
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
            
            DLog("Old V: \(V)")
            DLog("New V: \(newV)")
            
            DLog("Old I: \(I)")
            DLog("New I: \(newI)")
            
            I = newI
            V = newV
            simTime += h
        }
        
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
        
        NSApplication.sharedApplication().terminate(self)
        return
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
        /* SPICE-FILE STUFF FROM HERE ONE
        
        var fString = String()
        var mutSerNum = 1
        var dSections = [String]()
        
        cArray = coilSections
        
        for nextDisk in cArray
        {
            // Separate the disk ID into the coil name and the disk number
            let nextSectionID = nextDisk.data.sectionID
            dSections.append(nextSectionID)
            
            let coilName = nextSectionID[nextSectionID.startIndex.advancedBy(0)...nextSectionID.startIndex.advancedBy(1)]
            let diskNum = nextSectionID[nextSectionID.startIndex.advancedBy(2)..<nextSectionID.endIndex]
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
            // Calculate the resistance that we need to put in parallel with the inductance to prevent ringing (according to ATPDraw)
            fString += indParResName + " " + inNode + " " + midNode + String(format: " %.4E\n", nextDisk.data.selfInductance * 2.0 * 7.5 * 1000.0 / 1.0E-9)

            fString += resName + " " + midNode + " " + outNode + String(format: " %.4E\n", nextDisk.data.resistance)
            fString += seriesCapName + " " + inNode + " " + outNode + String(format: " %.4E\n", nextDisk.data.seriesCapacitance)
            
            var shuntCapSerialNum = 0
            for nextShuntCap in nextDisk.data.shuntCapacitances
            {
                let nsName = String(format: "CP%@%03d", nextSectionID, shuntCapSerialNum)
                
                let shuntID = nextShuntCap.0
                
                // make sure that this capacitance is not already done
                if dSections.contains(shuntID)
                {
                    continue
                }
                
                var shuntNode = String()
                if (shuntID == "0")
                {
                    shuntNode = "0"
                }
                else
                {
                    shuntNode = shuntID[shuntID.startIndex.advancedBy(0)...shuntID.startIndex.advancedBy(1)]
                    shuntNode += "I"
                    shuntNode += shuntID[shuntID.startIndex.advancedBy(2)...shuntID.endIndex]
                }
                
                fString += nsName + " " + inNode + " " + shuntNode + String(format: " %.4E\n", nextShuntCap.1)
                
                shuntCapSerialNum++
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
                
                mutSerNum++
            }
        }
        
        // We connect the coil ends to their nodes
        let hID = "HV"
        let lID = "LV"
        fString += "* Coil ends\n"
        fString += "R" + hID + "TOP " + hID + "TOP " + hID + "I001 1.0E-9\n"
        fString += "R" + lID + "TOP " + lID + "TOP " + lID + "I001 1.0E-9\n"
        
        fString += "R" + hID + "BOT " + hID + "BOT " + hID + String(format: "I%03d 1.0E-9\n", hvCoilSections + 1)
        fString += "R" + lID + "BOT " + lID + "BOT " + lID + String(format: "I%03d 1.0E-9\n", lvCoilSections + 1)
        
        self.saveFileWithString(fString)
        
        return
        
        

        // Interesting stuff starts here
        // Create the special section for ground. In SPICE, this always has the ID of '0'
        let ground = PCH_SectionData(sectionID: "0")
        
        // Job016 HV data
        let hv_capFirstDisk = 1.4923E-9
        let hv_capOtherDisks = 1.6185E-9
        let hv_capToShield = 6.5814E-12
        let hv_capToTank = 1.0259E-22
        let hv_resPerDisk = 0.19727 * resFactor
        let hv_numDisks = 60.0
        let hv_turnsPerDisk = 3200.0 / hv_numDisks
        // start at the top disk (the one that will be shot)
        var hv_diskRect = NSMakeRect(25.411 / 2.0 * 25.4/1000.0, (2.75 + 32.495 - 0.3488) * 25.4/1000.0, 5.148 * 25.4/1000.0, 0.3488 * 25.4/1000.00)
        let hv_diskPitch = (32.495 - 0.3488) * 25.4/1000.0 / 59.0
        let hv_J = 2.4056 * hv_turnsPerDisk / Double(hv_diskRect.size.width * hv_diskRect.size.height)
        let hv_ID = "HV"
        
        // Job016 core data
        let windowHt = 1.1
        let coreRadius = 0.141
        
        var hvCoil = [PCH_DiskSection]()
        
        DLog("Creating hv disk coil")
        for i in 1...Int(hv_numDisks)
        {
            var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", hv_ID, i))
            nextSectionData.resistance = hv_resPerDisk
            nextSectionData.seriesCapacitance = (i==1 ? hv_capFirstDisk : hv_capOtherDisks)
            nextSectionData.shuntCapacitances["0"] = hv_capToShield + hv_capToTank
            
            hvCoil.append(PCH_DiskSection(diskRect: hv_diskRect, N: hv_turnsPerDisk, J: hv_J, windHt: windowHt, coreRadius: coreRadius, secData: nextSectionData))
            hv_diskRect = hv_diskRect.offsetBy(dx: 0.0, dy:CGFloat(-hv_diskPitch))
        }
        
        hvCoil = hvCoil.reverse()
        
        // Job016 LV data
        let lv_capFirstDisk = 1.4734E-10
        let lv_capOtherDisks = 1.8072E-10
        let lv_capToShield = 3.9534E-11
        let lv_capToCore = 3.2097E-11
        let lv_resPerDisk = 1.3909E-3 * resFactor
        let lv_numDisks = 16.0
        let lv_turnsPerDisk = 1.0
        // start at the top disk (the one that will be shot)
        var lv_diskRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, (3.921 + 32.065) * 25.4/1000.0, 0.296 * 25.4/1000.0, 1.913 * 25.4/1000.00)
        let lv_diskPitch = (32.065 * 25.4/1000.0 / 16)
        let lv_J = 481.13 * lv_turnsPerDisk / Double(lv_diskRect.size.width * lv_diskRect.size.height)
        let lv_ID = "LV"
        
        var lvCoil = [PCH_DiskSection]()
        
        DLog("Creating lv disk coil")
        for i in 1...Int(lv_numDisks)
        {
            var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", lv_ID, i))
            nextSectionData.resistance = lv_resPerDisk
            nextSectionData.seriesCapacitance = (i==1 ? lv_capFirstDisk : lv_capOtherDisks)
            nextSectionData.shuntCapacitances["0"] = lv_capToShield + lv_capToCore
            
            lvCoil.append(PCH_DiskSection(diskRect: lv_diskRect, N: lv_turnsPerDisk, J: lv_J, windHt: windowHt, coreRadius: coreRadius, secData: nextSectionData))
            lv_diskRect = lv_diskRect.offsetBy(dx: 0.0, dy:CGFloat(-lv_diskPitch))
        }
        
        lvCoil = lvCoil.reverse()
        
        // At this point, our two arrays hold all the disks from the two windings. Now we need to calculate self- and mutual-inductances. We start by combining the arrays into one big one
        var coilArray = lvCoil + hvCoil
        
        DLog("Calculating self inductances")
        for nextDisk in coilArray
        {
            nextDisk.data.selfInductance = nextDisk.SelfInductance()
        }
        
        DLog("Calculating mutual inductances")
        while coilArray.count > 0
        {
            let nDisk = coilArray.removeAtIndex(0)
            
            for otherDisk in coilArray
            {
                let mutInd = fabs(nDisk.MutualInductanceTo(otherDisk))
                
                let mutIndCoeff = mutInd / sqrt(nDisk.data.selfInductance * otherDisk.data.selfInductance)
                if (mutIndCoeff < 0.0 || mutIndCoeff > 1.0)
                {
                    DLog("Fuck, fuck, fuck!")
                }
                
                nDisk.data.mutualInductances[otherDisk.data.sectionID] = mutInd
                otherDisk.data.mutualInductances[nDisk.data.sectionID] = mutInd
                
                nDisk.data.mutIndCoeff[otherDisk.data.sectionID] = mutIndCoeff
                otherDisk.data.mutIndCoeff[nDisk.data.sectionID] = mutIndCoeff
                
            }
        }
        
        
        // We now have all the electrical data calculated and stored for our disks. We can finally create the SPICE input file. The node numbering and component numbering is as follows, where for a section ID of XXYYY:
        //  Input node: XXIYYY (Output Node: XXI(YYY+1)
        //  Middle mdoe: XXMYYY
        //  Resistance: RXXYYY
        //  Self-inductance: LXXYYY
        //  Series capacitance: CSXXYYY
        //  Shunt capacitances: CPXXYYYNNN (where NNN is a serial number from 0 to 999)
        //  Mutual-inductance: KNNNNN (where NNNNN is a serial number from 0 to 99999)
        
        //  Special nodes are connected to the top and bottom leads using a low-value resistor as follows:
        //  RXXTOP XXTOP XXI001 1.0E-9
        //  RXXBOT XXBOT XXIZZZ 1.0E-9 (where ZZZ is the bottommost disk + 1)
        
        // We need an array to keep track of which elements we've already written to the file (to avoid multiple instances of identical mutual inductances and shunt capacitances)
        var doneSections = [String]()
        
        // The string that will be used to create the SPICE input file
        var fileString = String()
        
        // The mutual inductance serial number
        var mutIndSerialNum = 1
        
        DLog("Creating file string")
        coilArray = lvCoil + hvCoil
        for nextDisk in coilArray
        {
            // Separate the disk ID into the coil name and the disk number
            let nextSectionID = nextDisk.data.sectionID
            doneSections.append(nextSectionID)
            
            let coilName = nextSectionID[nextSectionID.startIndex.advancedBy(0)...nextSectionID.startIndex.advancedBy(1)]
            let diskNum = nextSectionID[nextSectionID.startIndex.advancedBy(2)..<nextSectionID.endIndex]
            let nextDiskNum = String(format: "%03d", Int(diskNum)! + 1)
            
            let inNode = coilName + "I" + diskNum
            let outNode = coilName + "I" + nextDiskNum
            let midNode = coilName + "M" + diskNum
            let resName = "R" + nextSectionID
            let selfIndName = "L" + nextSectionID
            let indParResName = "RPL" + nextSectionID
            let seriesCapName = "CS" + nextSectionID
            
            fileString += String(format: "* Definitions for disk: %@\n", nextSectionID)
            fileString += selfIndName + " " + inNode + " " + midNode + String(format: " %.4E\n", nextDisk.data.selfInductance)
            // Calculate the resistance that we need to put in parallel with the inductance to prevent ringing (according to ATPDraw)
            fileString += indParResName + " " + inNode + " " + midNode + String(format: " %.4E\n", nextDisk.data.selfInductance * 2.0 * 7.5 / 1.0E-9)
            fileString += resName + " " + midNode + " " + outNode + String(format: " %.4E\n", nextDisk.data.resistance)
            fileString += seriesCapName + " " + inNode + " " + outNode + String(format: " %.4E\n", nextDisk.data.seriesCapacitance)
            
            var shuntCapSerialNum = 0
            for nextShuntCap in nextDisk.data.shuntCapacitances
            {
                let nsName = String(format: "CP%@%03d", nextSectionID, shuntCapSerialNum)
                
                let shuntID = nextShuntCap.0
                
                // make sure that this capacitance is not already done
                if doneSections.contains(shuntID)
                {
                    continue
                }
            
                var shuntNode = String()
                if (shuntID == "0")
                {
                    shuntNode = "0"
                }
                else
                {
                    shuntNode = shuntID[shuntID.startIndex.advancedBy(0)...shuntID.startIndex.advancedBy(1)]
                    shuntNode += "I"
                    shuntNode += shuntID[shuntID.startIndex.advancedBy(2)...shuntID.endIndex]
                }
                
                fileString += nsName + " " + inNode + " " + shuntNode + String(format: " %.4E\n", nextShuntCap.1)
                
                shuntCapSerialNum++
            }
            
            for nextMutualInd in nextDisk.data.mutIndCoeff
            {
                let miName = String(format: "K%05d", mutIndSerialNum)
                
                let miID = nextMutualInd.0
                
                if (doneSections.contains(miID))
                {
                    continue
                }
                
                fileString += miName + " " + selfIndName + " L" + miID + String(format: " %.4E\n", nextMutualInd.1)
                
                mutIndSerialNum++
            }
        }
        
        // We connect the coil ends to their nodes
        fileString += "* Coil ends\n"
        fileString += "R" + hv_ID + "TOP " + hv_ID + "TOP " + hv_ID + "I001 1.0E-9\n"
        fileString += "R" + lv_ID + "TOP " + lv_ID + "TOP " + lv_ID + "I001 1.0E-9\n"
        
        fileString += "R" + hv_ID + "BOT " + hv_ID + "BOT " + hv_ID + String(format: "I%03d 1.0E-9\n", hvCoil.count + 1)
        fileString += "R" + lv_ID + "BOT " + lv_ID + "BOT " + lv_ID + String(format: "I%03d 1.0E-9\n", lvCoil.count + 1)
        
        self.saveFileWithString(fileString)
        /*
        NSString *documentsDirectory;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            documentsDirectory = [paths objectAtIndex:0];
        }
*/
        /*
        DLog("Creating file")
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        ZAssert(paths.count > 0, message: "Could not find Documents directory!")
        
        let filename = paths[0] + "/J016_Spicefile.cir"
        
        do {
            try fileString.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {
            ALog("Could not write file!")
        }

        DLog("Finished writing file")
*/*/
    }
    
    func derivativeOfBIL(V:Double, t:Double) -> Double
    {
        let k1 = 14400.0
        let k2 = 3.0E6
        
        return V * (k2 * exp(-k2 * t) - k1 * exp(-k1 * t))
        
    }
    
    func saveFileWithString(fileString:String)
    {
        let saveFilePanel = NSSavePanel()
        
        saveFilePanel.title = "Save Spice data"
        saveFilePanel.canCreateDirectories = true
        saveFilePanel.allowedFileTypes = ["cir", "txt"]
        saveFilePanel.allowsOtherFileTypes = false
        
        if (saveFilePanel.runModal() == NSFileHandlingPanelOKButton)
        {
            guard let newFileURL = saveFilePanel.URL
                else
            {
                DLog("Bad file name")
                return
            }
            
            do {
                try fileString.writeToURL(newFileURL, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                ALog("Could not write file!")
            }
            
            DLog("Finished writing file")
        }
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

