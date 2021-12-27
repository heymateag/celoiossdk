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

public class CeloTransaction {

    private var feeCurrency:String;
     /**
      * Coinbase address of the full serving the light client's transactions
      */
    private  var gatewayFeeRecipient:String
     /**
      * Value paid to the gateway fee recipient, denominated in the fee currency
      */
    private var gatewayFee:BigInt




public init (feeCurrency:String,gatewayFeeRecipient:String,gatewayFee:BigInt) {
 
    self.gatewayFee = gatewayFee
    self.gatewayFeeRecipient = gatewayFeeRecipient

    self.feeCurrency = feeCurrency
    

}
    
    public func getFeeCurrency() ->String {
          return feeCurrency;
      }

    public func setFeeCurrency(feeCurrency:String) {
          self.feeCurrency = feeCurrency;
      }
    
    public func getGatewayFeeRecipient() ->String {
          return gatewayFeeRecipient;
      }

    public func setGatewayFeeRecipient(gatewayFeeRecipient:String) {
          self.gatewayFeeRecipient = gatewayFeeRecipient;
      }
    
    public func getGatewayFee() ->BigInt {
          return gatewayFee;
      }

    public func setGatewayFee(gatewayFee:BigInt) {
          self.gatewayFee = gatewayFee;
      }


}
