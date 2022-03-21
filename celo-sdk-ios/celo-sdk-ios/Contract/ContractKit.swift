//
//  ContractKit.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 04/11/21.
//

import Foundation
import web3swift
import BigInt
import PromiseKit

//public protocol ContractKit {
//    func getContractKit(web3Instance: web3 ,_ abiString: String, at: web3swift.EthereumAddress) -> web3swift.web3.web3contract?
//}
public class ContractKit
{
    public var feeCurrency: String?
    public var gatewayFeeRecipient: String?
    public var gatewayFee: BigUInt?
    public func getContractKit(web3Instance: web3 ,_ abiString: String, at: web3swift.EthereumAddress) -> web3swift.web3.web3contract?
    {
        let contract = web3Instance.contract(abiString, at: at, abiVersion: 2)!
        return contract
    }
    
    public func getStableTokenBalanceOf(currentAddress:String) -> Promise<String> {
        
   
        let stableToken : StableTokenWrapper = StableTokenWrapper()
//        let stableTokenBal = stableToken.balanceOf(accountOwner: currentAddress)
       
        return stableToken.balanceOf(accountOwner: currentAddress)

   
    //    Configuration.changeEnvironment(isProduction: true)
    //    let contractAddress = EthereumAddress("0x765de816845861e75a25fca122bb6898b8b1282a")
    //    let stableTokenAbi = AddressRegistry().getAbiForContract(to: CeloContractClass.StableToken)
    //    let currentCeloAddress = EthereumAddress(currentAddress)!
    //    let contract = CeloSDK.shared.getContractKit(web3Instance: CeloSDK.web3Net, stableTokenAbi, at: contractAddress!)
    //    var options = ContractKitOptions.defaultOptions
    //
    //
    //    options.from = currentCeloAddress
    //    options.gasPrice = .automatic
    //    options.gasLimit = .automatic
    //
    //    let method = "balanceOf"
    //    let tx = contract!.read(
    //        method,
    //        parameters: [currentAddress] as [AnyObject],
    //        extraData: Data(),
    //        transactionOptions: options)!
    //    let tokenBalance = try! tx.call()
    //    let balanceBigUInt = tokenBalance["0"] as! BigUInt
    //    let balanceString = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3)!


    }
    
    public func getFeeCurrency() -> String {
        return self.feeCurrency!
    }

    public func setFeeCurrency(feeCurrency:String) {
        self.feeCurrency = feeCurrency
    }

    public func getGatewayFeeRecipient() -> String {
        return gatewayFeeRecipient!
    }

    public func setGatewayFeeRecipient(gatewayFeeRecipient:String) {
        self.gatewayFeeRecipient = gatewayFeeRecipient;
    }

    public func getGatewayFee() -> BigUInt{
        return gatewayFee!
    }

    public func setGatewayFee(gatewayFee:BigUInt) {
        self.gatewayFee = gatewayFee;
    }

    //
    public func getGaspriceMinimum() -> BigUInt
    {

        let randomDouble = Int.random(in: 1592580000...1592589999)
        var options = TransactionOptions.defaultOptions
        return 1592580000

    }
    
    
    public func sendTransaction(transaction :CeloTransactionRequest) -> Promise<String>

    {
        let returnPromise = Promise<String>.pending()
        
        var transactionReceiptHash : String = ""
        var gasLimitOption = TransactionOptions.GasLimitPolicy.automatic
  
        firstly {
            self.sendEncodedTransaction(toAddress: transaction.to, value: transaction.value, data: transaction.data,
                          gasPrice: transaction.gasPrice, gasLimit: transaction.gasLimit)
        }.done { hash in
            print(hash)
          transactionReceiptHash = hash
            returnPromise.resolver.fulfill(hash)

        }.catch { error in
            HUDManager.shared.showError(error: error)
            returnPromise.resolver.reject(error)
        }
        return returnPromise.promise
    }
    
    public func sendRawTransaction(to address: String,
                              amount: BigUInt,
                              abi: String,
                              data: Data,
                              functionName:String,
                              password _: String = "web3swift",
                              gasPrice: GasPrice = GasPrice.average,
                              gasLimit: TransactionOptions.GasLimitPolicy = .automatic) -> Promise<String> {
        return CeloTransactionManager.writeSmartContract(contractAddress: address,
                                                     functionName: functionName,
                                                     abi: abi,
                                                     parameters: [AnyObject](),
                                                     extraData: data,
                                                     value: amount,
                                                     gasPrice: gasPrice,
                                                     gasLimit: gasLimit)
    }
    
    public func sendEncodedTransaction(toAddress: String, value: BigUInt, data: Data = Data(),
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


public struct CeloTransactionRequest
{
    public var nonce: BigUInt
    public var gasPrice: GasPrice = .average
    public var gasLimit: TransactionOptions.GasLimitPolicy = .automatic
    public var feeCurrency: String?
    public var gatewayFeeRecipient: String?
    public var gatewayFee: BigUInt?
    public var to: String
    public var data: Data
    public var value: BigUInt
    
}


//bhar


    
  
//}



//
//public
