//
//  ContractKit.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 04/11/21.
//

import Foundation
import web3swift

public protocol ContractKit {
    func getContractKit(web3Instance: web3 ,_ abiString: String, at: web3swift.EthereumAddress) -> web3swift.web3.web3contract?
}

extension CeloSDK: ContractKit {
public func getContractKit(web3Instance: web3 ,_ abiString: String, at: web3swift.EthereumAddress) -> web3swift.web3.web3contract?
{
    let contract = web3Instance.contract(abiString, at: at, abiVersion: 2)!
    
    return contract
}
    
}


/// ABI for data about a function or event within a contract
public struct CeloABIObject: Codable {

    public enum ObjectType: String, Codable {
        // event
        case event
        
        // normal function
        case function
        
        // constructor function. can't have name or outputs
        case constructor
        
        // http://solidity.readthedocs.io/en/v0.4.21/contracts.html#fallback-function
        case fallback
    }
    
    /// Celo Value passed into our returned from a method or event
    public struct Parameter: Codable {
        let name: String
        let type: String
    }
    
    // Celo true if function is pure or view
    let constant: Bool?
    
    // Celo input parameters
    let inputs: [Parameter]?
    
    // Celo output parameters
    let outputs: [Parameter]?
    
    // Celo name of the function or event (not available for fallback or constructor functions)
    let name: String?
    
    // Celo type of function (constructor, function, or fallback) or event
    // can be omitted, defaulting to function
    // constructors never have name or outputs
    // fallback function never has name outputs or inputs
    let type: ObjectType
    
    // Celo true if function accepts ether
    let payable: Bool?


    
    public init(decoder: Decoder) throws {
        self.constant = try container.decode(Bool.self, forKey: .constant)
        self.inputs = try container.decode([Parameter].self, forKey: .inputs)
        self.outputs = try container.decode([Parameter].self, forKey: .outputs)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(ObjectType.self, forKey: .type) ?? .function
        self.payable = try container.decode(Bool.self, forKey: .payable) ?? false
        self.anonymous = try container.decode(Bool.self, forKey: .anonymous)
    }
}
