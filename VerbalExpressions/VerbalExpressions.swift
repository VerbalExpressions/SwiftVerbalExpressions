//
//  VerbalExpressions.swift
//  VerbalExpressions
//
//  Created by Dominique d'Argent on 04/06/14.
//  Copyright (c) 2014 Dominique d'Argent. All rights reserved.
//

import Foundation

func VerEx(options: NSRegularExpressionOptions = nil) -> VerbalExpressions {
    return VerbalExpressions(options: options)
}

class VerbalExpressions {
    // stored properties
    var pattern: String = ""
    var options: NSRegularExpressionOptions!
    
    // computed properties
    var regex: NSRegularExpression {
    return NSRegularExpression(pattern: pattern, options: options, error: nil)
    }
    
    // class methods
    class func escape(str: String) -> String {
        return NSRegularExpression.escapedPatternForString(str)
    }
    
    
    // initializers
    init(options: NSRegularExpressionOptions = nil) {
        self.options = options
    }
    
    
    // instance methods
    func startOfLine() -> Self {
        pattern += "^"
        
        return self
    }
    
    func endOfLine() -> Self {
        pattern += "$"
        
        return self
    }
    
    func then(str: String) -> Self {
        pattern += "(?:\(VerbalExpressions.escape(str)))"
        
        return self
    }
    
    // alias for then
    func find(str: String) -> Self {
        return self.then(str)
    }
    
    func maybe(str: String) -> Self {
        pattern += "(?:\(VerbalExpressions.escape(str)))?"
        
        return self
    }
    
    func something() -> Self {
        pattern += "(?:.+)"
        
        return self
    }
    
    func somethingBut(str: String) -> Self {
        pattern += "(?:[^\(VerbalExpressions.escape(str))]+)"
        
        return self
    }
    
    func anything() -> Self {
        pattern += "(?:.*)"
        
        return self
    }
    
    func anythingBut(str: String) -> Self {
        pattern += "(?:[^\(VerbalExpressions.escape(str))]*)"
        
        return self
    }
    
    func anyOf(str: String) -> Self {
        pattern += "(?:[\(VerbalExpressions.escape(str))])"
        
        return self
    }
    
    func any(str: String) -> Self {
        return self.anyOf(str)
    }
    
    func linebreak() -> Self {
        pattern += "(?:(?:\n)|(?:\r\n))"
        
        return self
    }
    
    // alias for linebreak
    func br() -> Self {
        return self.linebreak()
    }
    
    func tab() -> Self {
        pattern += "\t"
        
        return self
    }
    
    func word() -> Self {
        pattern += "\\w+"
        
        return self
    }
    
    func test(str: String, options: NSMatchingOptions = nil) -> Bool {
        let range = NSRange(location: 0, length: countElements(str))
        let result = self.regex.firstMatchInString(str, options: options, range: range)
        
        if result {
            return result.range.location != NSNotFound
        }
        
        return false
    }
    
}
