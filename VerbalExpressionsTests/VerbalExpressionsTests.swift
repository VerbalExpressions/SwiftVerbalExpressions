//
//  VerbalExpressionsTests.swift
//  VerbalExpressionsTests
//
//  Created by Dominique d'Argent on 04/06/14.
//  Copyright (c) 2014 Dominique d'Argent. All rights reserved.
//

import XCTest
import VerbalExpressions

class VerbalExpressionsTests: XCTestCase {
    
    func testStartOfLine() {
        var tester = VerEx()
            .startOfLine()
            .then("a")
        
        XCTAssert(tester.test("a"),   "starts with an a")
        XCTAssert(!tester.test("ba"), "doesn't start with an a")
        
        tester = tester.startOfLine(enabled: false)
        XCTAssert(tester.test("ba"), "contains an a")
        XCTAssert(!tester.test("b"), "doesn't contain an a")
    }
    
    func testEndOfLine() {
        var tester = VerEx()
            .find("a")
            .endOfLine()
        
        XCTAssert(tester.test("a"),   "ends with an a")
        XCTAssert(!tester.test("ab"), "doesn't end with an a")
        
        tester = tester.endOfLine(enabled: false)
        XCTAssert(tester.test("ab"), "contains an a")
        XCTAssert(!tester.test("b"), "doesn't contain an a")
    }
    
    func testMaybe() {
        let tester = VerEx()
            .startOfLine()
            .then("a")
            .maybe("b")
        
        XCTAssert(tester.test("abc"), "maybe has a b after an a")
        XCTAssert(tester.test("ac"),  "maybe has a b after an a")
    }
    
    func testAnything() {
        let tester = VerEx()
            .startOfLine()
            .then("a")
            .anything()
            .then("c")
        
        XCTAssert(tester.test("abc"), "has anything between a and c")
        XCTAssert(tester.test("ac"),  "has anything (or nothing) between a and c")
    }
    
    func testAnythingBut() {
        let tester = VerEx()
            .startOfLine()
            .then("a")
            .anythingBut("b")
            .then("c")
        
        XCTAssert(tester.test("axc"),  "has anything (but b) between a and c")
        XCTAssert(tester.test("ac"),   "has anything (or nothing) between a and c")
        XCTAssert(!tester.test("abc"), "has no b between a and c")
    }
    
    func testSomething() {
        let tester = VerEx()
            .startOfLine()
            .then("a")
            .something()
            .then("c")
        
        XCTAssert(tester.test("abc"), "has something between a and c")
        XCTAssert(!tester.test("ac"), "doesn't have something between a and c")
    }
    
    func testSomethingBut() {
        let tester = VerEx()
            .startOfLine()
            .then("a")
            .somethingBut("b")
            .then("c")
        
        XCTAssert(tester.test("axc"),  "has something (but b) between a and c")
        XCTAssert(!tester.test("ac"),  "doesn't have something between a and c")
        XCTAssert(!tester.test("abc"), "has no b between a and c")
    }
    
    func testLinebreak() {
        let tester = VerEx()
            .startOfLine()
            .then("abc")
            .lineBreak()
            .then("def")
        
        XCTAssert(tester.test("abc\ndef"),   "has line break between abc and def")
        XCTAssert(tester.test("abc\r\ndef"), "has line break between abc and def")
        XCTAssert(!tester.test("abcdef"),    "has no line break between abc and def")
        XCTAssert(!tester.test("abc\n def"), "has line break + space between abc and def")
    }
    
    func testBr() {
        let tester = VerEx()
            .startOfLine()
            .then("abc")
            .br()
            .then("def")
        
        XCTAssert(tester.test("abc\ndef"),   "has line break between abc and def")
        XCTAssert(tester.test("abc\r\ndef"), "has line break between abc and def")
        XCTAssert(!tester.test("abcdef"),    "has no line break between abc and def")
        XCTAssert(!tester.test("abc\n def"), "has line break + space between abc and def")
    }
    
    func testTab() {
        let tester = VerEx()
            .startOfLine()
            .then("abc")
            .tab()
            .then("def")
        
        XCTAssert(tester.test("abc\tdef"),   "has tab between abc and def")
        XCTAssert(!tester.test("abcdef"),    "has no tab between abc and def")
        XCTAssert(!tester.test("abc\t def"), "has tab + space between abc and def")
    }
    
    func testWord() {
        let tester = VerEx()
            .startOfLine()
            .then("abc")
            .word()
            .then("def")
        
        XCTAssert(tester.test("abcxyzdef"),   "has a word between abc and def")
        XCTAssert(!tester.test("abcdef"),     "has no word between abc and def")
        XCTAssert(!tester.test("abcxyz def"), "has a word + space between abc and def")
    }
    
    func testAnyOf() {
        let tester = VerEx()
            .startOfLine()
            .then("a")
            .anyOf("xyz")
        
        XCTAssert(tester.test("ax"),  "has x, y, or z after a")
        XCTAssert(tester.test("ay"),  "has x, y, or z after a")
        XCTAssert(tester.test("az"),  "has x, y, or z after a")
        XCTAssert(!tester.test("ab"), "doesn't have x, y, or z after a")
    }
    
    func testAny() {
        let tester = VerEx()
            .startOfLine()
            .then("a")
            .any("xyz")
        
        XCTAssert(tester.test("ax"),  "has x, y, or z after a")
        XCTAssert(tester.test("ay"),  "has x, y, or z after a")
        XCTAssert(tester.test("az"),  "has x, y, or z after a")
        XCTAssert(!tester.test("ab"), "doesn't have x, y, or z after a")
    }
    
    func testWithAnyCase() {
        var tester = VerEx()
            .startOfLine()
            .then("a")
        
        XCTAssert(tester.test("a"),  "tests case sensitive by default")
        XCTAssert(!tester.test("A"), "tests case sensitive by default")
        
        tester = tester.withAnyCase()
        XCTAssert(tester.test("a"),  "tests case insensitive")
        XCTAssert(tester.test("A"),  "tests case insensitive")
        
        tester = tester.withAnyCase(enabled: false)
        XCTAssert(tester.test("a"),  "tests case insensitive")
        XCTAssert(!tester.test("A"), "tests case insensitive")
    }
    
    func testSearchOneLine() {
        var tester = VerEx()
            .startOfLine()
            .then("a")
            .br()
            .then("b")
            .endOfLine()
        
        XCTAssert(tester.test("a\nb"), "b is on the second line")
        
        tester = tester.searchOneLine()
        XCTAssert(tester.test("a\nb"), "b is on the second line but we are only searching the first")
    }
    
    func testReplaceWith() {
        let tester = VerEx()
            .find("a")
        
        XCTAssertEqual(tester.replace("hallo", with: "e"), "hello", "replaces a with e")
        XCTAssertEqual(tester.replace("hallo", with: "$1"), "h$1llo", "replaces a with $1")
    }
    
    func testReplaceTemplate() {
        let tester = VerEx()
            .startOfLine()
            .then("http://")
            .beginCapture()
            .anythingBut("/")
            .endCapture()
            .endOfLine()
        
        
        XCTAssertEqual(tester.replace("http://google.com", template: "host: $1"), "host: google.com", "extracts host from URL")
    }
    
    
    func testURLExample() {
        let tester = VerEx()
            .startOfLine()
            .then("http")
            .maybe("s")
            .then("://")
            .maybe("www.")
            .anythingBut(" ")
            .endOfLine()
        
        XCTAssert(tester.test("http://www.google.com"), "matches HTTP URL")
        XCTAssert(tester.test("https://www.google.com"), "matches HTTPS URL")
        XCTAssert(tester.test("http://google.com"), "matches HTTP URL without www. part")
        XCTAssert(tester.test("https://google.com"), "matches HTTPS URL without www. part")
        XCTAssert(tester.test("https://github.com/nubbel/SwiftVerbalExpressions"), "matches invalid URL with path")
        XCTAssert(!tester.test("ws://google.com"), "doesn't match WebSocket URL")
        XCTAssert(!tester.test("http://goo gle.com"), "doesn't match invalid URL")
    }
    
    
    func testMatchOperators() {
        let tester = VerEx()
            .startOfLine()
            .then("a")
        
        XCTAssert("a"  =~ tester, "starts with an a")
        XCTAssert("ba" !~ tester, "doesn't start with an a")
    }
    
}
