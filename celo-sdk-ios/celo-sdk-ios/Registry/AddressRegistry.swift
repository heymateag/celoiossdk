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
//    "0x000000000000000000000000000000000000ce10"
    static let  REGISTRY_CONTRACT_ADDRESS:String = Setting.RegistryContractAddress
//    "0x0000000000000000000000000000000000000000"
    static let  NULL_ADDRESS:String = Setting.RegistryNullAddress
    
    public init() {
        
    }
    public func getAdressForString(contractName : String) -> Promise<String>
    {
        let queue = DispatchQueue.main
        let returnPromise = Promise<String>.pending()

        print(Setting.web3url)
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Registry)
        if let ethAddress = EthereumAddress(AddressRegistry.REGISTRY_CONTRACT_ADDRESS),
           let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress),
           let cAddress = (CeloSDK.currentAccount?.address) {
            var options = ContractKitOptions.defaultOptions
//            let address = (CeloSDK.currentAccount?.address)!
            let celoAddress = EthereumAddress(cAddress)
            options.from = celoAddress
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            let method = Setting.TXActionGetAddressFor
            let datan = Data(contractName.utf8)
            if let tx = contract.read(
                method,
                parameters: [datan.sha3(.keccak256)] as [AnyObject],
                extraData: Data(),
                transactionOptions: options) {
                var stableTokenBal = ""
                    firstly {
                        tx.callPromise(transactionOptions: options)
                    }.done { tokenBalance in
                        print(tokenBalance)
                        if let addressRegistry = tokenBalance["0"] as? EthereumAddress {
                            stableTokenBal  = addressRegistry.address
                            queue.async {
                                returnPromise.resolver.fulfill(stableTokenBal)
                            }
                        } else {
                            returnPromise.resolver.reject(CeloError.conversionFailure)
                        }
                    }.catch { error in
                        print(error)
                        returnPromise.resolver.reject(error)
                    }
            } else {
                returnPromise.resolver.reject(CeloError.contractFailure)
            }
        } else {
            returnPromise.resolver.reject(CeloError.invalidAddress)
        }
        return returnPromise.promise
    }
    public func getAbiForContract(to contract:CeloContractClass) -> String {
        let parser = Parser()
        let abi = parser.getContractDetailsFor(contract:contract,requiredData:.ABI)
        
       return abi
   }
}

