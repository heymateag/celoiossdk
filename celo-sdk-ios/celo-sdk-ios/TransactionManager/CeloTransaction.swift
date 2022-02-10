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




struct CeloTransactionOptions:TransactionOptionsInheritable {

    var transactionOptions: TransactionOptions

    var feeCurrency:String = "0x0"

    

    init(options:TransactionOptions) {

        self.transactionOptions = options

    }

}




struct CeloTransactionSendingResult {

    public var transaction: EthereumTransaction

    public var hash: String

}



extension web3.Eth { //webtransaction

    

    func sendRawCeloTransactionPromise(_ transaction: Data,web3 w3:web3) -> Promise<CeloTransactionSendingResult> {

        guard let deserializedTX = EthereumTransaction.fromRaw(transaction) else {

            let promise = Promise<CeloTransactionSendingResult>.pending()

            promise.resolver.reject(Web3Error.processingError(desc: "Serialized TX is invalid"))

            return promise.promise

        }

        return sendCeloTransactionPromise(deserializedTX,web3: w3)

    }

    

    func sendCeloTransactionPromise(_ transaction: EthereumTransaction, transactionOptions: CeloTransactionOptions? = nil, password:String = "web3swift",web3 w3:web3) -> Promise<CeloTransactionSendingResult> {

        //        print(transaction)

                var assembledTransaction : EthereumTransaction = transaction // .mergedWithOptions(transactionOptions)

                let queue = w3.requestDispatcher.queue

                do {

                    var mergedOptions = w3.transactionOptions.merge(transactionOptions?.transactionOptions)

                    

                    var forAssemblyPipeline : (EthereumTransaction, TransactionOptions) = (assembledTransaction, mergedOptions)

                    

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
        

        func encodeCeloTransaction(forSignature:Bool = false, chainID: BigUInt? = nil) -> Data? {

            if (forSignature) {

                if chainID != nil  {

                    let fields = [self.nonce, self.gasPrice, self.gasLimit, self.value!, self.data, chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]

                    return RLP.encode(fields)

                }


            } else {

                let fields = [self.nonce, self.gasPrice, self.gasLimit, self.value!, self.data, self.v, self.r, self.s] as [AnyObject]

                return RLP.encode(fields)

            }
                  return Data()
        }
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
}




