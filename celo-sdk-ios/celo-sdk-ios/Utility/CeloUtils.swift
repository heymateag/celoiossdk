//
//  ICOUtils.swift
//  ICO
//
//  Created by SREEDEEP PAUL on 17/08/18.
//  Copyright © 2018 SREEDEEP PAUL. All rights reserved.
//

import UIKit
import Foundation


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
        
        throw CeloError.unKnown
    }
    
    return data
}


public func JsonToData<T:JsonEncodable>(_ payload: T ) throws -> Data? {
    
    return try JSONSerialization.data(withJSONObject: payload.mapJson().serialize())
}

public func StringToJson(provisionCacheDataString:String) throws -> [String:Any]? {
    
    
    guard let provisionCacheDataStringUtf8 = provisionCacheDataString.data(using: .utf8) else {
        throw CeloError.unKnown
    }
    
    guard let provisionCacheDataJson = try? JSONSerialization.jsonObject(with: provisionCacheDataStringUtf8, options: []) as? [String: AnyObject] else {
        
        throw CeloError.unKnown
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



extension String {
    func isEthTxHash() -> Bool {
        if !hasPrefix("0x") {
            return false
        }

        if count != 66 {
            return false
        }
        return true
    }

    func isEmptyAfterTrim() -> Bool {
        let string = trimmingCharacters(in: .whitespacesAndNewlines)
        return string.count == 0
    }

    func trimed() -> String {
        let string = trimmingCharacters(in: .whitespacesAndNewlines)
        return string
    }

    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }

    func index(from: Int) -> Index {
        return index(startIndex, offsetBy: from)
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex ..< endIndex])
    }

    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == utf16.count
        } else {
            return false
        }
    }

    func validateUrl() -> Bool {
        guard !contains("..") else { return false }

        let head = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail = "\\.+[A-Za-z]{1,10}+(\\.)?+(/(.)*)?"
        let urlRegEx = head + "+(.)+" + tail

        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: trimmingCharacters(in: .whitespaces))

    }



    var drop0x: String {
        if count > 2, substring(with: 0 ..< 2) == "0x" {
            return String(dropFirst(2))
        }
        return self
    }

    func addHttpsPrefix() -> String {
        if !hasPrefix("https://") {
            return "https://" + self
        }
        return self
    }

    func addHttpPrefix() -> String {
        if !hasPrefix("http://") {
            return "http://" + self
        }
        return self
    }

    func addHexPrefix() -> String {
        if !hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }

    func dropEthPrefix() -> String {
        if hasPrefix("ethereum:") {
            return String(dropFirst(9))
        }
        return self
    }

    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }

    var firstCapitalized: String {
        return prefix(1).capitalized + dropFirst()
    }

    var hexDecodeUTF8: String? {
        guard let data = Data.fromHex(self) else {
            return nil
        }
        guard let decode = String(data: data, encoding: .utf8) else {
            return nil
        }
        return decode
    }



    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < endIndex {
            let endIndex = index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex ..< endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }

  

    func stripHexPrefix() -> String {
        if hasPrefix("0x") {
            let indexStart = index(startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }


    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }

    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return ($0 + " " + String($1))
            } else {
                return $0 + String($1)
            }
        }
    }

    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

func getUUID() ->String
{
    return UUID().uuidString.replacingOccurrences(of: "-", with: "")
}

