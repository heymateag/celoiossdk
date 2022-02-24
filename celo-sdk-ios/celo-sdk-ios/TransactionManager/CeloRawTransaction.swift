//
//  CeloTransactionManager.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 27/12/21.
//

import Foundation
import web3swift
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result

public class CeloRawTransaction {
public var transaction:CeloTransaction
public var contract: CeloContract
public var method: String

    private let feeCurrency:String;
     /**
      * Coinbase address of the full serving the light client's transactions
      */
    private  let gatewayFeeRecipient:String
     /**
      * Value paid to the gateway fee recipient, denominated in the fee currency
      */
    private let gatewayFee:BigInt
    private let from:String

var web3: web3

public init (transaction: CeloTransaction,feeCurrency:String,gatewayFeeRecipient:String, web3 web3Instance: web3,gatewayFee:BigInt,from:String, contract: CeloContract, method: String) {
    self.transaction = transaction
    self.web3 = web3Instance
    self.contract = contract
    self.method = method
    self.gatewayFee = gatewayFee
    self.gatewayFeeRecipient = gatewayFeeRecipient
    self.from = from
    self.feeCurrency = feeCurrency
    

}
    
public extension CeloTransactionInvocation {

    func call(block: EthereumQuantityTag = .latest) -> Promise<[String: Any]> {
        return Promise { seal in
            self.call(block: block, completion: seal.resolve)
        }
    }

    func send(nonce: CeloQuantity? = nil, from: CeloAddress, value: CeloQuantity?, gas: CeloQuantity, gasPrice: CeloQuantity?) -> Promise<CeloData> {
        return Promise { seal in
            self.send(nonce: nonce, from: from, value: value, gas: gas, gasPrice: gasPrice, completion: seal.resolve)
        }
    }

    func estimateGas(from: CeloAddress? = nil, gas: CeloQuantity? = nil, value: CeloQuantity? = nil) -> Promise<CeloQuantity> {
        return Promise { seal in
            self.estimateGas(from: from, gas: gas, value: value, completion: seal.resolve)
        }
    }
}

}
