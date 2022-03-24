//
//  WalletStruct.swift
//   
//
//    .
//   .
//

import Foundation


 public struct Account: Codable {
     public let address: String
}

extension Account: Hashable, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.address == rhs.address
    }

    public var hashValue: Int {
        return address.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
}

struct HDKey {
    let name: String?
    let address: String
}
