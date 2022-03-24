//
//  AddressRegistry.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 17/12/21.
//

import Foundation
import web3swift
import BigInt
import PromiseKit

public class AddressRegistry {
    static let  REGISTRY_CONTRACT_ADDRESS:String = "0x000000000000000000000000000000000000ce10";
    static let  NULL_ADDRESS:String = "0x0000000000000000000000000000000000000000";
    
    public init()
    {
        
    }
    public func getAdressForString(contractName : String) -> Promise<String>
    {
        let queue = DispatchQueue.main
        let returnPromise = Promise<String>.pending()

        print(Setting.web3url)
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Registry)
        
        let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: EthereumAddress(AddressRegistry.REGISTRY_CONTRACT_ADDRESS)!)
            var options = ContractKitOptions.defaultOptions
            let address = (CeloSDK.currentAccount?.address)!
            let celoAddress = EthereumAddress(address)
            options.from = celoAddress
        options.gasPrice = TransactionOptions.GasPricePolicy.automatic
        options.gasLimit = TransactionOptions.GasLimitPolicy.automatic

            let method = "getAddressFor"
        
        let datan = Data(contractName.utf8)
        let tx = contract!.read(
            method,
            parameters: [datan.sha3(.keccak256)] as [AnyObject],
            extraData: Data(),
            transactionOptions: options)!

            var stableTokenBal = ""
                firstly {
                    try tx.callPromise(transactionOptions: options)
                }.done { tokenBalance in
                    print(tokenBalance)
                    let addressRegistry = tokenBalance["0"] as! EthereumAddress
                    stableTokenBal  = addressRegistry.address
                    queue.async {
                        returnPromise.resolver.fulfill(stableTokenBal)
                    }
                }.catch { error in
              
                                print(error)
                                }
        
        
        return returnPromise.promise
    }
    public func getAbiForContract(to contract:CeloContractClass) -> String {
        
        let parser = Parser()
        let abi = parser.getContractDetailsFor(contract:contract,requiredData:.ABI)
        
       return abi
   }
}

