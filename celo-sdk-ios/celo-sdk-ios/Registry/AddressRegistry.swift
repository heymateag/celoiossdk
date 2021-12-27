//
//  AddressRegistry.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 17/12/21.
//

import Foundation
import web3swift
import BigInt

public class AddressRegistry {
    static let  REGISTRY_CONTRACT_ADDRESS:String = "0x000000000000000000000000000000000000ce10";
    static let  NULL_ADDRESS:String = "0x0000000000000000000000000000000000000000";
    
    var web3: web3
    public init (web3 web3Instance: web3) {
     
        self.web3 = web3Instance
        

    }
       
    
    public func addressFor(contract:CeloContract)->String {
        let contractCeloAddress = EthereumAddress(AddressRegistry.REGISTRY_CONTRACT_ADDRESS)
        let bundlePath = Bundle.main.path(forResource: "registry_cntracts", ofType: "json")
        let jsonString = try! String(contentsOfFile: bundlePath!)

        do {
            let contract = CeloSDK.shared.newKitFromWeb3(_web3InstanceFromUrl:web3 )
            var options = TransactionOptions.defaultOptions
            options.from = contractCeloAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            let method = "getAddressFor"
            let tx = contract!.read(
                method,
                parameters: [CeloSDK.shared.address] as [AnyObject],
                extraData: Data(),
                transactionOptions: options)!
            let tokenBalance = try! tx.call()
          let balanceBigUInt = tokenBalance["0"] as! BigUInt
            let address = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3)!
            
        
            return address;
        } catch {
            return "CeloError.invalidAddress"
        }
    
       
   }
}

