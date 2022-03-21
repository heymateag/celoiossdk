//
//  ContractKitTests.swift
//  celo-sdk-iosTests
//
//  Created by Sreedeep on 21/03/22.
//

import XCTest
import BigInt
import PromiseKit

class ContractKitTests: XCTestCase {

    var contractKit:ContractKit!
    let currency = "usd"
    let toAddress = ""
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        contractKit = CeloSDK.shared.contractKit
        contractKit.setFeeCurrency(feeCurrency: currency)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSendRawTransacttion() {
        
        let request = CeloTransactionRequest(nonce: BigInt(1), to: toAddress, data: Data(), value: BigInt(1))
        firstly {
            contractKit.sendTransaction(transaction: request)
        }.done {hash in
            XCTAssertNotNil(hash)
        }
    }

}
