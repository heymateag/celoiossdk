//
//  celo_sdk_iosTests.swift
//  celo-sdk-iosTests
//
//  Created by Sreedeep on 02/11/21.
//

import XCTest
import BigInt
import CryptoSwift
@testable import celo_sdk_ios

class celo_sdk_iosTests: XCTestCase {

   
    func testGetKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
        guard let data = NSData(contentsOfFile: path) else {return nil}
        return data as Data
    }
     func testSaveDefaultKeystore(_ password: String) throws -> KeystoreManager?{
        let keystore = try! EthereumKeystoreV3(password: password);
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        print(account)
        let data = try! keystore!.serialize()
        print(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue:0)))
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: password, account: account)
        XCTAssertNotNil(key)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSaveKeystore(_ keystore: BIP32Keystore) throws {
        
        let mnemonic = "test mnemonic bip32"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "", prefixPath: "44")
        XCTAssertNotNil(keystore)
        XCTAssertEqual(keystore!.addresses?.count, 1)
        try! keystore?.createNewCustomChildAccount(password: "", path: "/0/1")
        XCTAssertEqual(keystore?.addresses?.count, 2)
        let data = try! keystore?.serialize()
        let recreatedStore = BIP32Keystore.init(data!)
        XCTAssert(keystore?.addresses?.count == recreatedStore?.addresses?.count)
        XCTAssert(keystore?.rootPrefix == recreatedStore?.rootPrefix)
        print(keystore!.addresses![0].address)
        print(keystore!.addresses![1].address)
        print(recreatedStore!.addresses![0].address)
        print(recreatedStore!.addresses![1].address)
        XCTAssert(keystore?.addresses![1] == recreatedStore?.addresses![1])
        XCTAssert(keystore?.addresses![0] == recreatedStore?.addresses![0])
  
    }
    
    
    func testFetchAccountsDetails() {
        let keystore = try! EthereumKeystoreV3(password: "");
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        print(account)
        let data = try! keystore!.serialize()
        print(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue:0)))
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testFetchAccountBalance() throws {
        guard let urlStr = URL(string: "https://alfajores-forno.celo-testnet.org") else { return }

              do {
                let web3 = try Web3.new(urlStr)
                let w3sTokenAddress = EthereumAddress("0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1")!
                let erc20token = ERC20.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
                let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
                let balance = try erc20token.getBalance(account: userAddress)
                let allowance = try erc20token.getAllowance(originalOwner: userAddress, delegate: userAddress)
                XCTAssert(String(balance) == "1024000000000000000000")
                XCTAssert(allowance == 0)
                  
              } catch {
                  //handle error
                  print(error)
              }
      
    }
    func testFetchGasPriceBalance() throws {
        guard let keystoreData = getKeystoreData() else {return XCTFail()}
        guard let keystoreV3 = EthereumKeystoreV3.init(keystoreData) else {return XCTFail()}
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        let keystoreManager = KeystoreManager.init([keystoreV3])
        web3Rinkeby.addKeystoreManager(keystoreManager)
        let gasPriceRinkeby = try web3Rinkeby.eth.getGasPrice()
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        guard let writeTX = web3Rinkeby.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
        writeTX.transactionOptions.from = keystoreV3.addresses?.first
        writeTX.transactionOptions.gasPrice = .manual(gasPriceRinkeby * 2)
        let gasEstimate = try writeTX.estimateGasPromise().wait()
        writeTX.transactionOptions.gasLimit = .manual(gasEstimate + 1234)
        let assembled = try writeTX.assemblePromise().wait()
        XCTAssert(assembled.gasLimit == gasEstimate + 1234)
        XCTAssert(assembled.gasPrice == gasPriceRinkeby * 2)
    }
    func testPrivateKeyCreation()
    {
        let privKey = SECP256K1.generatePrivateKey()
        XCTAssert(privKey != nil, "Failed to create new private key")
    }


}
