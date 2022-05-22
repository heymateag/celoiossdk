//
//  GasPriceMinimumWrapper.swift
//  celo-sdk-ios
//
//  Created by Apple on 20/03/22.
//

import Foundation
import web3swift
import PromiseKit
import BigInt

//todo should this be public so all methods inside?
public struct GasPriceMinimumWrapper
{
    public init()
    {}
    public func getGasPriceMinimum(accountOwner: String) -> Promise<BigUInt> {
        let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.GasPriceMinimum)
        return Promise {seal in
            firstly {
                getGasPriceMinimumAddress()
            }.done { address in
                if let ethAddress = EthereumAddress(address),
                   let celoUnwrapped = CeloSDK.currentAccount?.address,
                   let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress) {
                    var options = ContractKitOptions.defaultOptions
                    //                                let address = (CeloSDK.currentAccount?.address)!
                    let celoAddress = EthereumAddress(celoUnwrapped)
                    options.from = celoAddress
                    options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                    options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                    if let tx = contract.read(
                        GAS_PRICE_MINIMUM.FUNCTION_GET_GASPRICE_MINIMUM,
                        parameters: [CeloSDK.shared.contractKit.getFeeCurrency()] as [AnyObject],
                        extraData: Data(),
                        transactionOptions: options) {
                        print("wait here")
                        var stableTokenBal:BigUInt = BigUInt(0)
                        let  gasPriceVal = try tx.callPromise(transactionOptions: options).wait()
                        if let balanceBigUInt =  gasPriceVal["0"] as? BigUInt {
                            print(" gasPriceVal \( gasPriceVal)")
                            let multiplied = balanceBigUInt*10
                            stableTokenBal = multiplied
                            seal.fulfill(stableTokenBal)
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
    
    func getGasPriceMinimumAddress() -> Promise<String> {

        return Promise { seal in
            if let address = Configuration.getGasPriceMinimumAddress(),!address.isEmpty {
                seal.fulfill(address)
            } else {
                firstly {
                    AddressRegistry.init().getAdressForString(contractName: CeloContractClass.GasPriceMinimum.rawValue)
                }.done { address in
                    seal.fulfill(address)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }
}
