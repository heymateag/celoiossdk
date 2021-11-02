//
//  ICOError.swift
//  ICO
//
//  Created by SREEDEEP PAUL on 02/08/18.
//  Copyright © 2018 SREEDEEP PAUL. All rights reserved.
//

import UIKit
import Foundation

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

    case unKnown
    case custom(String)

    public var code: Int {
        switch self {
        case .generic:
            return 700
        case .hasAccount:
            return 2201
        case .accountDoesNotExist:
            return 2202
        case .invalidKey:
            return 2204
        case .invalidAddress:
            return 2205
        case .malformedKeystore:
            return 2207
        case .networkFailure:
            return 2208
        case .conversionFailure:
            return 2209
        case .insufficientBalance:
            return 2210
        case .contractFailure:
            return 2211
        case .encryptFailure:
            return 2214
        case .decryptFailure:
            return 2215
        case .createAccountFailure:
            return 2216
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
        case .invalidKey:
            return "Account does not exist"
        case .invalidAddress:
            return "Invalid address"
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
