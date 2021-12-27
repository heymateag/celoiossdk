//
//  CeloTransactionManager.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 27/12/21.
//

import BigInt
import PromiseKit
import web3swift
import Foundation

// TODO: Change all function to Promise
class CeloTransactionManager {
    static let shared = CeloTransactionManager()

    class func getAddress() throws -> String {
        guard let address = CeloSDK.shared.address else { throw CeloError.accountDoesNotExist }
        return address
    }

    // MARK: - Call Smart Contract

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

            guard let contractAddress = EthereumAddress(contractAddress) else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            guard let amountInDouble = Double(value.readableValue) else {
                seal.reject(CeloError.conversionFailure)
                return
            }

        

            guard let contract = CeloSDK.contractkit.getContractKit(web3Instance: CeloSDK.shared.web3Main, abi, at: contractAddress) else {
                seal.reject(CeloError.contractFailure)
                return
            }

            let gasPrice = gasPrice.wei
            var options = TransactionOptions.defaultOptions
            options.value = notERC20 ? value : nil
            options.from = walletAddress
            options.gasPrice = .manual(gasPrice)
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

    // MARK: - Sign Message

  

//    class func signMessage(message: Data) throws -> String? {
//        guard let address = CeloSDK.shared.address else {
//            throw CeloError.invalidAddress
//        }
//
//        guard let walletAddress = EthereumAddress(address) else {
//            throw CeloError.invalidAddress
//        }
//
//        guard let keystore = CeloSDK.shared.address else {
//            throw CeloError.malformedKeystore
//        }
//      
//        do {
//            
//         
//            let signedData = try Web3Signer.signPersonalMessage(message,
//                                                                keystore: keystore,
//                                                                account: walletAddress,
//                                                                password: "celosdk")
//            return (signedData?.toHexString().addHexPrefix())!
//        } catch {
//            throw CeloError.invalidKey
//        }
//    }

    // MARK: - Sign Transaction



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

