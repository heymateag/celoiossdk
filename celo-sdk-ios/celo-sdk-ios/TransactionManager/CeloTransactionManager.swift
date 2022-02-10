//
//  CeloCeloTransactionManager.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 27/12/21.
//

import BigInt
import PromiseKit
import web3swift
import Foundation
fileprivate typealias PromiseResult = PromiseKit.Result
private var fetchPendingFrequency: TimeInterval = 5.0

// TODO: Change all function to Promise
class CeloTransactionManager {
    
    static let shared = CeloTransactionManager(web3: CeloSDK.shared.web3Main)
    var web3: web3!
    class func getAddress() throws -> String {
        guard let address = CeloSDK.shared.address else { throw CeloError.accountDoesNotExist }
        return address
    }

    // MARK: - Call Smart Contract
    public func transferToken(contractAddress: String,
                                         functionName: String,
                                         value: String,
                                         abi: String,
                                         toAddress:String,notERC20: Bool = true
                                        ) -> Promise<String> {
        
        
        return Promise<String> { seal in
            guard let contractAddress = EthereumAddress(contractAddress) else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            guard let toAddress = EthereumAddress(toAddress) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
         
            
            guard let contract = CeloSDK.contractkit.getContractKit(web3Instance: CeloSDK.shared.web3Main, abi, at: contractAddress) else {
                seal.reject(CeloError.contractFailure)
                return
            }
            guard let amountInDouble = Double(value) else {
                seal.reject(CeloError.conversionFailure)
                return
            }
            guard let address = CeloSDK.shared.address else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            
          

            guard let walletAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }
            var options = CeloTransactionOptions.defaultOptions
            CeloTransactionManager.init(web3: CeloSDK.shared.web3Main).gasForSendingCelo(to: contractAddress, amount: value, data: Data()).done { value in
                options.gasPrice = .manual(value)
            }
        

            options.gasLimit = .manual(10000000)
            options.value = Web3.Utils.parseToBigUInt("0", units: .eth)
            options.from = walletAddress
            
            
            let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
            
            guard let tx = contract.write(
                        functionName,
                        parameters: [toAddress, amount as Any] as [AnyObject],
                        extraData: Data(),
                        CeloTransactionOptions: options)
            else {
                seal.reject(CeloError.contractFailure)
                return
            }
            
            firstly {
                tx.sendPromise(password: Setting.password, CeloTransactionOptions: options)

            }.done { result in
                seal.fulfill(result.hash)


            }.catch { error in
      print(error)
                seal.reject(error)
            }
        }
            
    }
    public class func writeSmartContract(contractAddress: String,
                                         functionName: String,
                                         abi: String,
                                         parameters: [Any],
                                         extraData: Data,
                                         value: BigUInt,
                                         gasPrice: GasPrice = GasPrice.average,
                                         gasLimit: CeloTransactionOptions.GasLimitPolicy = .automatic,
                                         notERC20: Bool = true) -> Promise<String> {
        return Promise<String> { seal in

            guard let address = CeloSDK.shared.address else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            guard let walletAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            guard let celoContractAddress = EthereumAddress(contractAddress) else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            guard let amountInDouble = Double(value.readableValue) else {
                seal.reject(CeloError.conversionFailure)
                return
            }

        

            guard let contract = CeloSDK.contractkit.getContractKit(web3Instance: CeloSDK.shared.web3Main, abi, at: celoContractAddress) else {
                seal.reject(CeloError.contractFailure)
                return
            }


            var options = CeloTransactionOptions.defaultOptions
            options.value = notERC20 ? value : nil
            options.from = walletAddress
            
            CeloTransactionManager.init(web3: CeloSDK.shared.web3Main).gasForSendingCelo(to: contractAddress, amount: value, data: Data()).done { value in
                options.gasPrice = .manual(value)
            }
        

      
            options.gasLimit = gasLimit

            guard let tx = contract.write(
                functionName,
                parameters: parameters as [AnyObject],
                extraData: extraData,
                CeloTransactionOptions: options
            ) else {
                seal.reject(CeloError.contractFailure)
                return
            }
            
            firstly {
                CeloTransactionManager.shared.checkBalance(amountInDouble: amountInDouble, notERC20: notERC20)
            }.then { _ in
                tx.sendPromise(password: Setting.password, CeloTransactionOptions: options)
            }.done { result in
                seal.fulfill(result.hash)


            }.catch { error in

                seal.reject(error)
            }
        }
    }

    
    public func sendCeloSync(to address: String,
                              amount: BigUInt,
                              data: Data,
                              password _: String = Setting.password,
                              gasPrice: GasPrice = GasPrice.average,
                              gasLimit: CeloTransactionOptions.GasLimitPolicy = .automatic) -> Promise<String> {
        return CeloTransactionManager.writeSmartContract(contractAddress: address,
                                                     functionName: "fallback",
                                                     abi: Web3.Utils.coldWalletABI,
                                                     parameters: [AnyObject](),
                                                     extraData: data,
                                                     value: amount,
                                                     gasPrice: gasPrice,
                                                     gasLimit: gasLimit)
    }
    public func celoBalanceSync() throws -> String {
        guard let address = CeloSDK.shared.address else { throw CeloError.accountDoesNotExist }
        guard let celoAddress = EthereumAddress(address) else { throw CeloError.invalidAddress }

        guard let balanceInWeiUnitResult = try? CeloSDK.shared.web3Main.eth.getBalance(address: celoAddress) else {
            throw CeloError.insufficientBalance
        }

        guard let balanceInEtherUnitStr = Web3.Utils.formatToEthereumUnits(balanceInWeiUnitResult,
                                                                           toUnits: .eth,
                                                                           decimals: 6, decimalSeparator: ".")
        else { throw CeloError.conversionFailure }

        return balanceInEtherUnitStr
    }

    public func celoBalance() -> Promise<String> {
        return Promise<String> { seal in
            guard let address = CeloSDK.shared.address else {
                seal.reject(CeloError.accountDoesNotExist)
                return
            }
            guard let ethereumAddress = EthereumAddress(address) else {
                seal.reject(CeloError.invalidAddress)
                return
            }

            firstly {
                CeloSDK.shared.web3Main.eth.getBalancePromise(address: ethereumAddress)
            }.done { balanceInWeiUnitResult in
                guard let balanceInEtherUnitStr = Web3.Utils.formatToEthereumUnits(balanceInWeiUnitResult,
                                                                                   toUnits: .eth,
                                                                                   decimals: 6, decimalSeparator: ".")
                else {
                    seal.reject(CeloError.conversionFailure)
                    return
                }
                seal.fulfill(balanceInEtherUnitStr)
            }
        }

    }

    // MARK: - Send Transaction

   

    func checkBalance(amountInDouble: Double, notERC20: Bool) -> Promise<Bool> {
        return Promise { seal in
            // TODO: Add ERC20 Blanace Check
            if !notERC20 {
                seal.fulfill(true)
            }

            firstly {
                celoBalance()
            }.done { celoBalance in
                guard let celoBalanceInDouble = Double(celoBalance) else {
                    seal.reject(CeloError.conversionFailure)
                    return
                }
                if notERC20 {
                    guard celoBalanceInDouble >= amountInDouble else {
                        seal.reject(CeloError.insufficientBalance)
                        return
                    }
                }
                seal.fulfill(true)
            }
        }
    }


    public class CeloReadTransaction {
        public var transaction:CeloTransaction
        public var contract: CeloContract
        public var method: String
        public var CeloTransactionOptions: CeloTransactionOptions = CeloTransactionOptions.defaultOptions
        
        var web3: web3
        
        public init (transaction: CeloTransaction, web3 web3Instance: web3, contract: CeloContract, method: String, CeloTransactionOptions: CeloTransactionOptions?) {
            self.transaction = transaction
            self.web3 = web3Instance
            self.contract = contract
            self.method = method
            self.CeloTransactionOptions = self.CeloTransactionOptions.merge(CeloTransactionOptions)
            if self.web3.provider.network != nil {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        public func callPromise(CeloTransactionOptions: CeloTransactionOptions? = nil) -> Promise<[String: Any]> {
            var assembledTransaction : CeloTransaction = self.transaction
            let queue = self.web3.requestDispatcher.queue
            let returnPromise = Promise<[String:Any]> { seal in
                let mergedOptions = self.CeloTransactionOptions.merge(CeloTransactionOptions)
                var optionsForCall = CeloTransactionOptions()
                optionsForCall.from = mergedOptions.from
                optionsForCall.to = mergedOptions.to
                optionsForCall.value = mergedOptions.value
                optionsForCall.callOnBlock = mergedOptions.callOnBlock
                if mergedOptions.value != nil {
                    assembledTransaction.value = mergedOptions.value!
                }
                let callPromise : Promise<Data> = self.web3.eth.callPromise(assembledTransaction, CeloTransactionOptions: optionsForCall)
                callPromise.done(on: queue) {(data:Data) throws in
                    do {
                        if (self.method == "fallback") {
                            let resultHex = data.toHexString().addHexPrefix()
                            seal.fulfill(["result": resultHex as Any])
                            return
                        }
                        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else
                        {
                            throw Web3Error.processingError(desc: "Can not decode returned parameters")
                        }
                        seal.fulfill(decodedData)
                    } catch{
                        seal.reject(error)
                    }
                    }.catch(on: queue) {err in
                        seal.reject(err)
                }
            }
            return returnPromise
        }
        
        public func estimateGasPromise(CeloTransactionOptions: CeloTransactionOptions? = nil) -> Promise<BigUInt>{
            var assembledTransaction : CeloTransaction = self.transaction
            let queue = self.web3.requestDispatcher.queue
            let returnPromise = Promise<BigUInt> { seal in
                let mergedOptions = self.CeloTransactionOptions.merge(CeloTransactionOptions)
                var optionsForGasEstimation = CeloTransactionOptions()
                optionsForGasEstimation.from = mergedOptions.from
                optionsForGasEstimation.to = mergedOptions.to
                optionsForGasEstimation.value = mergedOptions.value
                
                // MARK: - Fixing estimate gas problem: gas price param shouldn't be nil
                if let gasPricePolicy = mergedOptions.gasPrice {
                    switch gasPricePolicy {
                    case .manual( _):
                        optionsForGasEstimation.gasPrice = gasPricePolicy
                    default:
                        optionsForGasEstimation.gasPrice = .manual(1) // 1 wei to fix wrong estimating gas problem
                    }
                }
                
                optionsForGasEstimation.callOnBlock = mergedOptions.callOnBlock
                if mergedOptions.value != nil {
                    assembledTransaction.value = mergedOptions.value!
                }
                let promise = self.web3.eth.estimateGasPromise(assembledTransaction, CeloTransactionOptions: optionsForGasEstimation)
                promise.done(on: queue) {(estimate: BigUInt) in
                    seal.fulfill(estimate)
                    }.catch(on: queue) {err in
                        seal.reject(err)
                }
            }
            return returnPromise
        }
        
        public func estimateGas(CeloTransactionOptions: CeloTransactionOptions? = nil) throws -> BigUInt {
            return try self.estimateGasPromise(CeloTransactionOptions: CeloTransactionOptions).wait()
        }
        
        public func call(CeloTransactionOptions: CeloTransactionOptions? = nil) throws -> [String: Any] {
            return try self.callPromise(CeloTransactionOptions: CeloTransactionOptions).wait()
        }
    }

    //import EthereumAddress

    public class CeloWriteTransaction: CeloReadTransaction {
        
        public func assemblePromise(CeloTransactionOptions: CeloTransactionOptions? = nil) -> Promise<CeloTransaction> {
            var assembledTransaction : CeloTransaction = self.transaction
            let queue = self.web3.requestDispatcher.queue
            let returnPromise = Promise<CeloTransaction> { seal in
                if self.method != "fallback" {
                    let m = self.contract.methods[self.method]
                    if m == nil {
                        seal.reject(Web3Error.inputError(desc: "Contract's ABI does not have such method"))
                        return
                    }
                    switch m! {
                    case .function(let function):
                        if function.constant {
                            seal.reject(Web3Error.inputError(desc: "Trying to transact to the constant function"))
                            return
                        }
                    case .constructor(_):
                        break
                    default:
                        seal.reject(Web3Error.inputError(desc: "Contract's ABI does not have such method"))
                        return
                    }
                }
                
                var mergedOptions = self.CeloTransactionOptions.merge(CeloTransactionOptions)
                if mergedOptions.value != nil {
                    assembledTransaction.value = mergedOptions.value!
                }
                var forAssemblyPipeline : (CeloTransaction, CeloContract, CeloTransactionOptions) = (assembledTransaction, self.contract, mergedOptions)
                
                for hook in self.web3.preAssemblyHooks {
                    let prom : Promise<Bool> = Promise<Bool> {seal in
                        hook.queue.async {
                            let hookResult = hook.function(forAssemblyPipeline)
                            if hookResult.3 {
                                forAssemblyPipeline = (hookResult.0, hookResult.1, hookResult.2)
                            }
                            seal.fulfill(hookResult.3)
                        }
                    }
                    let shouldContinue = try prom.wait()
                    if !shouldContinue {
                        seal.reject(Web3Error.processingError(desc: "Transaction is canceled by middleware"))
                        return
                    }
                }
                
                assembledTransaction = forAssemblyPipeline.0
                mergedOptions = forAssemblyPipeline.2
                
                guard let from = mergedOptions.from else {
                    seal.reject(Web3Error.inputError(desc: "No 'from' field provided"))
                    return
                }
                
                // assemble promise for gas estimation
                var optionsForGasEstimation = CeloTransactionOptions()
                optionsForGasEstimation.from = mergedOptions.from
                optionsForGasEstimation.to = mergedOptions.to
                optionsForGasEstimation.value = mergedOptions.value
                optionsForGasEstimation.gasLimit = mergedOptions.gasLimit
                optionsForGasEstimation.callOnBlock = mergedOptions.callOnBlock
                
                // assemble promise for gasLimit
                var gasEstimatePromise: Promise<BigUInt>? = nil
                guard let gasLimitPolicy = mergedOptions.gasLimit else {
                    seal.reject(Web3Error.inputError(desc: "No gasLimit policy provided"))
                    return
                }
                switch gasLimitPolicy {
                case .automatic, .withMargin, .limited:
                    gasEstimatePromise = self.web3.eth.estimateGasPromise(assembledTransaction, CeloTransactionOptions: optionsForGasEstimation)
                case .manual(let gasLimit):
                    gasEstimatePromise = Promise<BigUInt>.value(gasLimit)
                }
                
                // assemble promise for nonce
                var getNoncePromise: Promise<BigUInt>?
                guard let noncePolicy = mergedOptions.nonce else {
                    seal.reject(Web3Error.inputError(desc: "No nonce policy provided"))
                    return
                }
                switch noncePolicy {
                case .latest:
                    getNoncePromise = self.web3.eth.getTransactionCountPromise(address: from, onBlock: "latest")
                case .pending:
                    getNoncePromise = self.web3.eth.getTransactionCountPromise(address: from, onBlock: "pending")
                case .manual(let nonce):
                    getNoncePromise = Promise<BigUInt>.value(nonce)
                }

                // assemble promise for gasPrice
                var gasPricePromise: Promise<BigUInt>? = nil
                guard let gasPricePolicy = mergedOptions.gasPrice else {
                    seal.reject(Web3Error.inputError(desc: "No gasPrice policy provided"))
                    return
                }
                switch gasPricePolicy {
                case .automatic, .withMargin:
                    gasPricePromise = self.web3.eth.getGasPricePromise()
                case .manual(let gasPrice):
                    gasPricePromise = Promise<BigUInt>.value(gasPrice)
                }
                var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise!, gasPricePromise!, gasEstimatePromise!]
                when(resolved: getNoncePromise!, gasEstimatePromise!, gasPricePromise!).map(on: queue, { (results:[PromiseResult<BigUInt>]) throws -> CeloTransaction in
                    
                    promisesToFulfill.removeAll()
                    guard case .fulfilled(let nonce) = results[0] else {
                        throw Web3Error.processingError(desc: "Failed to fetch nonce")
                    }
                    guard case .fulfilled(let gasEstimate) = results[1] else {
                        throw Web3Error.processingError(desc: "Failed to fetch gas estimate")
                    }
                    guard case .fulfilled(let gasPrice) = results[2] else {
                        throw Web3Error.processingError(desc: "Failed to fetch gas price")
                    }
                    
                    guard let estimate = mergedOptions.resolveGasLimit(gasEstimate) else {
                        throw Web3Error.processingError(desc: "Failed to calculate gas estimate that satisfied options")
                    }
                    
                    guard let finalGasPrice = mergedOptions.resolveGasPrice(gasPrice) else {
                        throw Web3Error.processingError(desc: "Missing parameter of gas price for transaction")
                    }
                    
        
                    assembledTransaction.nonce = nonce
                    assembledTransaction.gasLimit = estimate
                    assembledTransaction.gasPrice = finalGasPrice
                    
                    forAssemblyPipeline = (assembledTransaction, self.contract, mergedOptions)
                    
                    for hook in self.web3.postAssemblyHooks {
                        let prom : Promise<Bool> = Promise<Bool> {seal in
                            hook.queue.async {
                                let hookResult = hook.function(forAssemblyPipeline)
                                if hookResult.3 {
                                    forAssemblyPipeline = (hookResult.0, hookResult.1, hookResult.2)
                                }
                                seal.fulfill(hookResult.3)
                            }
                        }
                        let shouldContinue = try prom.wait()
                        if !shouldContinue {
                            throw Web3Error.processingError(desc: "Transaction is canceled by middleware")
                        }
                    }
                    
                    assembledTransaction = forAssemblyPipeline.0
                    mergedOptions = forAssemblyPipeline.2
                    
                    return assembledTransaction
                }).done(on: queue) {tx in
                    seal.fulfill(tx)
                    }.catch(on: queue) {err in
                        seal.reject(err)
                }
            }
            return returnPromise
        }
        
        public func sendPromise(password:String = Setting.password, CeloTransactionOptions: CeloTransactionOptions? = nil) -> Promise<TransactionSendingResult>{
            let queue = self.web3.requestDispatcher.queue
            return self.assemblePromise(CeloTransactionOptions: CeloTransactionOptions).then(on: queue) { transaction throws -> Promise<CeloTransactionSendingResult> in
                let mergedOptions = self.CeloTransactionOptions.merge(CeloTransactionOptions)
                var cleanedOptions = CeloTransactionOptions()
                cleanedOptions.from = mergedOptions.from
                cleanedOptions.to = mergedOptions.to
                return self.web3.eth.sendTransactionPromise(transaction, CeloTransactionOptions: cleanedOptions, password: password)
            }
        }
        
        public func send(password:String = Setting.password, CeloTransactionOptions: CeloTransactionOptions? = nil) throws -> CeloTransactionSendingResult {
            return try self.sendPromise(password: password, CeloTransactionOptions: CeloTransactionOptions).wait()
        }
        
        public func assemble(CeloTransactionOptions: CeloTransactionOptions? = nil) throws -> CeloTransaction {
            return try self.assemblePromise(CeloTransactionOptions: CeloTransactionOptions).wait()
        }
    }

    public class func readSmartContract(contractAddress: String,
                                        functionName: String,
                                        abi: String, parameters: [Any],
                                        value: String = "0.0") -> Promise<[String: Any]> {
        return Promise<[String: Any]> { seal in

            guard let address = CeloSDK.shared.address else {
                throw CeloError.invalidAddress
            }

            guard let walletAddress = EthereumAddress(address) else {
                throw CeloError.invalidAddress
            }

            guard let contractAddress = EthereumAddress(contractAddress) else {
                throw CeloError.invalidAddress
            }

            let abiVersion = 2
            let extraData: Data = Data()
            let contract = CeloSDK.contractkit.getContractKit(web3Instance: CeloSDK.shared.web3Instance, abi, at: contractAddress)
            let amount = Web3.Utils.parseToBigUInt(value, units: .eth)

            var options = CeloTransactionOptions.defaultOptions
            options.value = value == "0.0" ? nil : amount
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            guard let tx = contract!.read(
                functionName,
                parameters: parameters as [AnyObject],
                extraData: extraData,
                CeloTransactionOptions: options
            ) else {
                throw CeloError.contractFailure
            }

            firstly {
                tx.callPromise()
            }.done { result in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }



    // MARK: - Sign chainId Transaction

    func transfer(toAddress: String, value: BigUInt, data: Data = Data(),
                  gasPrice: GasPrice = GasPrice.average,
                  gasLimit: CeloTransactionOptions.GasLimitPolicy = .automatic) -> Promise<String> {
        return Promise<String> { seal in

            var method: Promise<String>?
         
            method = CeloTransactionManager.shared.sendCeloSync(to: toAddress, amount: value,
                                                                 data: data,
                                                                 gasPrice: gasPrice,
                                                                 gasLimit: gasLimit)
          
         

            guard let block = method else {
                throw CeloError.insufficientBalance
            }

            block.done { txHash in
                seal.fulfill(txHash)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    // MARK: - Sign Send Transaction
    class func signTransaction(to address: String,
                               amount: BigUInt,
                               data: Data,
                               detailObject: Bool = false,
                               gasPrice: GasPrice = GasPrice.average) throws -> String {
        guard let toAddress = EthereumAddress(address) else {
            throw CeloError.invalidAddress
        }

        guard let address = CeloSDK.shared.address else {
            throw CeloError.invalidAddress
        }

        guard let walletAddress = EthereumAddress(address) else {
            throw CeloError.invalidAddress
        }
                var celoBalance =  "0"
        CeloSDK.balance.getCeloBalance { balance in
            celoBalance = balance ?? "0"
                       }
        
        guard let etherBalanceInDouble = Double(celoBalance) else {
            throw CeloError.conversionFailure
        }

        guard let amountInDouble = Double(amount.readableValue) else {
            throw CeloError.conversionFailure
        }

        guard etherBalanceInDouble >= amountInDouble else {
            throw CeloError.notEnoughBalance
        }
                guard let keystore = try? CeloSDK.shared.loadKeystore() else { return "" }
     
         
        let gasPrice = gasPrice.wei
        let value = amount
        var options = CeloTransactionOptions.defaultOptions
        options.value = value
        options.from = walletAddress
        options.gasPrice = .manual(gasPrice)
        options.gasLimit = .automatic

        var tx = CeloTransaction(to: toAddress, data: data, options: options)
        do {
            try Web3Signer.signTX(transaction: &tx,
                                  keystore: keystore,
                                  account: walletAddress,
                                  password: "celosdk")



               
            
            return (tx.encode(forSignature: false, chainID: nil)?.toHexString().addHexPrefix())!
        } catch {
            CeloError.contractFailure
        }

        return "Sign Transaction Failed"
    }


 
  
}





