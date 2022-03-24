//
//  WalletError.swift
//   
//
//    .
//   .
//

import web3swift

public enum CeloError: Error {
    case hasAccount
    case accountDoesNotExist
    case invalidPath
    case invalidKey
    case invalidAddress
    case messageFailedToData
    case malformedKeystore
    case networkFailure
    case conversionFailure
    case insufficientBalance
    case contractFailure
    case netCacheFailure
    case netSwitchFailure
    case encryptFailure
    case decryptFailure
    case createAccountFailure
    case unexpectedResult
    case invalidMnemonics
    case unKnown
    case custom(String)

    public var code: Int {
        switch self {
        case .unKnown:
            return 100
        case .hasAccount:
            return 1701
        case .accountDoesNotExist:
            return 1702
        case .invalidPath:
            return 1703
        case .invalidKey:
            return 1704
        case .invalidAddress:
            return 1705
        case .messageFailedToData:
            return 1706
        case .malformedKeystore:
            return 1707
        case .networkFailure:
            return 1708
        case .conversionFailure:
            return 1709
        case .insufficientBalance:
            return 1710
        case .contractFailure:
            return 1711
        case .netCacheFailure:
            return 1712
        case .netSwitchFailure:
            return 1713
        case .encryptFailure:
            return 1714
        case .decryptFailure:
            return 1715
        case .createAccountFailure:
            return 1716
        default:
            return -1
        }
    }

    public var errorDescription: String {
        switch self {
        case .unKnown:
            return "Unknown Error"
        case .hasAccount:
            return "Already has a acoount"
        case .accountDoesNotExist:
            return "Account does not exist"
        case .invalidPath:
            return "Invaild path"
        case .invalidKey:
            return "Account does not exist"
        case .invalidAddress:
            return "Invalid address"
        case .messageFailedToData:
            return "Fail to covert message to data"
        case .malformedKeystore:
            return "Malformed keystore"
        case .networkFailure:
            return "Network failure"
        case .conversionFailure:
            return "Conversion failure"
        case .insufficientBalance:
            return "Insufficient balance"
        case .contractFailure:
            return "Contract failure"
        case .netCacheFailure:
            return "Web3Net cache failure"
        case .netSwitchFailure:
            return "Switch network failure"
        case .encryptFailure:
            return "Encrpyt failure"
        case .decryptFailure:
            return "Decrpyt failure"
        case .createAccountFailure:
            return "Create account failure"
        case let .custom(msg):
            return msg
        default:
            return "Wallet Unknow Error"
        }
    }

    public var errorMessage: String {
        let errorCode = "code: " + "\(self.code) - "
        return "\(errorCode)" + self.errorDescription
    }
}

public enum ContractError: Error {
    case invalidABI
    case invalidMethodParams
    case invalidAddress
    case malformedKeystore
    case networkFailure
    case contractFailure
}
