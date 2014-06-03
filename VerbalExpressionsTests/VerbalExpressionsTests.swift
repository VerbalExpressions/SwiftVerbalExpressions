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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStartOfLine() {
        let tester = VerEx()
            .startOfLine()
            .then("h")
        
        XCTAssert(tester.test("hello"), "starts with h")
        XCTAssert(!tester.test("bonjour"), "doesn't start with h")
    }
    
    func testEndOfLine() {
        let tester = VerEx()
            .then("o")
            .endOfLine()
        
        XCTAssert(tester.test("hello"), "ends with o")
        XCTAssert(!tester.test("bonjour"), "doesn't end with r")
    }
    
    func testThen() {
        let tester = VerEx().then("hello")
        
        XCTAssertEqual(tester.pattern, "(?:hello)", "builds pattern correctly")
        XCTAssert(tester.test("hello"), "matches string")
        XCTAssert(tester.test("hallo, hello, bonjour"), "matches part of string")
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
    
}