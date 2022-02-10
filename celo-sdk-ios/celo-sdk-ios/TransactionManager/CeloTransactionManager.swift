//
//  CeloCeloTransactionManager.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 27/12/21.
//

import BigInt
import PromiseKit
import web3swift
import Foundation
private var fetchPendingFrequency: TimeInterval = 5.0

// TODO: Change all function to Promise
class CeloTransactionManager {
    
    static let shared = CeloTransactionManager(web3: CeloSDK.shared.web3Main)
    var web3: web3!
    class func getAddress() throws -> String {
        guard let address = CeloSDK.shared.address else { throw CeloError.accountDoesNotExist }
        return address
    }

    // MARK: - Call Smart Contract
    public func transferToken(contractAddress: String,
                                         functionName: String,
                                         value: String,
                                         abi: String,
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
         
            
            guard let contract = CeloSDK.contractkit.getContractKit(web3Instance: CeloSDK.shared.web3Main, abi, at: contractAddress) else {
                seal.reject(CeloError.contractFailure)
                return
            }
            guard let amountInDouble = Double(value) else {
                seal.reject(CeloError.conversionFailure)
                return
            }
            guard let address = CeloSDK.shared.address else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
          

            guard let walletAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            let randomDouble = Int.random(in: 1592580000...1592589999)
            var options = TransactionOptions.defaultOptions
            options.gasPrice = .manual(BigUInt(randomDouble))
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
                tx.sendPromise(password: Setting.password, transactionOptions: options)

            }.done { result in
                seal.fulfill(result.hash)


            }.catch { error in
      print(error)
                seal.reject(error)
            }
        }
            
    }
    public class func writeSmartContract(contractAddress: String,
                                         functionName: String,
                                         abi: String,
                                         parameters: [Any],
                                         extraData: Data,
                                         value: BigUInt,
                                         gasPrice: GasPrice = GasPrice.average,
                                         gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                         notERC20: Bool = true) -> Promise<String> {
        return Promise<String> { seal in

            guard let address = CeloSDK.shared.address else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            guard let walletAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            guard let celoContractAddress = EthereumAddress(contractAddress) else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            guard let amountInDouble = Double(value.readableValue) else {
                seal.reject(CeloError.conversionFailure)
                return
            }

        

            guard let contract = CeloSDK.contractkit.getContractKit(web3Instance: CeloSDK.shared.web3Main, abi, at: celoContractAddress) else {
                seal.reject(CeloError.contractFailure)
                return
            }

            let gasPrice = gasPrice.wei
            var options = TransactionOptions.defaultOptions
            options.value = notERC20 ? value : nil
            options.from = walletAddress
            
            CeloTransactionManager.init(web3: CeloSDK.shared.web3Main).gasForSendingCelo(to: contractAddress, amount: value, data: Data()).done { value in
                options.gasPrice = .manual(value)
            }
        

      
            options.gasLimit = gasLimit

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
                tx.sendPromise(password: Setting.password, transactionOptions: options)
            }.done { result in
                seal.fulfill(result.hash)


            }.catch { error in

                seal.reject(error)
            }
        }
    }

    
    public func sendCeloSync(to address: String,
                              amount: BigUInt,
                              data: Data,
                              password _: String = "web3swift",
                              gasPrice: GasPrice = GasPrice.average,
                              gasLimit: TransactionOptions.GasLimitPolicy = .automatic) -> Promise<String> {
        return CeloTransactionManager.writeSmartContract(contractAddress: address,
                                                     functionName: "fallback",
                                                     abi: Web3.Utils.coldWalletABI,
                                                     parameters: [AnyObject](),
                                                     extraData: data,
                                                     value: amount,
                                                     gasPrice: gasPrice,
                                                     gasLimit: gasLimit)
    }
    public func celoBalanceSync() throws -> String {
        guard let address = CeloSDK.shared.address else { throw CeloError.accountDoesNotExist }
        guard let celoAddress = EthereumAddress(address) else { throw CeloError.invalidAddress }

        guard let balanceInWeiUnitResult = try? CeloSDK.shared.web3Main.eth.getBalance(address: celoAddress) else {
            throw CeloError.insufficientBalance
        }

        guard let balanceInEtherUnitStr = Web3.Utils.formatToEthereumUnits(balanceInWeiUnitResult,
                                                                           toUnits: .eth,
                                                                           decimals: 6, decimalSeparator: ".")
        else { throw CeloError.conversionFailure }

        return balanceInEtherUnitStr
    }

    public func celoBalance() -> Promise<String> {
        return Promise<String> { seal in
            guard let address = CeloSDK.shared.address else {
                seal.reject(CeloError.accountDoesNotExist)
                return
            }
            guard let ethereumAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            firstly {
                CeloSDK.shared.web3Main.eth.getBalancePromise(address: ethereumAddress)
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
                celoBalance()
            }.done { celoBalance in
                guard let celoBalanceInDouble = Double(celoBalance) else {
                    seal.reject(CeloError.conversionFailure)
                    return
                }
                if notERC20 {
                    guard celoBalanceInDouble >= amountInDouble else {
                        seal.reject(CeloError.insufficientBalance)
                        return
                    }
                }
                seal.fulfill(true)
            }
        }
    }



    public class func readSmartContract(contractAddress: String,
                                        functionName: String,
                                        abi: String, parameters: [Any],
                                        value: String = "0.0") -> Promise<[String: Any]> {
        return Promise<[String: Any]> { seal in

            guard let address = CeloSDK.shared.address else {
                throw CeloError.invalidAddress
            }

            guard let walletAddress = EthereumAddress(address) else {
                throw CeloError.invalidAddress
            }

            guard let contractAddress = EthereumAddress(contractAddress) else {
                throw CeloError.invalidAddress
            }

            let abiVersion = 2
            let extraData: Data = Data()
            let contract = CeloSDK.contractkit.getContractKit(web3Instance: CeloSDK.shared.web3Instance, abi, at: contractAddress)
            let amount = Web3.Utils.parseToBigUInt(value, units: .eth)

            var options = TransactionOptions.defaultOptions
            options.value = value == "0.0" ? nil : amount
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            guard let tx = contract!.read(
                functionName,
                parameters: parameters as [AnyObject],
                extraData: extraData,
                transactionOptions: options
            ) else {
                throw CeloError.contractFailure
            }

            firstly {
                tx.callPromise()
            }.done { result in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }



    // MARK: - Sign chainId Transaction

    func transfer(toAddress: String, value: BigUInt, data: Data = Data(),
                  gasPrice: GasPrice = GasPrice.average,
                  gasLimit: TransactionOptions.GasLimitPolicy = .automatic) -> Promise<String> {
        return Promise<String> { seal in

            var method: Promise<String>?
         
            method = CeloTransactionManager.shared.sendCeloSync(to: toAddress, amount: value,
                                                                 data: data,
                                                                 gasPrice: gasPrice,
                                                                 gasLimit: gasLimit)
          
         

            guard let block = method else {
                throw CeloError.insufficientBalance
            }

            block.done { txHash in
                seal.fulfill(txHash)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    // MARK: - Sign Send Transaction
    class func signTransaction(to address: String,
                               amount: BigUInt,
                               data: Data,
                               detailObject: Bool = false,
                               gasPrice: GasPrice = GasPrice.average) throws -> String {
        guard let toAddress = EthereumAddress(address) else {
            throw CeloError.invalidAddress
        }

        guard let address = CeloSDK.shared.address else {
            throw CeloError.invalidAddress
        }

        guard let walletAddress = EthereumAddress(address) else {
            throw CeloError.invalidAddress
        }
                var celoBalance =  "0"
        CeloSDK.balance.getCeloBalance { balance in
            celoBalance = balance ?? "0"
                       }
        
        guard let etherBalanceInDouble = Double(celoBalance) else {
            throw CeloError.conversionFailure
        }

        guard let amountInDouble = Double(amount.readableValue) else {
            throw CeloError.conversionFailure
        }

        guard etherBalanceInDouble >= amountInDouble else {
            throw CeloError.notEnoughBalance
        }
                guard let keystore = try? CeloSDK.shared.loadKeystore() else { return "" }
     
         
        let gasPrice = gasPrice.wei
        let value = amount
        var options = TransactionOptions.defaultOptions
        options.value = value
        options.from = walletAddress
        options.gasPrice = .manual(gasPrice)
        options.gasLimit = .automatic

        var tx = EthereumTransaction(to: toAddress, data: data, options: options)
        do {
            try Web3Signer.signTX(transaction: &tx,
                                  keystore: keystore,
                                  account: walletAddress,
                                  password: "celosdk")



               
            
            return (tx.encode(forSignature: false, chainID: nil)?.toHexString().addHexPrefix())!
        } catch {
            CeloError.contractFailure
        }

        return "Sign Transaction Failed"
    }


 
  
}





