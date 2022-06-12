//
//  AttestationsWrapper.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 29/05/22.
//

import Foundation
import web3swift
import PromiseKit
import BigInt

public class AttestationsWrapper {
   public class AttestationStat {
       var completed : Int32 = 0
       var total : Int32 = 0
    }
    public class UnselectedRequest {

        var blockNumber : BigUInt = 0
        var attestationsRequested : BigUInt = 0
        var attestationRequestFeeToken : String = ""

       }
    
    public func getAttestationStats(identifier:Data,account:String) -> Promise<AttestationStat> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise {seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        ATTESTATION_CONTRACT.FUNCTION_GET_ATTESTATION_STATS,
                        parameters: [identifier, account as Any] as [AnyObject],
                        extraData: Data(),
                        transactionOptions: options) {
 
                        let  attestationstate = try tx.callPromise(transactionOptions: options).wait()
                        let attestatationstateInit = AttestationStat.init()
                        attestatationstateInit.completed = attestationstate["0"] as! Int32
                        attestatationstateInit.total = attestationstate["1"] as! Int32
                        seal.fulfill(attestatationstateInit)
                        
                    } else {
                        seal.reject(CeloError.contractFailure)
                    }
                } else {
                    seal.reject(CeloError.accountDoesNotExist)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getCompletableAttestations(identifier:Data,account:String) -> Promise<(blockNumbers:[BigUInt], issuers:[String],whereToBreakTheString:[BigUInt],metadataURLs:Data)> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise {seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        ATTESTATION_CONTRACT.FUNCTION_GET_COMPLETABLE_ATTESTATIONS,
                        parameters: [identifier, account as Any] as [AnyObject],
                        extraData: Data(),
                        transactionOptions: options) {
                    
 
//                        blockNumbers, issuers, whereToBreakTheString, metadataURLs
                        var rawCompletableAttestations : (blockNumbers:[BigUInt], issuers:[String],whereToBreakTheString:[BigUInt],metadataURLs:Data)
                        let PromiserawCompletableAttestations = try tx.callPromise(transactionOptions: options).wait()
                        rawCompletableAttestations.blockNumbers = PromiserawCompletableAttestations["0"] as! [BigUInt]
                        rawCompletableAttestations.issuers = PromiserawCompletableAttestations["1"] as! [String]
                        rawCompletableAttestations.whereToBreakTheString = PromiserawCompletableAttestations["2"] as! [BigUInt]
                        rawCompletableAttestations.metadataURLs = PromiserawCompletableAttestations["3"] as! Data
                        seal.fulfill(rawCompletableAttestations)
                       
                    } else {
                        seal.reject(CeloError.contractFailure)
                    }
                } else {
                    seal.reject(CeloError.accountDoesNotExist)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    public func lookupAccountsForIdentifier(identifier:Data) -> Promise<[String]> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise {seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        ATTESTATION_CONTRACT.FUNCTION_LOOKUP_ACCOUNTS_IDENTIFIER,
                        parameters: [identifier as Any] as [AnyObject],
                        extraData: Data(),
                        transactionOptions: options) {
 
                        let  accountsForIdentifier  = try tx.callPromise(transactionOptions: options).wait()
                        let accountsForIdentifierVal =  accountsForIdentifier["0"] as! [String]
                            seal.fulfill(accountsForIdentifierVal)
                       
                    } else {
                        seal.reject(CeloError.contractFailure)
                    }
                } else {
                    seal.reject(CeloError.accountDoesNotExist)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getUnselectedRequest(identifier:Data,account:String) -> Promise<UnselectedRequest> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise {seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        ATTESTATION_CONTRACT.FUNCTION_GET_UNSELECTED_REQUEST,
                        parameters: [identifier, account as Any] as [AnyObject],
                        extraData: Data(),
                        transactionOptions: options) {
 
                        let  attestationstate = try tx.callPromise(transactionOptions: options).wait()
                        let unSelectedRequestInit = UnselectedRequest.init()
                        unSelectedRequestInit.blockNumber = attestationstate["0"] as! BigUInt
                        unSelectedRequestInit.attestationsRequested = attestationstate["1"] as! BigUInt
                        unSelectedRequestInit.attestationRequestFeeToken = attestationstate["2"] as! String
                        seal.fulfill(unSelectedRequestInit)
                    } else {
                        seal.reject(CeloError.contractFailure)
                    }
                } else {
                    seal.reject(CeloError.accountDoesNotExist)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getAttestationExpiryBlocks() -> Promise<BigUInt> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise {seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        ATTESTATION_CONTRACT.FUNCTION_GET_ATTESTATION_EXPIRY_BLOCKS,
                        parameters: [AnyObject](),
                        extraData: Data(),
                        transactionOptions: options) {
 
                        let  attestationstate = try tx.callPromise(transactionOptions: options).wait()
                        if let attestationExpiryValue =  attestationstate["0"] as? BigUInt {
                            seal.fulfill(attestationExpiryValue)
                        } else {
                            seal.reject(CeloError.conversionFailure)
                        }
                    } else {
                        seal.reject(CeloError.contractFailure)
                    }
                } else {
                    seal.reject(CeloError.accountDoesNotExist)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func request(identifier:Data,attestationsRequested:BigUInt,attestationRequestFeeToken:String) -> Promise<String> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise<String> { seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    
                    
                    firstly {
                        CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType: .Attestations)
                    }.done { gasprice in
                        
                     print(gasprice)

                        options.gasPrice = .manual(gasprice)
                        options.gasLimit = .manual(10000000)
                        options.value = Web3.Utils.parseToBigUInt("0", units: .eth)
                        options.from = celoAddress
                        
                        
                        guard let tx = contract.write(
                            ATTESTATION_CONTRACT.FUNCTION_REQUEST,
                            parameters: [identifier as Any] as [AnyObject],
                            extraData: Data(),
                            transactionOptions: options)
                        else {
                            seal.reject(CeloError.contractFailure)
                            return
                        }
                        
                        firstly {
                            tx.sendPromise(password: "web3swift", transactionOptions: options)
                        }.done { result in
                            seal.fulfill(result.hash)
                            
                            
                        }.catch { error in
                            print(error)
                            seal.reject(error)
                        }
                    }

        }
    }
        }
    }
    public func getAttestationRequestFee(token:String) -> Promise<BigUInt> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise {seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        ATTESTATION_CONTRACT.FUNCTION_GET_ATTESTATION_REQUEST_FEE,
                        parameters: [token  as Any] as [AnyObject],
                        extraData: Data(),
                        transactionOptions: options) {
 
                        let  attestationstate = try tx.callPromise(transactionOptions: options).wait()
                        if let attestationRequestFee =  attestationstate["0"] as? BigUInt {
                            seal.fulfill(attestationRequestFee)
                        } else {
                            seal.reject(CeloError.conversionFailure)
                        }
                    } else {
                        seal.reject(CeloError.contractFailure)
                    }
                } else {
                    seal.reject(CeloError.accountDoesNotExist)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func selectIssuers(identifier:Data) -> Promise<String> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise<String> { seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    
                    
                    firstly {
                        CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType: .Attestations)
                    }.done { gasprice in
                        
                     print(gasprice)

                        options.gasPrice = .manual(gasprice)
                        options.gasLimit = .manual(10000000)
                        options.value = Web3.Utils.parseToBigUInt("0", units: .eth)
                        options.from = celoAddress
                        
                        
                        guard let tx = contract.write(
                            ATTESTATION_CONTRACT.FUNCTION_SELECT_ISSUERS,
                            parameters: [identifier as Any] as [AnyObject],
                            extraData: Data(),
                            transactionOptions: options)
                        else {
                            seal.reject(CeloError.contractFailure)
                            return
                        }
                        
                        firstly {
                            tx.sendPromise(password: "web3swift", transactionOptions: options)
                        }.done { result in
                            seal.fulfill(result.hash)
                            
                            
                        }.catch { error in
                            print(error)
                            seal.reject(error)
                        }
                    }

        }
    }
        }
    }
    
    public func selectIssuersWaitBlocks() -> Promise<BigUInt> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise {seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        ATTESTATION_CONTRACT.FUNCTION_SELECT_ISSUERS_WAIT_BLOCKS,
                        parameters: [AnyObject](),
                        extraData: Data(),
                        transactionOptions: options) {
 
                        let  attestationstate = try tx.callPromise(transactionOptions: options).wait()
                        if let selectIssuersWaitBlock =  attestationstate["0"] as? BigUInt {

                            seal.fulfill(selectIssuersWaitBlock)
                        } else {
                            seal.reject(CeloError.conversionFailure)
                        }
                    } else {
                        seal.reject(CeloError.contractFailure)
                    }
                } else {
                    seal.reject(CeloError.accountDoesNotExist)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func complete(identifier:Data,v:BigUInt,r:Data,s:Data) -> Promise<String>  {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise<String> { seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    
                    
                    firstly {
                        CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType: .Attestations)
                    }.done { gasprice in
                        
                     print(gasprice)

                        options.gasPrice = .manual(gasprice)
                        options.gasLimit = .manual(10000000)
                        options.value = Web3.Utils.parseToBigUInt("0", units: .eth)
                        options.from = celoAddress
                        
                        
                        guard let tx = contract.write(
                            ATTESTATION_CONTRACT.FUNCTION_ATTESTATION_COMPLETE,
                            parameters: [identifier,v,r,s as Any] as [AnyObject],
                            extraData: Data(),
                            transactionOptions: options)
                        else {
                            seal.reject(CeloError.contractFailure)
                            return
                        }
                        
                        firstly {
                            tx.sendPromise(password: "web3swift", transactionOptions: options)
                        }.done { result in
                            seal.fulfill(result.hash)
                            
                            
                        }.catch { error in
                            print(error)
                            seal.reject(error)
                        }
                    }

        }
    }
        }
        
    }
 
    public func validateAttestationCode(identifier:Data,account:String,v:BigUInt,r:Data,s:Data) -> Promise<String> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Attestations)
        return Promise {seal in
            firstly {
                self.getAttestationWrapperAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        ATTESTATION_CONTRACT.FUNCTION_VALIDATE_ATTESTATION_CODE,
                        parameters: [AnyObject](),
                        extraData: Data(),
                        transactionOptions: options) {
 
                        let  validateAttestationCode = try tx.callPromise(transactionOptions: options).wait()
                        let attestationAddress =  validateAttestationCode["0"] as! String
                            seal.fulfill(attestationAddress)
                       
                    } else {
                        seal.reject(CeloError.contractFailure)
                    }
                } else {
                    seal.reject(CeloError.accountDoesNotExist)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
   
    
    func getAttestationWrapperAddress() -> Promise<String> {

        return Promise { seal in
            if let address = Configuration.getAttestationWrapperAddress(),!address.isEmpty {
                seal.fulfill(address)
            } else {
                firstly {
                    AddressRegistry.init().getAdressForString(contractName: CeloContractClass.Attestations.rawValue)
                }.done { address in
                    seal.fulfill(address)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
