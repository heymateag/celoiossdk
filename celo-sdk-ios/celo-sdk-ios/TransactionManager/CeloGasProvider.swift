//
//  CeloTransactionManager.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 27/12/21.
//

import Foundation
import BigInt

import PromiseKit
import web3swift



private let defaultGasLimitForTransaction = 100_000
private let defaultGasLimitForTokenTransfer = 100_000

extension CeloTransactionManager {
    // Return GWEI

    func gasForContractMethod(to address: String,
                              contractABI: String,
                              methodName: String,
                              methodParams: [AnyObject],
                              amount: BigUInt,
                              data: Data) -> Promise<BigUInt> {
        return Promise { seal in
            guard let toAddress = EthereumAddress(address) else {
                seal.reject(CeloError.accountDoesNotExist)
                return
            }
            guard let contract = CeloSDK.contractkit.getContractKit(web3Instance: CeloSDK.shared.web3Main, contractABI, at: toAddress) else {
                seal.reject(CeloError.contractFailure)
                return
            }
            let value = amount
            var options = TransactionOptions.defaultOptions
            options.value = value
            options.from = toAddress
            options.to = toAddress
            options.gasLimit = .automatic
            options.gasPrice = .automatic

            guard let tx = contract.write(
                methodName,
                parameters: methodParams,
                extraData: data,
                transactionOptions: options
            ) else {
                seal.reject(CeloError.contractFailure)
                return
            }

            tx.estimateGasPromise().done { value in
                seal.fulfill(value)
            }.catch { error in
                print(error.localizedDescription)
                seal.reject(error)
            }
        }
    }
}

import BigInt
import Foundation
import PromiseKit
import web3swift




extension BigInt {
    var eth: Float {
        let ethValue = Web3.Utils.formatToEthereumUnits(BigUInt(self),
                                                        toUnits: .eth,
                                                        decimals: 6,
                                                        decimalSeparator: ".")
        return Float(ethValue!) as! Float
    }

    var currency: Float {
        return eth * 100
    }
}

extension BigUInt {
    var gweiToEth: Float {
        // Gwei 9  Eth 18
        let ethValue = Web3.Utils.formatToEthereumUnits(self,
                                                        toUnits: .Gwei,
                                                        decimals: 6,
                                                        decimalSeparator: ".")
        return Float(ethValue!)!
    }

    var currency: Float {
        return (gweiToEth * 50)
    }

  

    var readableValue: String {
        let string = Web3Utils.formatToEthereumUnits(self, toUnits: .eth, decimals: 5, decimalSeparator: ".")!
        return string
    }

    func readableValue(decimals: Int) -> String {
        guard let string = Web3Utils.formatToPrecision(self, numberDecimals: decimals, formattingDecimals: 5, decimalSeparator: ".", fallbackToScientific: false) else {
            return ""
        }
        //            .formatToEthereumUnits(self, toUnits: .eth, decimals: 5, decimalSeparator: ".")!
        return string
    }

    func formatToPrecision(decimals: Int, removeZero: Bool = true, scientific: Bool = false) -> String? {
        guard let string = Web3.Utils.formatToPrecision(self, numberDecimals: decimals, formattingDecimals: decimals, decimalSeparator: ".", fallbackToScientific: scientific),
              let amountInDouble = Double(string) else {
            return nil
        }

        if removeZero {
            return String(format: "%g", amountInDouble)
        }

        return String(amountInDouble)
    }
}


enum GasPrice {
    case fast
    case average
    case slow
    case custom(BigUInt)

    // TODO: FIX Custom

    // GWei
    var price: Float {
        switch self {
        case .fast:
            return GasPriceHelper.shared.fast ?? 10
        case .average:
            return GasPriceHelper.shared.average ?? 3
        case .slow:
            return GasPriceHelper.shared.safeLow ?? 1
        case let .custom(wei):
            guard let str = Web3.Utils.formatToEthereumUnits(wei, toUnits: .Gwei, decimals: 18, decimalSeparator: ".") else {
                return GasPriceHelper.shared.average ?? 3
            }
            return Float(str)!
        }
    }

    var time: Float {
        switch self {
        case .fast:
            return GasPriceHelper.shared.fastWait ?? 1
        case .average:
            return GasPriceHelper.shared.avgWait ?? 3
        case .slow:
            return GasPriceHelper.shared.safeLowWait ?? 10
        case .custom:
            return GasPriceHelper.shared.avgWait ?? 3
        }
    }

    var wei: BigUInt {
        // GWei to wei 9
        switch self {
        case .fast, .average, .slow:
            let wei = self.price * pow(10, 9)
            return BigUInt(wei)
        case let .custom(wei):
            return wei
        }
    }

    var timeString: String {
        return "~ \(self.time) mins"
    }

    var option: String {
        switch self {
        case .fast:
            return "fast"
        case .slow:
            return "slow"
        case .average:
            return "average"
        case let .custom(gas):
            return String(gas, radix: 16)
        }
    }

    static func make(string: String) -> GasPrice? {
        switch string {
        case "fast":
            return GasPrice.fast
        case "slow":
            return GasPrice.slow
        case "average":
            return GasPrice.average
        default:
            if let gasPrice = BigUInt(string.stripHexPrefix(), radix: 16) {
                return .custom(gasPrice)
            }
            return nil
        }
    }

    func toEth(gasLimit: BigUInt) -> Float {
        return gasLimit.gweiToEth * self.price
    }

  
}

class GasPriceHelper {
    static let shared = GasPriceHelper()
    var timeInterval: TimeInterval = 60 * 30



    var safeLow: Float?
    var average: Float?
    var fast: Float?

    // Minutes
    var safeLowWait: Float?
    var avgWait: Float?
    var fastWait: Float?



}
