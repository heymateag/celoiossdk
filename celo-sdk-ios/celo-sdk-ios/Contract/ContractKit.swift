//
//  ContractKit.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 04/11/21.
//

import Foundation
import web3swift

public protocol ContractKit {
    func getContractKit(web3Instance: web3 ,_ abiString: String, at: web3swift.EthereumAddress) -> web3swift.web3.web3contract?
}

extension CeloSDK: ContractKit {
public func getContractKit(web3Instance: web3 ,_ abiString: String, at: web3swift.EthereumAddress) -> web3swift.web3.web3contract?
{
    let contract = web3Instance.contract(abiString, at: at, abiVersion: 2)!
    
    return contract
}
    
//public func getContractKit(web3Instance: web3) -> web3swift.web3.web3contract?
//    {
//        let contract = web3Instance.contract(abiString, at: at, abiVersion: 2)!
//
//        return contract
//    }
//
    
}
