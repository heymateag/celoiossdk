//
//  AttestationTest.swift
//  celo-sdk-ios
//
//  Created by Apple on 11/06/22.
//

import XCTest
import PromiseKit

class AttestationStatTest: XCTestCase {



    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    func testAttestationStat() throws {
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
        }
    }
    
    func testGetAttestationExpiryBlocks() {
        firstly {
            wrapper.getAttestationExpiryBlocks()
        }.done { result in
            let blocks = result
        }
    }
    
    func testGetAttestationRequestFee() {
        firstly {
            let token = "sometoken"
            wrapper.getAttestationRequestFee(token: token)
        }.done { result in
            let fee = result
        }
    }
    
    func testSelectIssuersWaitBlocks() {
        firstly {
            wrapper.selectIssuersWaitBlocks()
        }.done { result in
            let blocks = result
        }
    }

    

}
