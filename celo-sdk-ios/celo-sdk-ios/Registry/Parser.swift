//
//  Parser.swift
//  TestVerloopPods
//
//  Created by Vankireddy, BharathkumarReddy on 16/03/22.
//

import Foundation

//enum Contract:String {
//    case Registry
//    case Accounts
//    case Attestations
//    case BlockchainParameters
//    case DoubleSigningSlasher
//    case DowntimeSlasher
//    case Election
//    case Escrow
//    case Exchange
//    case Freezer
//    case GasPriceMinimum
//    case GoldToken
//    case Governance
//    case LockedGold
//    case MultiSig
//    case ReleaseGold
//    case Reserve
//    case SortedOracles
//    case StableToken
//    case Validators
//}

enum ContractSubKeys:String {
    case ABI
    case Address
}
 
struct Parser {
    
    func getContractDetailsFor(contract:CeloContractClass,requiredData:ContractSubKeys) -> String {
        var desiredData = ""
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            let parsedData = parseRegistry()
            if !parsedData.keys.isEmpty {
                if let requiredObject = parsedData[contract.rawValue] as? [String:Any] {
                    if requiredData == .Address {
                        desiredData = requiredObject[ContractSubKeys.Address.rawValue] as? String ?? ""
                        group.leave()
                    } else if requiredData == .ABI {
                        if let abi = requiredObject[ContractSubKeys.ABI.rawValue] as? [Any] {
                            do {
                                let abiData = try JSONSerialization.data(withJSONObject: abi, options: .fragmentsAllowed)
                                desiredData = String(data: abiData, encoding: .utf8) ?? ""
                                group.leave()
                            } catch {
                                print("abi parse error \(error)")
                                group.leave()
                            }
                        } else {
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        group.wait()
        return desiredData
    }
    
    
    func getABIFor(key:CeloContractClass) -> String {
        var abiString = ""
        let group = DispatchGroup()
        group.enter()

        DispatchQueue.global(qos: .background).async {
            let parsedData = parseRegistry()
            if !parsedData.keys.isEmpty {
                if let requiredObject = parsedData[key.rawValue] as? [String:Any] {
                    if let abi = requiredObject[ContractSubKeys.ABI.rawValue] as? [Any] {
                        do {
                            let abiData = try JSONSerialization.data(withJSONObject: abi, options: .fragmentsAllowed)
                            abiString = String(data: abiData, encoding: .utf8) ?? ""
    //                        print("abiString \(abiString)")
//                            return abiString
                            group.leave()
                        } catch {
                            print("abi parse error \(error)")
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        group.wait()
//        group.notify(queue: .global(qos: .default)) {
//            print("notified")
//        }

        return abiString
    }
    
    func getAddressFor(contract:CeloContractClass) -> String {
        var address = ""
        let group = DispatchGroup.init()
        group.enter()
        
        DispatchQueue.global(qos: .background).async {
            let parsedData = parseRegistry()
            if !parsedData.keys.isEmpty {
                if let desiredAddress = parsedData[contract.rawValue] as? [String:Any] {
                    address = desiredAddress[ContractSubKeys.Address.rawValue] as? String ?? ""
                    group.leave()
                } else {
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        group.wait()
        
        return address
    }
    
    func parseRegistry() -> [String:Any] {
        let bundle = Bundle(identifier: "com.heymate.celo-sdk-ios")
        
//        /Bundle.main.url(forResource: "registry_contracts", withExtension: ".json")
        
        if let bundlePath = bundle!.path(forResource: "registry_contracts", ofType: "json") {
            let url = URL.init(fileURLWithPath: bundlePath)
            do {
                let data = try Data.init(contentsOf: url)
                if let jsonModel = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [CeloContractClass.RawValue:Any] {
                    return jsonModel
//                    if let registry = jsonModel[Contract.Registry.rawValue] as? [String:Any] {
//                        if let abi = registry["ABI"] as? [Any] {
////                            print("abi of registry \(abi)")
//                            do {
//                                let abiData = try JSONSerialization.data(withJSONObject: abi, options: .fragmentsAllowed)
//                                let abiString = String(data: abiData, encoding: .utf8)
//                                print("abiString \(abiString)")
//                            } catch {
//                                print("abi parse error \(error)")
//                            }
//                        }
//                    }
                }
            } catch {
                print("parser error \(error)")
            }
        } else {
            print("file not found")
        }
        return [:]
    }
}


