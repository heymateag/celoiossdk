//
//  BalanceTest.swift
//  celo-sdk-iosTests
//
//  Created by sreedeep on 22/03/22.
//

import XCTest
import PromiseKit
import WalletConnectSwift

class BalanceTest: XCTestCase {

    override class func setUp() {
        CeloSDK.shared.initializeWalletConnect {
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddress() {
        
        firstly {
            StableTokenWrapper().getStableTokenAddress()
        }.done { address in
            XCTAssertNotNil(address)
        }
    }
    
    func testBalance() throws {
        firstly {
            CeloSDK.shared.contractKit.getStableTokenBalanceOf(currentAddress: "0x1eCbC3f2Bc6278009a9fcA2bc2Cb760D7abbbf3C")
        }.done { balance in
            XCTAssertEqual(balance, "9.0")
        }
    }
    
    func getFeeCurrency() throws {
   
            let feeCurrency = CeloSDK.shared.contractKit.getFeeCurrency()
            XCTAssertEqual(feeCurrency, "0x765DE816845861e75A25fCA122bb6898B8B1282a")
       
    }
    
    func setFeeCurrency() throws {
   //bharth please suggest
            let feeCurrency = CeloSDK.shared.contractKit.setFeeCurrency(feeCurrency: "0x765DE816845861e75A25fCA122bb6898B8B1282a")
//            XCTAssertEqual(feeCurrency, "0x765DE816845861e75A25fCA122bb6898B8B1282a")
       
    }

    
    func getGasPriceMinimumTest() throws {
        firstly {
                   CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType: .StableToken)
               }.done { gasprice in
                   XCTAssertNotNil(gasprice)
                
               }
    }
    
    func transferTokenTest() throws {
        firstly {
            CeloSDK.shared.contractKit.transfer(amount: "0.1", toAddress: "0xf80cfad2c4df551a13faaf6fe631b0ed0b71324d")
        }.done { transactionReciept in
            XCTAssertNotNil(transactionReciept)
            
        }
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    private let password = "PASSWORD123"
    
    func testAccount() {
        guard let _  = try? CeloSDK.account.generateAccount(password: password) else {
            XCTFail()
            return
        }
        
        XCTAssert(CeloSDK.account.hasAccount)
        
        guard let address = CeloSDK.account.address else {
            XCTFail()
            return
        }
        XCTAssert(address.count == 42)
        
        guard let privateKey = try? CeloSDK.account.privateKey(password: password) else {
            XCTFail()
            return
        }
        XCTAssert(privateKey.count == 64)
        
        guard let _ = try? CeloSDK.account.importAccount(privateKey: privateKey, password: password) else {
            XCTFail()
            return
        }
        
        XCTAssert(address == CeloSDK.account.address)
        
        XCTAssert(CeloSDK.account.verifyPassword(password))
        XCTAssertFalse(CeloSDK.account.verifyPassword("WRONG_PASSWORD"))
    }

}
