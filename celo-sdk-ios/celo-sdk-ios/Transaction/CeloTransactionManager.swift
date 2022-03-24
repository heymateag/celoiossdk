//
//  TransactionManager.swift
//   
//
//    .
//   . All rights reserved.
//

import BigInt
import PromiseKit
//import SPStorkController
import UIKit
import web3swift
import HandyJSON

// TODO: Change all function to Promise
public class CeloTransactionManager {
    public static let shared = CeloTransactionManager()
    
    // MARK: - Smart Contract Popup
    
    
    
    
    class func getAddress() throws -> String {
        guard let address = CeloSDK.currentAccount?.address else { throw CeloError.accountDoesNotExist }
        return address
    }

    
    
    // MARK: - Call Smart Contract

  
    public func transferToken(contractAddress: String,
                              functionName: String,
                              value: String,
                              toAddress:String,notERC20: Bool = true
    ) -> Promise<String> {
        
        return Promise<String> { seal in
            guard let contractAddress = EthereumAddress(contractAddress) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
            guard let toAddress = EthereumAddress(toAddress) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
    

            let jsonString = Parser().getABIFor(key: .StableToken)
            
            guard let contract = CeloSDK.web3Net.contract(jsonString, at: contractAddress, abiVersion: 2) else {
                seal.reject(CeloError.contractFailure)
                return
            }
            guard let address = CeloSDK.currentAccount?.address else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
            
            
            guard let walletAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
            firstly {
                CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType: .StableToken)
            }.done { gasprice in
                
             print(gasprice)

                var options = TransactionOptions.defaultOptions

                options.gasPrice = .manual(gasprice)
                options.gasLimit = .manual(10000000)
                options.value = Web3.Utils.parseToBigUInt("0", units: .eth)
                options.from = walletAddress
                
                
                let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
                
                guard let tx = contract.write(
                    functionName,
                    parameters: [toAddress, amount as Any] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options)
                else {
                    seal.reject(CeloError.contractFailure)
                    return
                }
                
                firstly {
                    tx.sendPromise(password: "web3swift", transactionOptions: options)
                }.done { result in
                    seal.fulfill(result.hash)
                    
                    
                }.catch { error in
                    print(error)
                    seal.reject(error)
                }
            }
            
      
        }
        
    }
    // MARK: - Send Transaction
    public class func sendTransactionRequest(contractAddress: String,
                                         functionName: String,
                                         abi: String,
                                         parameters: [Any],
                                         extraData: Data,
                                         value: BigUInt,
                                         gasPrice: GasPrice = GasPrice.average,
                                         gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                         notERC20: Bool = true) -> Promise<String> {
        return Promise<String> { seal in
            
            guard let address = CeloSDK.currentAccount?.address else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
            guard let walletAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
            guard let contractAddress = EthereumAddress(contractAddress) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
            guard let amountInDouble = Double(value.readableValue) else {
                seal.reject(CeloError.conversionFailure)
                return
            }
            
            guard let _ = CeloSDK.web3Net.provider.attachedKeystoreManager else {
                seal.reject(CeloError.malformedKeystore)
                return
            }
            
            guard let contract = CeloSDK.web3Net.contract(abi, at: contractAddress, abiVersion: 2) else {
                seal.reject(CeloError.contractFailure)
                return
            }
            

            var options = TransactionOptions.defaultOptions
            options.value = notERC20 ? value : nil
            options.to = contractAddress
            options.from = walletAddress
            
            options.gasLimit = .manual(10000000)
            firstly {
                CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType: .StableToken)
            }.done { gasprice in
                print(gasprice)

                options.gasPrice = .manual(gasprice)
                print(options)
                
                guard let tx = contract.write(
                    functionName,
                    parameters: parameters as [AnyObject],
                    extraData: extraData,
                    transactionOptions: options
                ) else {
                    seal.reject(CeloError.contractFailure)
                    return
                }
                
                firstly {
                    CeloTransactionManager.shared.checkBalance(amountInDouble: amountInDouble, notERC20: notERC20)
                }.then { _ in
                    tx.sendPromise(password: "web3swift", transactionOptions: options)
                }.done { result in
                    seal.fulfill(result.hash)
                    
                    
                }.catch { error in
                    
                    seal.reject(error)
                }
            }
            

           
        }
    }
    
    // MARK: - Sign Transaction
    class func signNewTransaction(to address: String,
                                   amount: BigUInt,
                                   data: Data,
                                   detailObject: Bool = false) -> Promise<String> {

            return Promise {seal in

                guard let toAddress = EthereumAddress(address) else {

                    throw CeloError.invalidAddress

                }

                guard let address = CeloSDK.currentAccount?.address else {

                    throw CeloError.invalidAddress

                }



                guard let walletAddress = EthereumAddress(address) else {

                    throw CeloError.invalidAddress

                }



                let etherBalance = try CeloTransactionManager.shared.etherBalanceSync()

                guard let etherBalanceInDouble = Double(etherBalance) else {

                    throw CeloError.conversionFailure

                }



                guard let amountInDouble = Double(amount.readableValue) else {

                    throw CeloError.conversionFailure

                }



                guard etherBalanceInDouble >= amountInDouble else {

                    throw CeloError.insufficientBalance

                }



                guard let keystore = CeloSDK.web3Net.provider.attachedKeystoreManager else {

                    throw CeloError.malformedKeystore

                }





                let value = amount

                var options = TransactionOptions.defaultOptions

                options.value = value

                options.to = toAddress

                options.from = walletAddress
                firstly {
                    CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType: .StableToken)
                }.done { gasprice in
                    print(gasprice)
                    options.gasPrice = .manual(gasprice)

                    options.gasLimit = .manual(10000000)

                    print("######### my transaction options ######")

                    print(options)
                    var tx = EthereumTransaction(to: toAddress, data: data, options: options)

                    do {

                        try Web3Signer.signTX(transaction: &tx,

                                              keystore: keystore,

                                              account: walletAddress,

                                              password: Setting.password)



                        print("######### tx.toJsonString ###########")

                        print(tx.toJsonString())

            

                        if detailObject {

                            return seal.fulfill(tx.toJsonString())

                        }

                        return seal.fulfill((tx.encode(forSignature: false, chainID: nil)?.toHexString().addHexPrefix())!)



                    } catch {

                        HUDManager.shared.showError()

                    }



                    return seal.reject(CeloError.custom("Sign Transaction Failed"))
                    
                }

               

            }

        }



    public func etherBalanceSync() throws -> String {
        guard let address = CeloSDK.currentAccount?.address else { throw CeloError.accountDoesNotExist }
        guard let ethereumAddress = EthereumAddress(address) else { throw CeloError.invalidAddress }

        guard let balanceInWeiUnitResult = try? CeloSDK.web3Net.eth.getBalance(address: ethereumAddress) else {
            throw CeloError.insufficientBalance
        }

        guard let balanceInEtherUnitStr = Web3.Utils.formatToEthereumUnits(balanceInWeiUnitResult,
                                                                           toUnits: .eth,
                                                                           decimals: 6, decimalSeparator: ".")
        else { throw CeloError.conversionFailure }

        return balanceInEtherUnitStr
    }
    public func sendEtherSync(to address: String,
                              amount: BigUInt,
                              data: Data,
                              password _: String = "web3swift",
                              gasPrice: GasPrice = GasPrice.average,
                              gasLimit: TransactionOptions.GasLimitPolicy = .automatic) -> Promise<String> {
        return CeloTransactionManager.sendTransactionRequest(contractAddress: address,
                                                     functionName: "fallback",
                                                     abi: Web3.Utils.coldWalletABI,
                                                     parameters: [AnyObject](),
                                                     extraData: data,
                                                     value: amount,
                                                     gasPrice: gasPrice,
                                                     gasLimit: gasLimit)
    }

    
    public func etherBalance() -> Promise<String> {
        return Promise<String> { seal in
            guard let address = CeloSDK.currentAccount?.address else {
                seal.reject(CeloError.accountDoesNotExist)
                return
            }
            guard let ethereumAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
            firstly {
                CeloSDK.web3Net.eth.getBalancePromise(address: ethereumAddress)
            }.done { balanceInWeiUnitResult in
                guard let balanceInEtherUnitStr = Web3.Utils.formatToEthereumUnits(balanceInWeiUnitResult,
                                                                                   toUnits: .eth,
                                                                                   decimals: 6, decimalSeparator: ".")
                else {
                    seal.reject(CeloError.conversionFailure)
                    return
                }
                seal.fulfill(balanceInEtherUnitStr)
            }
        }
        
    }
    
    // MARK: - Send Transaction
    
    func checkBalance(amountInDouble: Double, notERC20: Bool) -> Promise<Bool> {
        return Promise { seal in
            // TODO: Add ERC20 Blanace Check
            if !notERC20 {
                seal.fulfill(true)
            }
            
            firstly {
                etherBalance()
            }.done { etherBalance in
                guard let etherBalanceInDouble = Double(etherBalance) else {
                    seal.reject(CeloError.conversionFailure)
                    return
                }
                if notERC20 {
                    guard etherBalanceInDouble >= amountInDouble else {
                        seal.reject(CeloError.insufficientBalance)
                        return
                    }
                }
                seal.fulfill(true)
            }
        }
    }
    
    
    
    // MARK: - Sign Transaction
    
    
    
}

class GasPriceHelper {
    static let shared = GasPriceHelper()
    var timeInterval: TimeInterval = 60 * 30
    

    
    var safeLow: Float?
    var average: Float?
    var fast: Float?
    
    // Minutes
    var safeLowWait: Float?
    var avgWait: Float?
    var fastWait: Float?
    

 
}

public class PriceHelper {
    static let shared = PriceHelper()

    var exchangeRate: Float = 0
}
public enum GasPrice {
    case fast
    case average
    case slow
    case custom(BigUInt)
    
    // TODO: FIX Custom
    
    // GWei
    public  var price: Float {
        switch self {
        case .fast:
            return GasPriceHelper.shared.fast ?? 10
        case .average:
            return GasPriceHelper.shared.average ?? 3
        case .slow:
            return GasPriceHelper.shared.safeLow ?? 1
        case let .custom(wei):
            guard let str = Web3.Utils.formatToEthereumUnits(wei, toUnits: .Gwei, decimals: 18, decimalSeparator: ".") else {
                return GasPriceHelper.shared.average ?? 3
            }
            return Float(str)!
        }
    }
    
    var time: Float {
        switch self {
        case .fast:
            return GasPriceHelper.shared.fastWait ?? 1
        case .average:
            return GasPriceHelper.shared.avgWait ?? 3
        case .slow:
            return GasPriceHelper.shared.safeLowWait ?? 10
        case .custom:
            return GasPriceHelper.shared.avgWait ?? 3
        }
    }
    
    var wei: BigUInt {
        // GWei to wei 9
        switch self {
        case .fast, .average, .slow:
            let wei = self.price * pow(10, 9)
            return BigUInt(wei)
        case let .custom(wei):
            return wei
        }
    }
    
    var timeString: String {
        return "~ \(self.time) mins"
    }
    
    var option: String {
        switch self {
        case .fast:
            return "fast"
        case .slow:
            return "slow"
        case .average:
            return "average"
        case let .custom(gas):
            return String(gas, radix: 16)
        }
    }
    
    static func make(string: String) -> GasPrice? {
        switch string {
        case "fast":
            return GasPrice.fast
        case "slow":
            return GasPrice.slow
        case "average":
            return GasPrice.average
        default:
            if let gasPrice = BigUInt(string.stripHexPrefix(), radix: 16) {
                return .custom(gasPrice)
            }
            return nil
        }
    }

}







