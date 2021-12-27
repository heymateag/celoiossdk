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
public var transaction:EthereumTransaction
public var contract: EthereumContract
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

public init (transaction: EthereumTransaction,feeCurrency:String,gatewayFeeRecipient:String, web3 web3Instance: web3,gatewayFee:BigInt,from:String, contract: EthereumContract, method: String) {
    self.transaction = transaction
    self.web3 = web3Instance
    self.contract = contract
    self.method = method
    self.gatewayFee = gatewayFee
    self.gatewayFeeRecipient = gatewayFeeRecipient
    self.from = from
    self.feeCurrency = feeCurrency
    

}

}
