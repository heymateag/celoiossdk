//
//  StableTokenwrapperTests.swift
//  celo-sdk-iosTests
//
//  Created by Sreedeep on 21/03/22.
//

import XCTest
import celo_sdk_ios
import PromiseKit

class StableTokenwrapperTests: XCTestCase {

    let testOwner = ""
    let transferToAddress = ""
    var currentAddress:String = ""
    let wrapper = StableTokenWrapper.init()
    let transferAmount = "0.1"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        currentAddress = CeloSDK.currentAccount?.address ?? ""
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCeloBalance() {
        firstly {
            wrapper.balanceOf(accountOwner: testOwner)
        }.done { balance in
            XCTAssertNotNil(balance)
        }
    }
    
    func testTransferToken() {
        if !currentAddress.isEmpty {
            firstly {
                wrapper.transfer(amount: transferAmount, toAddress: transferToAddress)

            }.done { hash in
                XCTAssertNotNil(hash)
            }
        }
    }
}
