//
//  PCH_Defs.swift
//  TransformerModel
//
//  Created by Peter Huber on 2015-07-15.
//  Copyright (c) 2015 Peter Huber. All rights reserved.
//

// Standard defs that should be included in all PCH projects.

import Foundation

/**
    Swift does a ridiculous amount of syntactic gymnastics for strings to ensure that every possible alphabet know to man will be properly handled. Since my program will (mostly) be used in the Western world, I have decided to write a few simple functions to make string manipulation easier.
    
    Version 1.0: Compatibility with Swift 3 (former versions untested)
*/

// The PCH_Mid function returns a substring the old-fashioned way
func PCH_Mid(_ src:String, start:Int, end:Int) -> String
{
    let strLen = src.characters.count
    
    guard (start >= 0 && start < strLen && end >= start && end < strLen) else
    {
        DLog("Illegal index")
        return ""
    }
    
    let theRange = Range(uncheckedBounds: (src.index(src.startIndex, offsetBy: start), src.index(src.startIndex, offsetBy: end)))
    
    let result = src.substring(with: theRange)
    
    return result
}

/** 

    My standard debug logging function (this will probably change with time)
    
    - parameter message: The debug message
    - parameter file: The name of the file where the debug message was invoked
    - parameter function: The name of the function where the debug message was invoked
    - parameter line: The line number of the file where the debug message was invoked

*/
func DLog(_ message:String, file:String = #file, function:String = #function, line:Int = #line)
{
    #if DEBUG
        
        print("\(file) : \(function) : \(line) : \(message)\n")
        
    #endif
}

/**

    My standard assertion/debugging logging function (this will probably change with time)

    - parameter message: The debug message
    - parameter file: The name of the file where the debug message was invoked
    - parameter function: The name of the function where the debug message was invoked
    - parameter line: The line number of the file where the debug message was invoked

*/
func ALog(_ message:String, file:String = #file, function:String = #function, line:Int = #line)
{
    #if DEBUG
    
        let msgString = file + " : " + function + " : " + String(line) + " : " + message
        
        assert(false, msgString)
        
    #else
    
        print("\(file) : \(function) : \(line) : \(message)\n", terminator: "")
        
    #endif
}

/**
    My standard "assert" function
    
    - parameter condition: The condition that must be true to not assert
    - parameter message: The message to show if condition is false
*/
func ZAssert(_ condition:Bool, message:String, file:String = #file, function:String = #function, line:Int = #line)
{
    if !condition
    {
        #if DEBUG
            
            let msgString = file + " : " + function + " : " + String(line) + " : " + message
            
            assert(false, msgString)
            
        #else
            
            print("\(file) : \(function) : \(line) : \(message)\n", terminator: "")
            
        #endif
    }
}
