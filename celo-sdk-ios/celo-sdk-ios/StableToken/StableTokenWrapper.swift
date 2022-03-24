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

public struct StableTokenWrapper
{
    public init()
    {}
    public func balanceOf(accountOwner: String) -> Promise<String>
    {
        let queue = DispatchQueue.main
//        Configuration.changeEnvironment(isProduction: true)
        print(Setting.web3url)
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.StableToken)
        
        let returnPromise = Promise<String>.pending()
        
        let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: EthereumAddress(CeloSDK.shared.contractKit.getFeeCurrency())!)
                var options = ContractKitOptions.defaultOptions
                let address = accountOwner
                let celoAddress = EthereumAddress(address)
                options.from = celoAddress
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            let tx = contract!.read(
                STABLE_TOKEN.FUNCTION_BALANCE_OF,
                parameters: [CeloSDK.currentAccount?.address] as [AnyObject],
                extraData: Data(),
                transactionOptions: options)!

                var stableTokenBal = ""
           

                    firstly {
                        try tx.callPromise(transactionOptions: options)
                    }.done { tokenBalance in
                        print(tokenBalance)
                        let balanceBigUInt = tokenBalance["0"] as! BigUInt
                                        let balanceString = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3)!
                        stableTokenBal = balanceString
                        
                        queue.async {
                            returnPromise.resolver.fulfill(stableTokenBal)
                        }

                //                        print(balanceString)
                    }
//        }
        return returnPromise.promise

//      return stableTokenBal
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

            }

            return retunrPromise.promise

        }
    
    
public func getStableTokenAddress() -> Promise<String> {

    
    return Promise {seal in

        if let address = UserDefaults.standard.value(forKey: "STABLE_TOKEN_ADDRESS") as? String,!address.isEmpty {
            CeloSDK.shared.contractKit.setFeeCurrency(feeCurrency: address)
            seal.fulfill(address)

        } else {
//            seal.fulfill(true)
            firstly {
                AddressRegistry.init().getAdressForString(contractName: CeloContractClass.StableToken.rawValue)
            }.done { address in
                CeloSDK.shared.contractKit.setFeeCurrency(feeCurrency: address)
                seal.fulfill(address)
            }
        }
    }
    
            

//            return returnPromsie.promise

        }
    
    
}


