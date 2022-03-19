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
    
fileprivate func parseToElement(from abiRecord: CeloABI.Record, type: CeloABI.ElementType) throws -> ABI.Element {
    switch type {
    case .function:
        let function = try parseFunction(abiRecord: abiRecord)
        return CeloABI.Element.function(function)
    case .constructor:
        let constructor = try parseConstructor(abiRecord: abiRecord)
        return CeloABI.Element.constructor(constructor)
    case .fallback:
        let fallback = try parseFallback(abiRecord: abiRecord)
        return CeloABI.Element.fallback(fallback)
    case .event:
        let event = try parseEvent(abiRecord: abiRecord)
        return CeloABI.Element.event(event)
    case .receive:
        let receive = try parseReceive(abiRecord: abiRecord)
        return CeloABI.Element.receive(receive)
    }
    
}

fileprivate func parseFunction(abiRecord:CeloABI.Record) throws -> ABI.Element.Function {
    let inputs = try abiRecord.inputs?.map({ (input:CeloABI.Input) throws -> CeloABI.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs != nil ? inputs! : [CeloABI.Element.InOut]()
    let outputs = try abiRecord.outputs?.map({ (output:CeloABI.Output) throws -> ABI.Element.InOut in
        let nativeOutput = try output.parse()
        return nativeOutput
    })
    let abiOutputs = outputs != nil ? outputs! : [CeloABI.Element.InOut]()
    let name = abiRecord.name != nil ? abiRecord.name! : ""
    let payable = abiRecord.stateMutability != nil ?
        (abiRecord.stateMutability == "payable" || abiRecord.payable ?? false) : false
    let constant = (abiRecord.constant == true || abiRecord.stateMutability == "view" || abiRecord.stateMutability == "pure")
    let functionElement = CeloABI.Element.Function(name: name, inputs: abiInputs, outputs: abiOutputs, constant: constant, payable: payable)
    return functionElement
}

fileprivate func parseFallback(abiRecord:CeloABI.Record) throws -> CeloABI.Element.Fallback {
    let payable = (abiRecord.stateMutability == "payable" || abiRecord.payable == true)
    var constant = abiRecord.constant == true
    if (abiRecord.stateMutability == "view" || abiRecord.stateMutability == "pure") {
        constant = true
    }
    let functionElement = CeloABI.Element.Fallback(constant: constant, payable: payable)
    return functionElement
}

fileprivate func parseConstructor(abiRecord:CeloABI.Record) throws -> CeloABI.Element.Constructor {
    let inputs = try abiRecord.inputs?.map({ (input:CeloABI.Input) throws -> CeloABI.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs != nil ? inputs! : [CeloABI.Element.InOut]()
    var payable = false
    if (abiRecord.payable != nil) {
        payable = abiRecord.payable!
    }
    if (abiRecord.stateMutability == "payable") {
        payable = true
    }
    let constant = false
    let functionElement = CeloABI.Element.Constructor(inputs: abiInputs, constant: constant, payable: payable)
    return functionElement
}

fileprivate func parseEvent(abiRecord:CeloABI.Record) throws -> ABI.Element.Event {
    let inputs = try abiRecord.inputs?.map({ (input:CeloABI.Input) throws -> ABI.Element.Event.Input in
        let nativeInput = try input.parseForEvent()
        return nativeInput
    })
    let abiInputs = inputs != nil ? inputs! : [CeloABI.Element.Event.Input]()
    let name = abiRecord.name != nil ? abiRecord.name! : ""
    let anonymous = abiRecord.anonymous != nil ? abiRecord.anonymous! : false
    let functionElement = CeloABI.Element.Event(name: name, inputs: abiInputs, anonymous: anonymous)
    return functionElement
}

fileprivate func parseReceive(abiRecord:CeloABI.Record) throws -> CeloABI.Element.Receive {
    let inputs = try abiRecord.inputs?.map({ (input:CeloABI.Input) throws -> CeloABI.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs != nil ? inputs! : [ABI.Element.InOut]()
    var payable = false
    if (abiRecord.payable != nil) {
        payable = abiRecord.payable!
    }
    if (abiRecord.stateMutability == "payable") {
        payable = true
    }
    let functionElement = CeloABI.Element.Receive(inputs: abiInputs, payable: payable)
    return functionElement
}

extension CeloABI.Input {
    func parse() throws -> CeloABI.Element.InOut {
        let name = self.name != nil ? self.name! : ""
        let parameterType = try ABITypeParser.parseTypeString(self.type)
        if case .tuple(types: _) = parameterType {
            let components = try self.components?.compactMap({ (inp: CeloABI.Input) throws -> CeloABI.Element.ParameterType in
                let input = try inp.parse()
                return input.type
            })
            let type = CeloABI.Element.ParameterType.tuple(types: components!)
            let nativeInput = CeloABI.Element.InOut(name: name, type: type)
            return nativeInput
        }
        else if case .array(type: .tuple(types: _), length: _) = parameterType {
            let components = try self.components?.compactMap({ (inp: CeloABI.Input) throws -> CeloABI.Element.ParameterType in
                let input = try inp.parse()
                return input.type
            })
            let tupleType = CeloABI.Element.ParameterType.tuple(types: components!)
            
            let newType: CeloABI.Element.ParameterType = .array(type: tupleType, length: 0)
            let nativeInput = CeloABI.Element.InOut(name: name, type: newType)
            return nativeInput
        }
        else {
            let nativeInput = CeloABI.Element.InOut(name: name, type: parameterType)
            return nativeInput
        }
    }
    
    func parseForEvent() throws -> CeloABI.Element.Event.Input{
        let name = self.name != nil ? self.name! : ""
        let parameterType = try ABITypeParser.parseTypeString(self.type)
        let indexed = self.indexed == true
        return ABI.Element.Event.Input(name:name, type: parameterType, indexed: indexed)
    }
}


}
