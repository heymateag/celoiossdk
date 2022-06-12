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

public class ContractKit
{
    public var feeCurrency: String?
    public var gatewayFeeRecipient: String?
    public var gatewayFee: BigUInt?
    public var contracts:WrapperCache!
    public func getContractKit(web3Instance: web3 ,_ abiString: String, at: web3swift.EthereumAddress) -> web3swift.web3.web3contract?
    {
        return web3Instance.contract(abiString, at: at, abiVersion: 2)
//        return contract
    }
    public func getAdressForString(contractName : String) -> Promise<String>{
        let addressRegistry : AddressRegistry = AddressRegistry()
        let addressForContract = addressRegistry.getAdressForString(contractName: contractName)
        return addressForContract
    }
    public func getStableTokenBalanceOf(currentAddress:String) -> Promise<String> {
        print("currentAddress \(currentAddress)")
        let stableToken : StableTokenWrapper = StableTokenWrapper()
        let stableTokenBal = stableToken.balanceOf(accountOwner: currentAddress)
       
        return stableTokenBal
    }
    
    public func transfer(amount: String,toAddress :String) -> Promise<String> {
        let stableToken : StableTokenWrapper = StableTokenWrapper()
        let transactionHash = stableToken.transfer(amount: amount, toAddress: toAddress)
        return transactionHash
    }
    public func calculateCELO(address :String) -> String {
        let balanceString : String = ""
        guard let urlStr = URL(string: Setting.web3url),
              let ethereumAddress = EthereumAddress(address) else {
                  return balanceString
              }
        do {
            let web3 = try Web3.new(urlStr)
            let balance = try web3.eth.getBalance(address: ethereumAddress)
            if let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 2) {
                   return balanceString
            }
        } catch {
            print("balance error \(error)")
            return balanceString
          
        }
        return balanceString
    }
    public func getFeeCurrency() -> String {
        print("getFeeCurrency \(String(describing: feeCurrency))")
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
    
    
    public func getGaspriceMinimum(tokenType:CeloContractClass) -> Promise<BigUInt>
    {
        let stableToken : GasPriceMinimumWrapper = GasPriceMinimumWrapper()
        let gasPriceMinimum = stableToken.getGasPriceMinimum(accountOwner: tokenType.rawValue)
        return gasPriceMinimum
    }

 
    // MARK: - Send and Sign Transaction
  
    
    public func sendTransaction(to address: String,
                              amount: BigUInt,
                              abi: String,
                              data: Data,
                              functionName:String,
                              password _: String = "web3swift",
                              gasPrice: GasPrice = GasPrice.average,
                              gasLimit: TransactionOptions.GasLimitPolicy = .automatic) -> Promise<String> {
        return CeloTransactionManager.sendTransactionRequest(contractAddress: address,
                                                     functionName: functionName,
                                                     abi: abi,
                                                     parameters: [AnyObject](),
                                                     extraData: data,
                                                     value: amount,
                                                     gasPrice: gasPrice,
                                                     gasLimit: gasLimit)
    }
    
    public func signTransaction(to address: String,
                              amount: BigUInt,
                              data: Data,
                              password _: String = "web3swift") -> Promise<String> {
                                  return CeloTransactionManager.signNewTransaction(to: address, amount: amount, data: data)
    }
    
    // MARK: - Util function
    
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
    public func sendRawTransaction(transaction :CeloTransactionRequest) -> String

    {

        
        var transactionReceiptHash : String = ""
        _ = TransactionOptions.GasLimitPolicy.automatic

        firstly {
            self.sendEncodedTransaction(toAddress: transaction.to, value: transaction.value, data: transaction.data,
                          gasPrice: transaction.gasPrice, gasLimit: transaction.gasLimit)
        }.done { hash in
            print(hash)
          transactionReceiptHash = hash


        }.catch { error in
            HUDManager.shared.showError(error: error)
        }
        return transactionReceiptHash
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
