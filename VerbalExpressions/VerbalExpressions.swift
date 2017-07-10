//
//  VerbalExpressions.swift
//  VerbalExpressions
//
//  Created by Dominique d'Argent on 04/06/14.
//  Copyright (c) 2014 Dominique d'Argent. All rights reserved.
//

import Foundation

public func VerEx() -> VerbalExpressions {
    return VerbalExpressions()
}

public struct VerbalExpressions {
    // stored properties
    fileprivate let prefixes: String
    fileprivate let source: String
    fileprivate let suffixes: String
    fileprivate let options: NSRegularExpression.Options

    // computed properties
    public var pattern: String { return prefixes + source + suffixes }

    public var regularExpression: NSRegularExpression! {
        return try! NSRegularExpression(pattern: pattern, options: options)
    }
    
    // initializers
    public init() {
        self.init(prefixes: "", source: "", suffixes: "", options: .anchorsMatchLines)
    }
    
    fileprivate init(prefixes: String, source: String, suffixes: String, options: NSRegularExpression.Options) {
        self.prefixes = prefixes
        self.source = source
        self.suffixes = suffixes
        self.options = options
    }
    
    // instance methods
    public func startOfLine(enabled: Bool = true) -> VerbalExpressions {
        return setting(prefixes: enabled ? "^" : "")
    }

    public func endOfLine(enabled: Bool = true) -> VerbalExpressions {
        return setting(suffixes: enabled ? "$" : "")
    }

    public func then(_ string: String) -> VerbalExpressions {
        return adding("(?:\(string.sanitized))")
    }

    public func then(_ exp: VerbalExpressions) -> VerbalExpressions {
        return then(exp.source)
    }

    // alias for then
    public func find(_ string: String) -> VerbalExpressions {
        return then(string)
    }

    public func find(_ exp: VerbalExpressions) -> VerbalExpressions {
        return find(exp.source)
    }

    public func maybe(_ string: String) -> VerbalExpressions {
        return adding("(?:\(string.sanitized))?")
    }

    public func maybe(_ exp: VerbalExpressions) -> VerbalExpressions {
        return maybe(exp.source)
    }

    public func or() -> VerbalExpressions {
        return setting(prefixes: prefixes + "(?:", suffixes: ")" + suffixes)
            .adding(")|(?:")
    }

    public func or(_ string: String) -> VerbalExpressions {
        return or().then(string)
    }

    public func or(_ exp: VerbalExpressions) -> VerbalExpressions {
        return or(exp.source);
    }

    public func anything() -> VerbalExpressions {
        return adding("(?:.*)")
    }

    public func anythingBut(_ string: String) -> VerbalExpressions {
        return adding("(?:[^\(string.sanitized)]*)")
    }

    public func anythingBut(_ exp: VerbalExpressions) -> VerbalExpressions {
        return anythingBut(exp.source)
    }

    public func something() -> VerbalExpressions {
        return adding("(?:.+)")
    }

    public func somethingBut(_ string: String) -> VerbalExpressions {
        return adding("(?:[^\(string.sanitized)]+)")
    }

    public func somethingBut(_ exp: VerbalExpressions) -> VerbalExpressions {
        return somethingBut(exp.source)
    }

    public func lineBreak() -> VerbalExpressions {
        return adding("(?:(?:\n)|(?:\r\n))")
    }

    // alias for lineBreak
    public func br() -> VerbalExpressions {
        return lineBreak()
    }

    public func tab() -> VerbalExpressions {
        return adding("\t")
    }

    public func word() -> VerbalExpressions {
        return adding("\\w+")
    }

    public func anyOf(_ string: String) -> VerbalExpressions {
        return adding("(?:[\(string.sanitized)])")
    }

    public func anyOf(_ exp: VerbalExpressions) -> VerbalExpressions {
        return anyOf(exp.source)
    }

    // alias for anyOf
    public func any(_ string: String) -> VerbalExpressions {
        return anyOf(string)
    }

    public func any(_ exp: VerbalExpressions) -> VerbalExpressions {
        return anyOf(exp.source)
    }

    public func withAnyCase(enabled: Bool = true) -> VerbalExpressions {
        if enabled {
            return adding(modifier: "i")
        }
        else {
            return removing(modifier: "i")
        }
    }

    public func searchOneLine(enabled: Bool = true) -> VerbalExpressions {
        if enabled {
            return removing(modifier: "m")
        }
        else {
            return adding(modifier: "m")
        }
    }

    public func beginCapture() -> VerbalExpressions {
        return setting(suffixes: suffixes + ")")
            .adding("(")
    }

    public func endCapture() -> VerbalExpressions {
        return setting(suffixes: suffixes.substring(to: suffixes.endIndex))
            .adding(")")
    }

    public func replace(_ string: String, template: String) -> String {
        let range = NSRange(location: 0, length: string.utf16.count)

        return regularExpression.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: template)
    }

    public func replace(_ string: String, with: String) -> String {
        let range = NSRange(location: 0, length: string.utf16.count)
        let template = NSRegularExpression.escapedTemplate(for: with)

        return regularExpression.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: template)
    }

    public func test(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)

        if let result = regularExpression.firstMatch(in: string, options: [], range: range) {
            return result.range.location != NSNotFound
        }

        return false
    }

}

fileprivate extension VerbalExpressions {
    func setting(prefixes: String? = nil, source: String? = nil, suffixes: String? = nil, options: NSRegularExpression.Options? = nil) -> VerbalExpressions {
        guard prefixes != self.prefixes || source != self.source || suffixes != self.suffixes || options != self.options else {
            return self
        }
        
        return VerbalExpressions(
            prefixes: prefixes ?? self.prefixes,
            source: source ?? self.source,
            suffixes: suffixes ?? self.suffixes,
            options: options ?? self.options
        )
    }
    
    func adding(_ string: String) -> VerbalExpressions {
        return setting(source: source + string)
    }

    func adding(modifier: Character) -> VerbalExpressions {
        return adding(options: NSRegularExpression.Options(modifier: modifier))
    }

    func adding(options: NSRegularExpression.Options) -> VerbalExpressions {
        return setting(options: self.options.union(options))
    }

    func removing(modifier: Character) -> VerbalExpressions {
        let removedOptions = NSRegularExpression.Options(modifier: modifier)
        let newOptions = options.subtracting(removedOptions)
        return setting(options: newOptions)
    }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible conformance
extension VerbalExpressions: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { return pattern }
    public var debugDescription: String { return pattern }
}

// MARK: - Equatable conformance
extension VerbalExpressions: Equatable {
    public static func ==(lhs: VerbalExpressions, rhs: VerbalExpressions) -> Bool {
        return lhs.pattern == rhs.pattern && lhs.options == rhs.options
    }
}

fileprivate extension String {
    var sanitized: String {
        return NSRegularExpression.escapedPattern(for: self)
    }
}

fileprivate extension NSRegularExpression.Options {
    init(modifier: Character) {
        switch modifier {
        case "d": // UREGEX_UNIX_LINES
            self = .useUnixLineSeparators
        case "i": // UREGEX_CASE_INSENSITIVE
            self = .caseInsensitive
        case "x": // UREGEX_COMMENTS
            self = .allowCommentsAndWhitespace
        case "m": // UREGEX_MULTILINE
            self = .anchorsMatchLines
        case "s": // UREGEX_DOTALL
            self = .dotMatchesLineSeparators
        case "u": // UREGEX_UWORD
            self = .useUnicodeWordBoundaries
        case "U": // UREGEX_LITERAL
            self = .ignoreMetacharacters
        default:
            self = []
        }
    }
}

// MARK: - Operators
// Adapted from https://gist.github.com/JimRoepcke/d68dd41ee2fedc6a0c67
infix operator =~: ComparisonPrecedence
infix operator !~: ComparisonPrecedence

public func =~(lhs: String, rhs: VerbalExpressions) -> Bool {
    return rhs.test(lhs)
}

public func =~(lhs: VerbalExpressions, rhs: String) -> Bool {
    return lhs.test(rhs)
}

public func !~(lhs: String, rhs: VerbalExpressions) -> Bool {
    return !(lhs =~ rhs)
}

public func !~(lhs: VerbalExpressions, rhs: String) -> Bool {
    return !(lhs =~ rhs)
}

