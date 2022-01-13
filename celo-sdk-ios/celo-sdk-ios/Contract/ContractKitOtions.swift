//
//  ContractKitOtions.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 27/12/21.
//

import Foundation
import BigInt
import PromiseKit


import web3swift




public final class ContractKitOtions {
    static let  DEFAULT_GAS_INFLATION_FACTOR = 1.3;
    static let  DEFAULT_GAS_PRICE_SUGGESTION_MULTIPLIER = 5;
    
    static let DEFAULT_PRICE:Int = 0;
    static let  CHAIN_ID = 44787;
    static let  GANACHE_CHAIN_ID = 1337;
    
    public let gasInflationFactor:Float
    public let gasPriceSuggestionMultiplier:Float
    public let gasPrice:Int
    public let feeCurrency:CeloContract
    public let from:String
    public let chainId: Int
    
    
    public init(gasInflationFactor:Float, gasPriceSuggestionMultiplier:Float, gasPrice:Int, feeCurrency:CeloContract, from:String, chainId:Int) {
          self.gasInflationFactor = gasInflationFactor;
        self.gasPriceSuggestionMultiplier = gasPriceSuggestionMultiplier;
        self.gasPrice = gasPrice;
        self.feeCurrency = feeCurrency;
        self.from = from;
        self.chainId = chainId;
      }
    
    let fee = AddressRegistry.addressFor
    

}
