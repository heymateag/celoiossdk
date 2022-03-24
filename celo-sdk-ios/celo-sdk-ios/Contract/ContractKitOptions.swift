//
//  ContractKitOptions.swift
//  celo-sdk-ios
//
//  Created by Apple on 19/03/22.
//

import Foundation
import BigInt
import PromiseKit


import web3swift

/// Options for sending or calling a particular Ethereum transaction
public struct ContractKitOptions {
    /// Sets the transaction destination. It can either be a contract address or a private key controlled wallet address.
    ///
    /// Usually should never be nil, left undefined for a contract-creation transaction.
    public var to: EthereumAddress? = nil
    /// Can be nil if one reads the information from the blockchain.
    public var from: EthereumAddress? = nil
    public var feeCurrency: String? 
    public var gatewayFeeRecipient: String?
    public var gatewayFee: BigUInt?

    public var gasLimit: TransactionOptions.GasLimitPolicy?


    public var gasPrice: TransactionOptions.GasPricePolicy?

    /// The value transferred for the transaction in wei, also the endowment if it’s a contract-creation transaction.
    public var value: BigUInt? = nil
    
    public enum NoncePolicy {
        case pending
        case latest
        case manual(BigUInt)
    }
    public var nonce: NoncePolicy?
    
    public enum CallingBlockPolicy {
        case pending
        case latest
        case exactBlockNumber(BigUInt)
        
        var stringValue: String {
            switch self {
            case .pending:
                return "pending"
            case .latest:
                return "latest"
            case .exactBlockNumber(let number):
                return String(number, radix: 16).addHexPrefix()
            }
        }
    }
    public var callOnBlock: CallingBlockPolicy?
    
    public init() {
    }
    
    public static var defaultOptions: TransactionOptions {
        var opts = TransactionOptions()
        opts.callOnBlock = .pending
        opts.nonce = .pending
        opts.gasLimit = TransactionOptions.GasLimitPolicy.automatic
        opts.gasPrice = TransactionOptions.GasPricePolicy.automatic
        
        
        return opts
    }
}

