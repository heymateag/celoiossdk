//
//  StableTokenWrapper.swift
//  celo-sdk-ios
//
//  Created by Apple on 20/03/22.
//

import Foundation
import web3swift
import PromiseKit
import BigInt

//todo why its public so all methods
public struct StableTokenWrapper
{
    public init(){
        
    }
    public func balanceOf(accountOwner: String) -> Promise<String> {
        let queue = DispatchQueue.main
        print(Setting.web3url)
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.StableToken)
        let returnPromise = Promise<String>.pending()
        if let ethAddress = EthereumAddress(CeloSDK.shared.contractKit.getFeeCurrency()),
           let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress){
            var options = ContractKitOptions.defaultOptions
            let address = accountOwner
            let celoAddress = EthereumAddress(address)
            options.from = celoAddress
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            if let tx = contract.read(
                STABLE_TOKEN.FUNCTION_BALANCE_OF,
                parameters: [accountOwner] as [AnyObject],
                extraData: Data(),
                transactionOptions: options) {
                var stableTokenBal = ""
                firstly {
                    tx.callPromise(transactionOptions: options)
                }.done { tokenBalance in
                    print(tokenBalance)
                    if let balanceBigUInt = tokenBalance["0"] as? BigUInt,
                       let balanceString = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3) {
                        stableTokenBal = balanceString
                        queue.async {
                            returnPromise.resolver.fulfill(stableTokenBal)
                        }
                    } else {
                        queue.async {
                            returnPromise.resolver.reject(CeloError.conversionFailure)
                        }
                    }
                }.catch { error in
                    returnPromise.resolver.reject(error)
                }
            }
        } else {
            returnPromise.resolver.reject(CeloError.contractFailure)
        }
        
//        let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: EthereumAddress(CeloSDK.shared.contractKit.getFeeCurrency())!)
//
//            let tx = contract!.read(
//                STABLE_TOKEN.FUNCTION_BALANCE_OF,
//                parameters: [accountOwner] as [AnyObject],
//                extraData: Data(),
//                transactionOptions: options)!
//
//                var stableTokenBal = ""
//
//
//                    firstly {
//                        try tx.callPromise(transactionOptions: options)
//                    }.done { tokenBalance in
//                        print(tokenBalance)
//                        let balanceBigUInt = tokenBalance["0"] as! BigUInt
//                                        let balanceString = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3)!
//                        stableTokenBal = balanceString
//
//                        queue.async {
//                            returnPromise.resolver.fulfill(stableTokenBal)
//                        }
//                    }
        return returnPromise.promise
    }
    

    public func transfer(amount: String,toAddress :String) -> Promise<String> {
        let retunrPromise = Promise<String>.pending()
        firstly {
            getStableTokenAddress()
        }.done { address in
            firstly {
                CeloTransactionManager.shared.transferToken(contractAddress: address, functionName: STABLE_TOKEN.FUNCTION_TOKEN_TRANSFER, value: amount, toAddress: toAddress)
            }.done { hash in
                retunrPromise.resolver.fulfill(hash)
            }
        }.catch { error in
            retunrPromise.resolver.reject(error)
        }
        return retunrPromise.promise
    }
    
    
    public func getStableTokenAddress() -> Promise<String> {
        
        
        return Promise {seal in
            if let address = Configuration.getStableTokenAddress(),!address.isEmpty {
                CeloSDK.shared.contractKit.setFeeCurrency(feeCurrency: address)
                seal.fulfill(address)
            } else {
                firstly {
                    AddressRegistry.init().getAdressForString(contractName: CeloContractClass.StableToken.rawValue)
                }.done { address in
                    CeloSDK.shared.contractKit.setFeeCurrency(feeCurrency: address)
                    seal.fulfill(address)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}


