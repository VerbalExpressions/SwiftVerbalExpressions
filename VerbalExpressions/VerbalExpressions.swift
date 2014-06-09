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
    var options: NSRegularExpressionOptions = nil

    // computed properties
    var regex: NSRegularExpression {
    return NSRegularExpression(pattern: pattern, options: options, error: nil)
    }

    // class methods
    class func escape(string: String) -> String {
        return NSRegularExpression.escapedPatternForString(string)
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

    func then(string: String) -> Self {
        pattern += "(?:\(VerbalExpressions.escape(string)))"

        return self
    }

    // alias for then
    func find(string: String) -> Self {
        return then(string)
    }

    func maybe(string: String) -> Self {
        pattern += "(?:\(VerbalExpressions.escape(string)))?"

        return self
    }

    func something() -> Self {
        pattern += "(?:.+)"

        return self
    }

    func somethingBut(string: String) -> Self {
        pattern += "(?:[^\(VerbalExpressions.escape(string))]+)"

        return self
    }

    func anything() -> Self {
        pattern += "(?:.*)"

        return self
    }

    func anythingBut(string: String) -> Self {
        pattern += "(?:[^\(VerbalExpressions.escape(string))]*)"

        return self
    }

    func anyOf(string: String) -> Self {
        pattern += "(?:[\(VerbalExpressions.escape(string))])"

        return self
    }

    func any(string: String) -> Self {
        return anyOf(string)
    }

    func linebreak() -> Self {
        pattern += "(?:(?:\n)|(?:\r\n))"

        return self
    }

    // alias for linebreak
    func br() -> Self {
        return linebreak()
    }

    func tab() -> Self {
        pattern += "\t"

        return self
    }

    func word() -> Self {
        pattern += "\\w+"

        return self
    }

    func test(string: String, options: NSMatchingOptions = nil) -> Bool {
        let range = NSRange(location: 0, length: countElements(string))
        
        if let result = regex.firstMatchInString(string, options: options, range: range) {
            return result.range.location != NSNotFound
        }

        return false
    }

}
