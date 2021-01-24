//
//  DenizenTests.swift
//  DenizenTests
//
//  Created by J C on 2021-01-20.
//

import XCTest
@testable import Denizen

class DenizenTests: XCTestCase {
    var viewController: ViewController!
    
    override func setUp() {
        super.setUp()
        viewController = ViewController()
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
