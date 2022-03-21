//
//  GasPriceMinimumWrapper.swift
//  celo-sdk-ios
//
//  Created by Apple on 20/03/22.
//

import Foundation
import web3swift
import PromiseKit
import BigInt

public struct GasPriceMinimumWrapper
{
    public func balanceOf(accountOwner: String) -> Promise<BigUInt>
    {
        
        let returnPromise = Promise<BigUInt>.pending()
Configuration.changeEnvironment(isProduction: true)
print(Setting.web3url)
let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.GasPriceMinimum)


let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: EthereumAddress("0x765de816845861e75a25fca122bb6898b8b1282a")!)
var options = ContractKitOptions.defaultOptions
let address = (CeloSDK.currentAccount?.address)!
let celoAddress = EthereumAddress(address)
options.from = celoAddress
options.gasPrice = .automatic
options.gasLimit = .automatic

let method = "getGasPriceMinimum"


let tx = contract!.write(
 method,
 parameters: ["0x765de816845861e75a25fca122bb6898b8b1282a"] as [AnyObject],
 extraData: Data(),
 transactionOptions: options)!
//        let tx = contract!.read(
//            method,
//            parameters: ["0x765de816845861e75a25fca122bb6898b8b1282a"] as [AnyObject],
//            extraData: Data(),
//            transactionOptions: options)!
        let randomDouble = Int.random(in: 1592580000...1592589999)
        
        var stableTokenBal = BigUInt(randomDouble)
firstly {
tx.sendPromise(password: "web3swift", transactionOptions: options)
}.done { tokenBalance in
print(tokenBalance)
    returnPromise.resolver.fulfill(BigUInt(randomDouble))

}.catch { error in
let randomDouble = Int.random(in: 1592580000...1592589999)
var options = TransactionOptions.defaultOptions
options.gasPrice = .manual(BigUInt(randomDouble))
options.gasLimit = .manual(10000000)
    returnPromise.resolver.reject(error)
print(error)
}
//        return stableTokenBal
        return returnPromise.promise
    }
    
    
}
