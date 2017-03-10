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
    var prefixes = ""
    var source = ""
    var suffixes = ""
    var options: NSRegularExpression.Options = .anchorsMatchLines

    // computed properties
    var pattern: String { return prefixes + source + suffixes }

    var regularExpression: NSRegularExpression! {
        return try! NSRegularExpression(pattern: pattern, options: options)
    }
    
    func set(prefixes: String? = nil, source: String? = nil, suffixes: String? = nil, options: NSRegularExpression.Options? = nil) -> VerbalExpressions {
        return VerbalExpressions(
            prefixes: prefixes ?? self.prefixes,
            source: source ?? self.source,
            suffixes: suffixes ?? self.suffixes,
            options: options ?? self.options
        )
    }

    // instance methods
    public func startOfLine(enabled: Bool = true) -> VerbalExpressions {
        return set(prefixes: enabled ? "^" : "")
    }

    public func endOfLine(enabled: Bool = true) -> VerbalExpressions {
        return set(suffixes: enabled ? "$" : "")    }

    public func then(_ string: String) -> VerbalExpressions {
        return add("(?:\(sanitize(string)))")
    }

    public func then(_ string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:\(sanitize(string.source)))")
    }

    // alias for then
    public func find(_ string: String) -> VerbalExpressions {
        return then(string)
    }

    public func find(_ string: VerbalExpressions) -> VerbalExpressions {
        return then(string)
    }

    public func maybe(_ string: String) -> VerbalExpressions {
        return add("(?:\(sanitize(string)))?")
    }

    public func maybe(_ string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:\(sanitize(string.source)))?")
    }

    public func or() -> VerbalExpressions {
        return set(prefixes: prefixes + "(?:")
            .set(suffixes: ")" + suffixes)
            .add(")|(?:")
    }

    public func or(_ value: String) -> VerbalExpressions {
        return or().then(value)
    }

    public func or(_ value: VerbalExpressions) -> VerbalExpressions {
        return or(value.source);
    }

    public func anything() -> VerbalExpressions {
        return add("(?:.*)")
    }

    public func anythingBut(_ string: String) -> VerbalExpressions {
        return add("(?:[^\(sanitize(string))]*)")
    }

    public func anythingBut(_ string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:[^\(sanitize(string.source))]*)")
    }

    public func something() -> VerbalExpressions {
        return add("(?:.+)")
    }

    public func somethingBut(_ string: String) -> VerbalExpressions {
        return add("(?:[^\(sanitize(string))]+)")
    }

    public func somethingBut(_ string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:[^\(sanitize(string.source))]+)")
    }

    public func lineBreak() -> VerbalExpressions {
        return add("(?:(?:\n)|(?:\r\n))")
    }

    // alias for lineBreak
    public func br() -> VerbalExpressions {
        return lineBreak()
    }

    public func tab() -> VerbalExpressions {
        return add("\t")
    }

    public func word() -> VerbalExpressions {
        return add("\\w+")
    }

    public func anyOf(_ string: String) -> VerbalExpressions {
        return add("(?:[\(sanitize(string))])")
    }

    public func anyOf(_ string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:[\(sanitize(string.source))])")
    }

    // alias for anyOf
    public func any(_ string: String) -> VerbalExpressions {
        return anyOf(string)
    }

    public func any(_ string: VerbalExpressions) -> VerbalExpressions {
        return anyOf(string.source)
    }

    public func withAnyCase(enabled: Bool = true) -> VerbalExpressions {
        if enabled {
            return addModifier("i")
        }
        else {
            return removeModifier("i")
        }
    }

    public func searchOneLine(enabled: Bool = true) -> VerbalExpressions {
        if enabled {
            return removeModifier("m")
        }
        else {
            return addModifier("m")
        }
    }

    public func beginCapture() -> VerbalExpressions {
        return set(suffixes: suffixes + ")")
            .add("(")
    }

    public func endCapture() -> VerbalExpressions {
        return set(suffixes: suffixes[suffixes.startIndex..<suffixes.characters.index(before: suffixes.endIndex)])
            .add(")")
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

    // internal methods

    func sanitize(_ string: String) -> String {
        return NSRegularExpression.escapedPattern(for: string)
    }

    func add(_ string: String) -> VerbalExpressions {
        return set(source: source + string)
    }

    func addModifier(_ modifier: Character) -> VerbalExpressions {
        if let option = option(forModifier: modifier) {
            if( options.union(option) != options ){
                return set(options: options.union(option))
            }
        }
        return self
    }

    func addModifier(_ modifier: NSRegularExpression.Options) -> VerbalExpressions {
        if( options != options.union(modifier) ){
            return set(options: options.union(modifier))
        }
        return self
    }

    func removeModifier(_ modifier: Character) -> VerbalExpressions {
        if let option = option(forModifier: modifier), options.contains(option) {
            return set(options: options.subtracting(option))
        }

        return self
    }

    func option(forModifier modifier: Character) -> NSRegularExpression.Options? {
        switch modifier {
        case "d": // UREGEX_UNIX_LINES
            return .useUnixLineSeparators
        case "i": // UREGEX_CASE_INSENSITIVE
            return .caseInsensitive
        case "x": // UREGEX_COMMENTS
            return .allowCommentsAndWhitespace
        case "m": // UREGEX_MULTILINE
            return .anchorsMatchLines
        case "s": // UREGEX_DOTALL
            return .dotMatchesLineSeparators
        case "u": // UREGEX_UWORD
            return .useUnicodeWordBoundaries
        case "U": // UREGEX_LITERAL
            return .ignoreMetacharacters
        default:
            fatalError("Unknown modifier")
        }
    }

}

extension VerbalExpressions: CustomStringConvertible {
    public var description: String { return pattern }
}

// Match operators
// Adapted from https://gist.github.com/JimRoepcke/d68dd41ee2fedc6a0c67
infix operator =~  { associativity left precedence 140 }
infix operator !~ { associativity left precedence 140 }

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
