//
//  ERC20.swift
//   
//

//   .
//

import Foundation
import HandyJSON

struct ERC20: HandyJSON {
    var address: String!
    var name: String!
    var symbol: String!
    var decimals: Int!
    var lastUpdated: Int!
    var description: String?
    var website: String?


    var balance: Double!

    init() {}

    init(address: String) {
        self.address = address
    }

  
}

extension ERC20: Hashable, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.address == rhs.address
    }

    var hashValue: Int {
        return address.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
}
