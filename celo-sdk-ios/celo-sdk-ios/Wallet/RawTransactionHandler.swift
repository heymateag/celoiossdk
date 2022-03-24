//
//  WalletConnectServerHandler.swift
//   

//   .
//

import BigInt
import Foundation
import WalletConnectSwift
import web3swift
import PromiseKit
import UIKit



class RawSigninTransactionHandler: RequestHandler {
    weak var server: Server!
    typealias onAccept = () -> Void
    typealias onCancel = () -> Void
    struct WCTransaction: Codable {
        var from: String
        var to: String?
        var data: String
        var gasLimit: String?
        var gasPrice: String?
        var value: String?
        var nonce: String?
    }
    
    init(server: Server) {
        self.server = server
    }
    
    func canHandle(request _: Request) -> Bool {
        return false
    }
    
    func handle(request _: Request) {
    }
    func showPromptMessage(title:String?,message:String?,acceptTitle:String,cancelTitle:String,onAccept:@escaping(onAccept),onReject:@escaping(onCancel)) {
        let topVC = UIApplication.topViewController()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acceptTitle, style: .default, handler: { (_) in
            onAccept()
        }))
        if cancelTitle != "" {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (_) in
                onReject()
            }))
        }
        
        topVC?.present(alert, animated: true, completion: nil)
    }
}


class SignTransactionHandler: RawSigninTransactionHandler {

    


//    func signTx(request: Request) {
//        do {
//            let wcTx = try request.parameter(of: WCTransaction.self, at: 0)
//
//            let jsonEncoder = JSONEncoder()
//            let jsonData = try jsonEncoder.encode(wcTx)
//            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
//            guard let transactionJSON = jsonString?.toJSON() as? [String: Any] else {
//                throw CeloError.custom("Parse tx failed")
//            }
//
//            guard let tx = EthereumTransaction.fromJSON(transactionJSON) else {
//                throw CeloError.custom("Parse tx failed")
//            }
//
//            guard let options = TransactionOptions.fromJSON(transactionJSON) else {
//                throw CeloError.custom("Parse tx failed")
//            }
//
//            let value = options.value != nil ? options.value! : BigUInt(0)
//            CeloTransactionManager.shared.signNewTransaction(to: tx.to.address, amount: value, data: tx.data, chainID: Setting.celoChainid)
////            CeloTransactionManager.signNewTransaction(to: tx.to.address, value: value, data: tx.data) { signData in
////                let response = try! Response(url: request.url, value: signData, id: request.id!)
////                self.server.send(response)
//
//            }
//        } catch {
//
//            HUDManager.shared.showError(text: "Handle Wallect Connect Request Faild")
//            return
//        }
    
}


class SendTransactionHandler: RawSigninTransactionHandler {
    var toAddress: String?
    var amount: BigUInt!
    var data: Data!

    
    var gasLimit: BigUInt!
    var gasPrice: GasPrice = GasPrice.average
    var isCustomGasLimit: Bool = false

    var mRequest:Request!
 
    
    func sendTx(request: Request) {
        do {
            
            let wcTx = try request.parameter(of: WCTransaction.self, at: 0)
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(wcTx)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            guard let json = jsonString, var transactionJSON = json.toJSON() as? [String: Any] else {
                throw CeloError.custom("Parse tx failed")
            }
            
            if !transactionJSON.keys.contains("value") {
                transactionJSON["value"] = String(BigUInt(0))
            }
            
            guard let tx = EthereumTransaction.fromJSON(transactionJSON) else {
                throw CeloError.custom("Parse tx failed")
            }
            
            guard let options = TransactionOptions.fromJSON(transactionJSON) else {
                throw CeloError.custom("Parse tx failed")
            }
            
            let value = options.value != nil ? options.value! : BigUInt(0)
            self.toAddress = tx.to.address
            self.amount = value
            self.data = tx.data

            self.gasLimit = BigUInt(0)
            self.gasPrice = GasPrice.average
            self.mRequest = request
            self.sendsigned()
        } catch {
            HUDManager.shared.showError(error: error)
            return
        }
    }

    
    @objc func gasChange(_ notification: Notification) {
        guard let text = notification.userInfo?["gasPrice"] as? String,
              let gasPrice = GasPrice.make(string: text) else { return }
        
        self.gasPrice = gasPrice
        
    }
    

    
    func sendsigned() {

        var gasLimitOption = TransactionOptions.GasLimitPolicy.automatic
        if isCustomGasLimit {
            gasLimitOption = TransactionOptions.GasLimitPolicy.manual(gasLimit)
        }
        
        firstly {
            self.transfer(toAddress: toAddress!, value: amount!, data: self.data,
                           gasPrice: gasPrice, gasLimit: gasLimitOption)
        }.done { hash in
            print(hash)


        }.catch { error in
            HUDManager.shared.showError(error: error)
        }
    }
   public func transfer(toAddress: String, value: BigUInt, data: Data = Data(),
                  gasPrice: GasPrice = GasPrice.average,
                  gasLimit: TransactionOptions.GasLimitPolicy = .automatic) -> Promise<String> {
        return Promise<String> { seal in

            let method: Promise<String>?
           
            method = CeloTransactionManager.shared.sendEtherSync(to: toAddress, amount: value,
                                                                 data: data,
                                                                 gasPrice: gasPrice,
                                                                 gasLimit: gasLimit)
          
          

            guard let block = method else {
                throw CeloError.unKnown
            }

            block.done { txHash in
                seal.fulfill(txHash)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
 
}


