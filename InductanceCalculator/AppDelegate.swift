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
        
        lvRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, 2.965 * 25.4/1000.0, 0.296 * 25.4/1000.0, 32.065 * 25.4/1000)
        lv = PCH_DiskSection(diskRect: lvRect, N: 16.0, J: -16.0 * 481.13 / Double(lvRect.size.width * lvRect.size.height), windHt: 1.1, coreRadius: 0.141)
        hvRect = NSMakeRect(25.411 / 2.0 * 25.4/1000.0, 2.75 * 25.4/1000.0, 5.148 * 25.4/1000.0, 32.495 * 25.4/1000)
        hv = PCH_DiskSection(diskRect: hvRect, N: 3200.0, J: 3200.0 * 2.4056 / Double(hvRect.size.width * hvRect.size.height), windHt: 1.1, coreRadius: 0.141)
        
        L1 = lv.SelfInductance()
        L2 = hv.SelfInductance()
        M12 = lv.MutualInductanceTo(hv)
        
        // The actual calculation for two-winding transformers (exactly right!!!)
        // This is the leakage inductance looking from the L1 (in this case LV) side
        lkInd = L1 + gsl_pow_2(16.0 / 3200.0) * L2 - 2.0 * (16.0 / 3200.0) * M12
        
        DLog("Leakage reactance (ohms): \(lkInd * 2.0 * π * 60.0)")
        
        lvRect = NSMakeRect(18.3 / 2.0 * 25.4/1000.0, 2.75 * 25.4/1000.0, 1.198 * 25.4/1000.0, 39.409 * 25.4/1000)
        lv = PCH_DiskSection(diskRect: lvRect, N: 233.0, J: -233.0 * 166.667 / Double(lvRect.size.width * lvRect.size.height), windHt: 1.18, coreRadius: 0.207)
        hvRect = NSMakeRect(22.928 / 2.0 * 25.4/1000.0, 2.75 * 25.4/1000.0, 1.198 * 25.4/1000.0, 39.409 * 25.4/1000)
        hv = PCH_DiskSection(diskRect: hvRect, N: 233.0, J: 233.0 * 166.667 / Double(hvRect.size.width * hvRect.size.height), windHt: 1.18, coreRadius: 0.207)
        
        L1 = lv.SelfInductance()
        L2 = hv.SelfInductance()
        M12 = lv.MutualInductanceTo(hv)
        
        lkInd = L1 + L2 - 2.0 * M12
        
        DLog("Leakage reactance (ohms): \(lkInd * 2.0 * π * 60.0)")
        */
        
        // Interesting stuff starts here
        // Create the special section for ground. In SPICE, this always has the ID of '0'
        let ground = PCH_SectionData(sectionID: "0")
        
        // Job016 HV data
        let hv_capFirstDisk = 1.4923E-9
        let hv_capOtherDisks = 1.6185E-9
        let hv_capToShield = 6.5814E-12
        let hv_capToTank = 1.0259E-22
        let hv_resPerDisk = 0.19727
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
        
        for i in 1...Int(hv_numDisks)
        {
            var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", hv_ID, i))
            nextSectionData.resistance = hv_resPerDisk
            nextSectionData.seriesCapacitance = (i==1 ? hv_capFirstDisk : hv_capOtherDisks)
            nextSectionData.shuntCapacitances["0"] = hv_capToShield + hv_capToTank
            
            hvCoil.append(PCH_DiskSection(diskRect: hv_diskRect, N: hv_turnsPerDisk, J: hv_J, windHt: windowHt, coreRadius: coreRadius, secData: nextSectionData))
            hv_diskRect = hv_diskRect.offsetBy(dx: 0.0, dy:CGFloat(-hv_diskPitch))
        }
        
        // Job016 LV data
        let lv_capFirstDisk = 1.4734E-10
        let lv_capOtherDisks = 1.8072E-10
        let lv_capToShield = 3.9534E-11
        let lv_capToCore = 3.2097E-11
        let lv_resPerDisk = 1.3909E-3
        let lv_numDisks = 16.0
        let lv_turnsPerDisk = 1.0
        // start at the top disk (the one that will be shot)
        var lv_diskRect = NSMakeRect(14.1 / 2.0 * 25.4/1000.0, (3.921 + 32.065) * 25.4/1000.0, 0.296 * 25.4/1000.0, 1.913 * 25.4/1000.00)
        let lv_diskPitch = (32.065 * 25.4/1000.0 / 16)
        let lv_J = 481.13 * lv_turnsPerDisk / Double(hv_diskRect.size.width * hv_diskRect.size.height)
        let lv_ID = "LV"
        
        var lvCoil = [PCH_DiskSection]()
        
        for i in 1...Int(lv_numDisks)
        {
            var nextSectionData = PCH_SectionData(sectionID: String(format: "%@%03d", lv_ID, i))
            nextSectionData.resistance = lv_resPerDisk
            nextSectionData.seriesCapacitance = (i==1 ? lv_capFirstDisk : lv_capOtherDisks)
            nextSectionData.shuntCapacitances["0"] = lv_capToShield + lv_capToCore
            
            lvCoil.append(PCH_DiskSection(diskRect: lv_diskRect, N: lv_turnsPerDisk, J: lv_J, windHt: windowHt, coreRadius: coreRadius, secData: nextSectionData))
            lv_diskRect = lv_diskRect.offsetBy(dx: 0.0, dy:CGFloat(-lv_diskPitch))
        }
        
        // At this point, our two arrays hold all the disks from the two windings. Now we need to calculate self- and mutual-inductances. We start by combining the arrays into one big one
        var coilArray = hvCoil + lvCoil
        
        for nextDisk in coilArray
        {
            nextDisk.data.selfInductance = nextDisk.SelfInductance()
        }
        
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
        var mutIndSerialNum = 0
        
        coilArray = hvCoil + lvCoil
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
            let seriesCapName = "CS" + nextSectionID
            
            fileString += String(format: "* Definitions for disk: %@\n", nextSectionID)
            fileString += selfIndName + " " + inNode + " " + midNode + String(format: " %.4E\n", nextDisk.data.selfInductance)
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
        
        /*
        NSString *documentsDirectory;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            documentsDirectory = [paths objectAtIndex:0];
        }
*/
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        ZAssert(paths.count > 0, message: "Could not find Documents directory!")
        
        let filename = paths[0] + "/J016_Spicefile.cir"
        
        do {
            try fileString.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {
            ALog("Could not write file!")
        }

    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

