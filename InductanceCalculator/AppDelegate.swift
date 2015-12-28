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
        let capFirstDisk = 1.4923E-9
        let capOtherDisks = 1.6185E-9
        let capToShield = 6.5814E-12
        let capToTank = 1.0259E-22
        let resPerDisk = 0.19727
        let numDisks = 60
         
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

