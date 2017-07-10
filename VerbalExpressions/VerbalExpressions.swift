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
    var options: NSRegularExpressionOptions = .AnchorsMatchLines

    // computed properties
    var pattern: String { return prefixes + source + suffixes }

    var regularExpression: NSRegularExpression! {
        return try! NSRegularExpression(pattern: pattern, options: options)
    }
    
    func set(prefixes prefixes: String? = nil, source: String? = nil, suffixes: String? = nil, options: NSRegularExpressionOptions? = nil) -> VerbalExpressions {
        return VerbalExpressions(
            prefixes: prefixes ?? self.prefixes,
            source: source ?? self.source,
            suffixes: suffixes ?? self.suffixes,
            options: options ?? self.options
        )
    }

    // instance methods
    public func startOfLine(enabled enabled: Bool = true) -> VerbalExpressions {
        return set(prefixes: enabled ? "^" : "")
    }

    public func endOfLine(enabled enabled: Bool = true) -> VerbalExpressions {
        return set(suffixes: enabled ? "$" : "")    }

    public func then(string: String) -> VerbalExpressions {
        return add("(?:\(sanitize(string)))")
    }

    public func then(string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:\(sanitize(string.source)))")
    }

    // alias for then
    public func find(string: String) -> VerbalExpressions {
        return then(string)
    }

    public func find(string: VerbalExpressions) -> VerbalExpressions {
        return then(string)
    }

    public func maybe(string: String) -> VerbalExpressions {
        return add("(?:\(sanitize(string)))?")
    }

    public func maybe(string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:\(sanitize(string.source)))?")
    }

    public func or() -> VerbalExpressions {
        return set(prefixes: prefixes + "(?:")
            .set(suffixes: ")" + suffixes)
            .add(")|(?:")
    }

    public func or(value: String) -> VerbalExpressions {
        return or().then(value)
    }

    public func or(value: VerbalExpressions) -> VerbalExpressions {
        return or(value.source);
    }

    public func anything() -> VerbalExpressions {
        return add("(?:.*)")
    }

    public func anythingBut(string: String) -> VerbalExpressions {
        return add("(?:[^\(sanitize(string))]*)")
    }

    public func anythingBut(string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:[^\(sanitize(string.source))]*)")
    }

    public func something() -> VerbalExpressions {
        return add("(?:.+)")
    }

    public func somethingBut(string: String) -> VerbalExpressions {
        return add("(?:[^\(sanitize(string))]+)")
    }

    public func somethingBut(string: VerbalExpressions) -> VerbalExpressions {
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

    public func anyOf(string: String) -> VerbalExpressions {
        return add("(?:[\(sanitize(string))])")
    }

    public func anyOf(string: VerbalExpressions) -> VerbalExpressions {
        return add("(?:[\(sanitize(string.source))])")
    }

    // alias for anyOf
    public func any(string: String) -> VerbalExpressions {
        return anyOf(string)
    }

    public func any(string: VerbalExpressions) -> VerbalExpressions {
        return anyOf(string.source)
    }

    public func withAnyCase(enabled enabled: Bool = true) -> VerbalExpressions {
        if enabled {
            return addModifier("i")
        }
        else {
            return removeModifier("i")
        }
    }

    public func searchOneLine(enabled enabled: Bool = true) -> VerbalExpressions {
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
        return set(suffixes: suffixes[suffixes.startIndex..<suffixes.endIndex.predecessor()])
            .add(")")
    }

    public func replace(string: String, template: String) -> String {
        let range = NSRange(location: 0, length: string.utf16.count)

        return regularExpression.stringByReplacingMatchesInString(string, options: [], range: range, withTemplate: template)
    }

    public func replace(string: String, with: String) -> String {
        let range = NSRange(location: 0, length: string.utf16.count)
        let template = NSRegularExpression.escapedTemplateForString(with)

        return regularExpression.stringByReplacingMatchesInString(string, options: [], range: range, withTemplate: template)
    }

    public func test(string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)

        if let result = regularExpression.firstMatchInString(string, options: [], range: range) {
            return result.range.location != NSNotFound
        }

        return false
    }

    // internal methods

    func sanitize(string: String) -> String {
        return NSRegularExpression.escapedPatternForString(string)
    }

    func add(string: String) -> VerbalExpressions {
        return set(source: source + string)
    }

    func addModifier(modifier: Character) -> VerbalExpressions {
        if let option = option(forModifier: modifier) {
            if( options.union(option) != options ){
                return set(options: options.union(option))
            }
        }
        return self
    }

    func addModifier(modifier: NSRegularExpressionOptions) -> VerbalExpressions {
        if( options != options.union(modifier) ){
            return set(options: options.union(modifier))
        }
        return self
    }

    func removeModifier(modifier: Character) -> VerbalExpressions {
        if let option = option(forModifier: modifier) where options.contains(option) {
            return set(options: options.subtract(option))
        }

        return self
    }

    func option(forModifier modifier: Character) -> NSRegularExpressionOptions? {
        switch modifier {
        case "d": // UREGEX_UNIX_LINES
            return .UseUnixLineSeparators
        case "i": // UREGEX_CASE_INSENSITIVE
            return .CaseInsensitive
        case "x": // UREGEX_COMMENTS
            return .AllowCommentsAndWhitespace
        case "m": // UREGEX_MULTILINE
            return .AnchorsMatchLines
        case "s": // UREGEX_DOTALL
            return .DotMatchesLineSeparators
        case "u": // UREGEX_UWORD
            return .UseUnicodeWordBoundaries
        case "U": // UREGEX_LITERAL
            return .IgnoreMetacharacters
        default:
            fatalError("Unknown modifier")
        }
    }

}

extension VerbalExpressions: CustomStringConvertible {
    public var description: String { return pattern }
}

//Return found substrings
extension VerbalExpressions {
    func resultsFromString(string: String) -> [String] {
        let range = NSRange(location: 0, length: string.utf16.count)
        let results = regularExpression.matchesInString(string, options: [], range: range)
        var strings: [String] = []
        for result in results {
            guard result.range.location != NSNotFound else { continue }
            autoreleasepool {
                let string = (string as NSString).substringWithRange(result.range)
                strings.append(string)
            }
        }
        return strings
    }
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
