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


/**
 * 'nonce',
 * 'gasPrice',
 * 'gas',
 * 'feeCurrency',           -> CELO field
 * 'gatewayFeeRecipient',   -> CELO field
 * 'gatewayFee',            -> CELO field
 * 'to',
 * 'value',
 * 'data',
 * 'chainId',
 */


struct CeloCeloTransactionOptions:CeloTransactionOptionsInheritable {

    var CeloTransactionOptions: CeloTransactionOptions

    var feeCurrency:String = "0x0"
    
    public var feeCurrency: String?
    public var gatewayFeeRecipient: String?
    public var gatewayFee: : BigUInt = BigUInt(0)

    

    init(options:CeloTransactionOptions) {

        self.CeloTransactionOptions = options

    }

}




struct CeloTransactionSendingResult {

    public var transaction: CeloTransaction

    public var hash: String

}



extension web3.Eth { //webtransaction

    

    func sendRawCeloTransactionPromise(_ transaction: Data,web3 w3:web3) -> Promise<CeloTransactionSendingResult> {

        guard let deserializedTX = CeloTransaction.fromRaw(transaction) else {

            let promise = Promise<CeloTransactionSendingResult>.pending()

            promise.resolver.reject(Web3Error.processingError(desc: "Serialized TX is invalid"))

            return promise.promise

        }

        return sendCeloTransactionPromise(deserializedTX,web3: w3)

    }

    

    func sendCeloTransactionPromise(_ transaction: CeloTransaction, CeloTransactionOptions: CeloCeloTransactionOptions? = nil, password:String = Setting.password,web3 w3:web3) -> Promise<CeloTransactionSendingResult> {

        //        print(transaction)

                var assembledTransaction : CeloTransaction = transaction // .mergedWithOptions(CeloTransactionOptions)

                let queue = w3.requestDispatcher.queue

                do {

                    var mergedOptions = w3.CeloTransactionOptions.merge(CeloTransactionOptions?.CeloTransactionOptions)

                    

                    var forAssemblyPipeline : (CeloTransaction, CeloTransactionOptions) = (assembledTransaction, mergedOptions)

                    

                    for hook in w3.preSubmissionHooks {

                        let prom : Promise<Bool> = Promise<Bool> {seal in

                            hook.queue.async {

                                let hookResult = hook.function(forAssemblyPipeline)

                                if hookResult.2 {

                                    forAssemblyPipeline = (hookResult.0, hookResult.1)

                                }

                                seal.fulfill(hookResult.2)

                            }

                        }

                        let shouldContinue = try prom.wait()

                        if !shouldContinue {

                            throw Web3Error.processingError(desc: "Transaction is canceled by middleware")

                        }

                    }

                    

                    assembledTransaction = forAssemblyPipeline.0

                    mergedOptions = forAssemblyPipeline.1

                    



                    guard let from = mergedOptions.from else {

                        throw Web3Error.inputError(desc: "No 'from' field provided")

                    }

                    do {

                        try Web3Signer.signTX(transaction: &assembledTransaction, keystore: w3.provider.attachedKeystoreManager!, account: from, password: password)

                    } catch {

                        throw Web3Error.inputError(desc: "Failed to locally sign a transaction")

                    }
                    let returnPromise = Promise<CeloTransactionSendingResult>.pending()

                    queue.async {

                        returnPromise.resolver.reject(CeloError.contractFailure)

                    }

                    return returnPromise.promise
                  

                } catch {

                    let returnPromise = Promise<CeloTransactionSendingResult>.pending()

                    queue.async {

                        returnPromise.resolver.reject(error)

                    }

                    return returnPromise.promise

                }

            }

}

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
    func toJsonString() -> String {
        var model = CeloTransaction.CeloTransactionModel()
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
        

        public func encode(forSignature:Bool = false, chainID: BigUInt? = nil) -> Data? {

            if (forSignature) {
                if chainID != nil  {
                    let fields = [self.nonce, self.gasPrice, self.gasLimit, feeCurrency,gatewayFeeRecipient,BigUInt(0), self.to.addressData, self.value!, self.data, chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]
                    return RLP.encode(fields)
                }
                else if self.chainID != nil  {
                    let fields = [self.nonce, self.gasPrice, self.gasLimit,feeCurrency,gatewayFeeRecipient,BigUInt(0), self.to.addressData, self.value!, self.data, self.chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]
                    return RLP.encode(fields)
                } else {
                    let fields = [self.nonce, self.gasPrice, self.gasLimit,feeCurrency,gatewayFeeRecipient,BigUInt(0), self.to.addressData, self.value!, self.data] as [AnyObject]
                    return RLP.encode(fields)
                }
            } else {
                let fields = [self.nonce, self.gasPrice, self.gasLimit,feeCurrency,gatewayFeeRecipient,BigUInt(0), self.to.addressData, self.value!, self.data, self.v, self.r, self.s] as [AnyObject]
                return RLP.encode(fields)
            }
        }
    }
    
    
    public var description: String {
        get {
            var toReturn = ""
            toReturn = toReturn + "Transaction" + "\n"
            toReturn = toReturn + "Nonce: " + String(self.nonce) + "\n"
            toReturn = toReturn + "Gas price: " + String(self.gasPrice) + "\n"
            toReturn = toReturn + "Gas limit: " + String(describing: self.gasLimit) + "\n"
            toReturn = toReturn + "To: " + self.to.address + "\n"
            toReturn = toReturn + "Fee Currency: " + String(self.feeCurrency ?? "nil") + "\n"
            toReturn = toReturn + "Gateway FeeRecipient: " + String(self.gatewayFeeRecipient ?? "nil") + "\n"
            toReturn = toReturn + "Value: " + String(self.value ?? "nil") + "\n"
            toReturn = toReturn + "Data: " + self.data.toHexString().addHexPrefix().lowercased() + "\n"
            toReturn = toReturn + "v: " + String(self.v) + "\n"
            toReturn = toReturn + "r: " + String(self.r) + "\n"
            toReturn = toReturn + "s: " + String(self.s) + "\n"
            toReturn = toReturn + "Intrinsic chainID: " + String(describing:self.chainID) + "\n"
            toReturn = toReturn + "Infered chainID: " + String(describing:self.inferedChainID) + "\n"
            toReturn = toReturn + "sender: " + String(describing: self.sender?.address)  + "\n"
            toReturn = toReturn + "hash: " + String(describing: self.hash?.toHexString().addHexPrefix()) + "\n"
            return toReturn
        }
        
    }
    public var sender: EthereumAddress? {
        get {
            guard let publicKey = self.recoverPublicKey() else {return nil}
            return Web3.Utils.publicToAddress(publicKey)
        }
    }
    
    public func recoverPublicKey() -> Data? {
        if (self.r == BigUInt(0) && self.s == BigUInt(0)) {
            return nil
        }
        var normalizedV:BigUInt = BigUInt(27)
        let inferedChainID = self.inferedChainID
        var d = BigUInt(0)
        if self.v >= 35 && self.v <= 38 {
            d = BigUInt(35)
        } else if self.v >= 31 && self.v <= 34 {
            d = BigUInt(31)
        } else if self.v >= 27 && self.v <= 30 {
            d = BigUInt(27)
        }
        if (self.chainID != nil && self.chainID != BigUInt(0)) {
            normalizedV = self.v - d - self.chainID! - self.chainID!
        } else if (inferedChainID != nil) {
            normalizedV = self.v - d - inferedChainID! - inferedChainID!
        } else {
            normalizedV = self.v - d
        }
        guard let vData = normalizedV.serialize().setLengthLeft(1) else {return nil}
        guard let rData = r.serialize().setLengthLeft(32) else {return nil}
        guard let sData = s.serialize().setLengthLeft(32) else {return nil}
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        var hash: Data
        if inferedChainID != nil {
            guard let h = self.hashForSignature(chainID: inferedChainID) else {return nil}
            hash = h
        } else {
            guard let h = self.hashForSignature(chainID: self.chainID) else {return nil}
            hash = h
        }
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return publicKey
    }
    
    public var txhash: String? {
        get{
            guard self.sender != nil else {return nil}
            guard let hash = self.hash else {return nil}
            let txid = hash.toHexString().addHexPrefix().lowercased()
            return txid
        }
    }
    
    public var txid: String? {
        get {
            return self.txhash
        }
    }
}






