//
//  ParserTests.swift
//  celo-sdk-iosTests
//
//  Created by sreedeep on 21/03/22.
//

import XCTest

class ParserTests: XCTestCase {

    let parser = Parser()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStableTokenABI() {
        let abi = parser.getContractDetailsFor(contract: .StableToken, requiredData: .ABI)
        XCTAssertNotNil(abi)
    }
    
    func testStableAddress() {
        let address = parser.getContractDetailsFor(contract: .StableToken, requiredData: .Address)
        XCTAssertEqual(address, "")
    }
    
    func testRegistryABI() {
        let abi = parser.getABIFor(key: .Registry)
        XCTAssertNotNil(abi)
    }

}
