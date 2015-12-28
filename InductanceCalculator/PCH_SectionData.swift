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
    
    /// The series capacitance of the section, in F
    var seriesCapacitance:Double = 0.0
    
    /// The shunt capacitances to other sections, in F. The keys are the sectionID's of the other sections.
    var shuntCapacitances = [String:Double]()
    
    /// The resistance of the section, in Ω
    var resistance:Double = 0.0
    
    /// The self-inductance of the section, in H
    var selfInductance:Double = 0.0
    
    /// The mutual inductances to all other sections, in H. The keys are the sectionID's of the other sections.
    var mutualInductances = [String:Double]()
    
    init(sectionID:String)
    {
        self.sectionID = sectionID
    }
    
}
