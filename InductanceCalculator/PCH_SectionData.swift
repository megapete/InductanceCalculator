//
//  PCH_SectionData.swift
//  InductanceCalculator
//
//  Created by PeterCoolAssHuber on 2015-12-28.
//  Copyright © 2015 Peter Huber. All rights reserved.
//

import Cocoa

struct PCH_SectionData {

    /// The ID of the section
    let sectionID:String
    
    /// The unique serial number associated with the section. This is used in the construction of the inductance and capacitance matrices
    let serialNumber:Int
    
    let nodes:(inNode:Int, outNode:Int)
    
    /// The series capacitance of the section, in F
    var seriesCapacitance:Double = 0.0
    
    /// The shunt capacitances to other sections, in F. The keys are the sectionID's of the other sections.
    var shuntCapacitances = [String:Double]()
    
    /// The shunt capacitances to other sections, in F. The keys are the PCH_Section's of the other sections.
    var shuntCaps = [PCH_DiskSection:Double]()
    
    /// The resistance of the section, in Ω
    var resistance:Double = 0.0
    
    /// The self-inductance of the section, in H
    var selfInductance:Double = 0.0
    
    /// The mutual inductances to all other sections, in H. The keys are the sectionID's of the other sections.
    var mutualInductances = [String:Double]()
    
    /// The mutual inductances to all other sections, in H. The keys are the PCH_Section's of the other sections
    var mutInd = [PCH_DiskSection:Double]()
    
    /// The mutual inductances as coefficients k = M12 / sqrt(L1 * L2). The keys are the sectionID's of the other sections.
    var mutIndCoeff = [String:Double]()
    
    init(sectionID:String, serNum:Int, inNode:Int, outNode:Int)
    {
        self.sectionID = sectionID
        self.serialNumber = serNum
        self.nodes = (inNode, outNode)
    }
    
}
