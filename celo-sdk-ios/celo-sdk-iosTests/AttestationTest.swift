//
//  AttestationTest.swift
//  celo-sdk-ios
//
//  Created by Apple on 11/06/22.
//

import XCTest
import PromiseKit
import BigInt

//TODO :- Once we get the end result ,
class AttestationStatTest: XCTestCase {
    let wrapper:AttestationsWrapper!
    override func setUpWithError() throws {
        wrapper = AttestationsWrapper.init()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAttestaationStat() throws {
        let wrapper = AttestationsWrapper.init()
        firstly {
            let request = "sampleData"
            let account = CeloSDK.account.address
            let data = request.data(using: .utf8)
            wrapper.getAttestationStats(identifier: data, account: account)
        }.done { result in
            XCTAssertEqual(result.completed, 1)
        }.
    }

    func testGetCompletableAttestations() {
        let wrapper = AttestationsWrapper.init()
        firstly {
            let request = "sampleData"
            let account = CeloSDK.account.address
            let data = request.data(using: .utf8)
            wrapper.getCompletableAttestations(identifier: data, account: account)
        }.done { result in
            let blockNums = result.blockNumbers
            let issuers = result.issuers
            let whereToBreakTheString = result.whereToBreakTheString
            let metadataURLs = result.metadataURLs
            XCTAssertTrue(blockNums.count > 0)
            
        }
    }
    
    func testLookupAccountForIdentifier() {
        let wrapper = AttestationsWrapper.init()
        firstly {
            let identifier = "identifier"
            let data = identifier.data(using: .utf8)
            wrapper.lookupAccountsForIdentifier(identifier: data)
        }.done { result in
            let identifierResults = result
            XCTAssertNotNil(identifierResults)
        }
    }
    
    func testGetUnselectedRequest() {
        firstly {
            let identifier = "identifier"
            let data = identifier.data(using: .utf8)
            let account = CeloSDK.account.address
            wrapper.getUnselectedRequest(identifier: data, account: account)
        }.done { result in
            let block = result.blockNumber
            let attestationsRequested = result.attestationsRequested
            let attestationRequestFeeToken = result.attestationRequestFeeToken
            XCTAssertEqual(attestationRequestFeeToken, "sometoken")
            XCTAssertEqual(attestationsRequested, 0)
        }
    }
    
    func testGetAttestationExpiryBlocks() {
        firstly {
            wrapper.getAttestationExpiryBlocks()
        }.done { result in
            let blocks = result
            XCTAssertEqual(result, 1)
        }
    }
    
    func testGetAttestationRequestFee() {
        firstly {
            let token = "sometoken"
            wrapper.getAttestationRequestFee(token: token)
        }.done { result in
            let fee = result
            XCTAssertEqual(fee, 1)
        }
    }
    
    func testSelectIssuersWaitBlocks() {
        firstly {
            wrapper.selectIssuersWaitBlocks()
        }.done { result in
            let blocks = result
            XCTAssertEqual(blocks, 1)
        }
    }
    
    func testValidateAttestationCode() {
        firstly {
            let identifier = "identifier"
            let data = identifier.data(using: .utf8)
            let account = CeloSDK.account.address
            let v = 0
            let r = ""
            let rData = r.data(using: .utf8)
            let s = ""
            let sData = s.data(using: .utf8)
            wrapper.validateAttestationCode(identifier: data, account: account, v: v, r: rData, s: sData)
        }.done { result in
            XCTAssertEqual(result, "som value")
        }
    }
    
    func testComplete() {
        firstly {
            let identifier = "identifier"
            let data = identifier.data(using: .utf8)
            let v = 0
            let r = ""
            let rData = r.data(using: .utf8)
            let s = ""
            let sData = s.data(using: .utf8)
            wrapper.complete(identifier: data, v: v, r: rData, s: sData)
        }.done { result in
            XCTAssertEqual(result, "som value")
        }
    }
    
    func testSelectIssuers() {
        firstly {
            let identifier = "identifier"
            let data = identifier.data(using: .utf8)
            wrapper.selectIssuers(identifier: data)
        }.done { result in
            XCTAssertEqual(result, "som value")
        }
    }
    
    func testRequest() {
        firstly {
            let identifier = "identifier"
            let data = identifier.data(using: .utf8)
            let attRequest = 0
            let attFeeToken = ""
            wrapper.request(identifier: data, attestationsRequested: attRequest, attestationRequestFeeToken: attFeeToken)
        }.done { result in
            XCTAssertEqual(result, "som value")
        }
    }
    
}
