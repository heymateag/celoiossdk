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
    public func balanceOf(accountOwner: String) -> Promise<String>
    {
        let queue = DispatchQueue.main
        Configuration.changeEnvironment(isProduction: true)
        print(Setting.web3url)
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.StableToken)
        
        let returnPromise = Promise<String>.pending()
        
        
        let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: EthereumAddress("0x765de816845861e75a25fca122bb6898b8b1282a")!)
            var options = ContractKitOptions.defaultOptions
            let address = accountOwner
            let celoAddress = EthereumAddress(address)
            options.from = celoAddress
        options.gasPrice = TransactionOptions.GasPricePolicy.automatic
        options.gasLimit = TransactionOptions.GasLimitPolicy.automatic

            let method = "balanceOf"
    //            var tokenBalance : [String: Any]!
        let tx = contract!.read(
            method,
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

        return returnPromise.promise

//      return stableTokenBal
    }
    

    public func transfer(amount: String,toAddress :String) -> Promise<String> {
        return CeloTransactionManager.shared.transferToken(contractAddress: "0x765de816845861e75a25fca122bb6898b8b1282a", functionName: "transfer", value: amount, toAddress: toAddress)
    }
    
}

