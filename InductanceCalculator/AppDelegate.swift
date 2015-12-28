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
        
        for _ in 1...Int(hv_numDisks)
        {
            hvCoil.append(PCH_DiskSection(diskRect: hv_diskRect, N: hv_turnsPerDisk, J: hv_J, windHt: windowHt, coreRadius: coreRadius))
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
        
        for _ in 1...Int(lv_numDisks)
        {
            lvCoil.append(PCH_DiskSection(diskRect: lv_diskRect, N: lv_turnsPerDisk, J: lv_J, windHt: windowHt, coreRadius: coreRadius))
            lv_diskRect = lv_diskRect.offsetBy(dx: 0.0, dy:CGFloat(-lv_diskPitch))
        }
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

