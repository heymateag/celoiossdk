//
//  ICOUtils.swift
//  ICO
//
//  Created by SREEDEEP PAUL on 17/08/18.
//  Copyright © 2018 SREEDEEP PAUL. All rights reserved.
//

import UIKit
import Foundation

struct Account: Codable {
    let address: String
    var name: String

}

extension Account: Hashable, Equatable {
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

struct HDKey {
    let name: String?
    let address: String
}

public func TLog(_ entry: String) {
    #if DEBUG
        print(entry)
    #endif
}
func validateNil<T>(value:T?) throws -> T {
    
    guard let data = value else {
        throw CeloError.unKnown
    }
    
    return data
    
}


func isNil<T>(value:T?) throws -> T {
    
    guard let data = value else {
        throw CeloError.unKnown
    }
    
    return data
    
}


func isNil<T>(data:T?) -> Bool {
    if data == nil {
        return false
    }
    return true
    
}

public func JSONToString<T:JsonEncodable>(_ payload: T ) -> String? {
    if let data = try? JSONSerialization.data(withJSONObject: payload.mapJson().serialize()) {
        let payload = String(data: data, encoding: .utf8)
        TLog(payload ?? "nil")
        return payload
    }
    
    return nil
}


public func JSONToData<T:JsonEncodable>(_ payload: T ) throws -> Data? {
    guard let data = try? JSONSerialization.data(withJSONObject: payload.mapJson().serialize())  else {
        
        throw CeloError.custom("unable to convert it to json")
    }
    
    return data
}


public func JsonToData<T:JsonEncodable>(_ payload: T ) throws -> Data? {
    
    return try JSONSerialization.data(withJSONObject: payload.mapJson().serialize())
}

public func StringToJson(provisionCacheDataString:String) throws -> [String:Any]? {
    
    
    guard let provisionCacheDataStringUtf8 = provisionCacheDataString.data(using: .utf8) else {
        throw CeloError.custom("provisionCacheDataString is nil or empty")
    }
    
    guard let provisionCacheDataJson = try? JSONSerialization.jsonObject(with: provisionCacheDataStringUtf8, options: []) as? [String: AnyObject] else {
        
        throw CeloError.custom("unable to convert it to json")
    }
    return provisionCacheDataJson ?? nil
    
}



public protocol JsonEncodable {
    func mapJson() -> Json
}

public protocol JsonDecodable {
    init?(json: [String: Any])
}

public enum Json {
    case dict([String: Json])
    case array([Json])
    case string(String?)
    case number(NSNumber)
    case bool(Bool)
    case null
}

extension Json {
    public func serialize() -> Any {
        switch self {
        case let .dict(dict):
            var serializedDict = [String: Any]()
            for (key, value) in dict {
                serializedDict[key] = value.serialize()
            }
            return serializedDict
        case let .array(array):
            return array.map { $0.serialize() }
        case let .string(string?):
            return string
        case let .number(number):
            return number
        case let .bool(bool):
            return NSNumber(booleanLiteral: bool)
        case .null:
            return NSNull()
        default:
            return NSNull()
            
        }
    }
}

extension Json: Equatable {
    public static func == (lhs: Json, rhs: Json) -> Bool {
        switch (lhs, rhs) {
        case let (.dict(l), .dict(r)):
            return l == r
        case let (.array(l), .array(r)):
            return l == r
        case let (.string(l), .string(r)):
            return l == r
        case let (.number(l), .number(r)):
            return l == r
        case let (.bool(l), .bool(r)):
            return l == r
        case (.null, .null):
            return true
        default:
            return false
        }
        
    }
}

func getUUID() ->String
{
    return UUID().uuidString.replacingOccurrences(of: "-", with: "")
}

