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
    /// Sets from what account a transaction should be sent. Used only internally as the sender of Ethereum transaction
    /// is determined purely from the transaction signature. Indicates to the Ethereum node or to the local keystore what private key
    /// should be used to sign a transaction.
    ///
    /// Can be nil if one reads the information from the blockchain.
    public var from: EthereumAddress? = nil
    public var feeCurrency: String? 
    public var gatewayFeeRecipient: String?
    public var gatewayFee: BigUInt?
//    public enum GasLimitPolicy {
//        case automatic
//        case manual(BigUInt)
//        case limited(BigUInt)
//        case withMargin(Double)
//    }
    public var gasLimit: TransactionOptions.GasLimitPolicy?

//    public enum GasPricePolicy {
//        case automatic
//        case manual(BigUInt)
//        case withMargin(Double)
//    }
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


//public final class ContractKitOptions {
//    public static  let  DEFAULT_GAS_INFLATION_FACTOR = 1.3;
//    public static  let  DEFAULT_GAS_PRICE_SUGGESTION_MULTIPLIER = 5;
//
//    public static  let DEFAULT_PRICE:Int = 0;
//    public static  let  CHAIN_ID = 44787;
//    public static  let  GANACHE_CHAIN_ID = 1337;
//
//    public   let gasInflationFactor:Float
//    public   let gasPriceSuggestionMultiplier:Float
//    public   let gasPrice:Int
//    public  var feeCurrency:CeloContractClass
//    public   let from:String
//    public   let chainId: Int
//
//    public init(){
//        self.gasInflationFactor = gasInflationFactor;
//      self.gasPriceSuggestionMultiplier = gasPriceSuggestionMultiplier;
//      self.gasPrice = gasPrice;
//      self.feeCurrency = feeCurrency;
//      self.from = from;
//      self.chainId = chainId;
//    }
//
////    public init(gasInflationFactor:Float, gasPriceSuggestionMultiplier:Float, gasPrice:Int, feeCurrency:CeloContractClass, from:String, chainId:Int) {
////          self.gasInflationFactor = gasInflationFactor;
////        self.gasPriceSuggestionMultiplier = gasPriceSuggestionMultiplier;
////        self.gasPrice = gasPrice;
////        self.feeCurrency = feeCurrency;
////        self.from = from;
////        self.chainId = chainId;
////      }
////
//    func setFeeCurrency(currency:CeloContractClass) {
//
//        self.feeCurrency = currency
//
//    }
//
//
//
//    func getFeeCurrency() -> CeloContractClass {
//
//        return self.feeCurrency
//
//    }
//
//
//
//}
