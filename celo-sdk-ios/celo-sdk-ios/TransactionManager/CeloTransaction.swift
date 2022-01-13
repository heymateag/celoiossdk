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
import HandyJSON

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
struct CeloTransactionModel: HandyJSON {
    var nonce: String?
    var gasPrice: String?
    var gasLimit: String?
    var to: String?
    var value: String?
    var data: String?
    var v: String?
    var r: String?
    var s: String?
    var chainID: String?
    var inferedChainID: String?
    var from: String?
    var hash: String?

    init() {
        return
    }
}
struct EthTransaction: Hashable {
    var hash: String

    init?(hash: String) {
        if !hash.hasPrefix("0x") {
            return nil
        }

        if hash.count != 66 {
            return nil
        }

        self.hash = hash
    }
}

extension EthereumTransaction {
    func toJsonString() -> String {
        var model = CeloTransactionModel()
        model.nonce = String(nonce)
        model.gasPrice = String(gasPrice)
        model.gasLimit = String(describing: gasLimit)
        model.to = to.address
        if let v = value {
            model.value = String(v)
        }
        model.data = data.toHexString().addHexPrefix().lowercased()
        model.v = String(v)
        model.r = String(r)
        model.s = String(s)
        model.chainID = String(describing: intrinsicChainID)
        model.inferedChainID = String(describing: inferedChainID)
        model.from = String(describing: sender!.address)
        model.hash = String(describing: hash!.toHexString().addHexPrefix())
        return model.toJSONString(prettyPrint: true)!
    }
}
