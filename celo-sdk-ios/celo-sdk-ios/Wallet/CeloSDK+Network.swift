//
//  WalletManager+Network.swift
//   
//

//   .
//

import BigInt
import Foundation
import HandyJSON
import PromiseKit
import web3swift
import Haneke

struct Web3NetModel: HandyJSON, Equatable {
    var name: String!
    var chainID: Int!
    var color: String!
    var rpcURL: String!

    //    static func == (lhs: Web3NetEnum, rhs: Web3NetEnum) -> Bool {
    //        return lhs.chainID == rhs.chainID && lhs.rpcURL == rhs.rpcURL
    //    }
}

struct Web3NetModelList: HandyJSON {
    var list: [Web3NetModel]!
}

enum Web3NetEnum: CaseIterable, Equatable {
    case main
    case custom(Web3NetModel)

    init(model: Web3NetModel) {
        switch model {
        case Web3NetEnum.main.model:
            self = Web3NetEnum.main
        default: // Custom
            self = Web3NetEnum.custom(model)
        }
    }

    static var allCases: [Web3NetEnum] {
        let defaultList: [Web3NetEnum] = [.main]
        let customList = CeloSDK.customNetworkList.map {
            Web3NetEnum(model: $0)
        }
        return defaultList + customList
    }

    static func == (lhs: Web3NetEnum, rhs: Web3NetEnum) -> Bool {
        return lhs.chainID == rhs.chainID && lhs.rpcURL == rhs.rpcURL && lhs.name == rhs.name
    }
}

extension Web3NetEnum {
    var name: String {
        switch self {
        case .main:
            return Setting.web3url
        case let .custom(model):
            return Setting.web3url
        default:
            return "Custom"
        }
    }

    var color: UIColor {
        switch self {
        case .main:
            return UIColor(hex: "#45A9A5")
        case let .custom(model):
            return UIColor(hex: model.color)
        default:
            return UIColor.lightGray
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .main:
            if #available(iOS 12.0, *) {
                let window = UIApplication.shared.keyWindow
                return window?.traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "434343") : UIColor(hex: "434343")
            }
            return .black
        default:
            return self.color
        }
    }

    var chainID: Int {
        switch self {
        case .main: return 1
        //        case .custom(let chainID): return chainID
        case let .custom(model):
            return model.chainID
        }
    }

    var rpcURL: URL {
        let urlString: String = {
            switch self {
            case .main: return Setting.web3url
            case let .custom(model):
                return model.rpcURL
            }
        }()
        return URL(string: urlString)!
    }

    var isUsingInfura: Bool {
        switch self {
        case .main:
            return true
        default:
            return false
        }
    }

    var isCustom: Bool {
        switch self {
        case .main:
            return false
        default:
            return true
        }
    }

    var model: Web3NetModel {
        return Web3NetModel(name: name,
                            chainID: chainID,
                            color: color.toHexString(),
                            rpcURL: rpcURL.absoluteString)
    }

    var network: Networks {
        switch self {
        case .main: return .Mainnet
        case let .custom(model):
            return .Custom(networkID: BigUInt(model.chainID))
        //        case .custom(let chainID): return .Custom(networkID: chainID)
        }
    }
}

extension CeloSDK {
    class func make(type: Web3NetEnum, customURL _: String = Setting.web3url) throws -> web3 {
        switch type {
        case .main:
            if let web3Url = URL(string: Setting.web3url) {
                do {
                    return try Web3.new(web3Url)
                } catch {
                    print("web3Url error \(error)")
                    throw CeloError.custom("WEB3URL form error")
                }
            }
        case .custom:
            do {
                let net = try CeloSDK.customNet(url: Setting.web3url)
                return net
            } catch {
                throw error
            }
        }
        return try! Web3.new(URL(string: Setting.web3url)!)
    }

    class func make(url: String) -> Promise<web3> {
        return Promise<web3> { seal in
            do {
                let net = try CeloSDK.customNet(url: url)
                seal.fulfill(net)
            } catch {
                seal.reject(error)
            }
        }
    }
    
    func loadRPCFromCache() {
        Shared.stringCache.fetch(key: CacheKey.web3CustomRPCKey).onSuccess { string in
            guard let list = Web3NetModelList.deserialize(from: string) else {
                HUDManager.shared.showError(text: "Load Custom PRC faild")
                return
            }
            CeloSDK.customNetworkList = list.list
        }
    }

   public class func customNet(url: String) throws -> web3 {
        guard let URL = URL(string: url), let web3Url = Web3HttpProvider(URL) else {
            throw CeloError.netSwitchFailure
        }

        let net = web3(provider: web3Url)
        return net
    }

    // MARK: - Cache

    class func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    class func storeInCache(type: Web3NetModel) {
        UserDefaults.standard.set(Setting.web3url, forKey: CacheKey.web3NetStoreKey)
    }

    class func fetchFromCache() -> web3 {
        UserDefaults.standard.removeObject(forKey: "heymate.web3.net")
        // Not find the key in UserDefault use MainNet
        if !CeloSDK.isKeyPresentInUserDefaults(key: CacheKey.web3NetStoreKey) {
            let net = Web3NetEnum.main
            CeloSDK.storeInCache(type: net.model)
            if let url = URL(string: Setting.web3url) {
                do {
                    return try Web3.new(url)
                }catch {
                    print("web3 url error \(error)")
                }
            }
        }

        guard let typeString = UserDefaults.standard.string(forKey: CacheKey.web3NetStoreKey),
              let model = Web3NetModel.deserialize(from: typeString) else {
            // TODO:
//            HUDManager.shared.showError(text: WalletError.netCacheFailure.errorDescription)
            return try! Web3.new(URL(string: Setting.web3url)!)
        }

        let type = Web3NetEnum(model: model)

        do {
            let net = try CeloSDK.make(type: type)
            CeloSDK.currentNetwork = type
            return net
        } catch let error as CeloError {
            HUDManager.shared.showError(text: error.errorDescription)
        } catch {
            HUDManager.shared.showError()
        }

        return try! Web3.new(URL(string: Setting.web3url)!)
    }

    class func fetchFromCache() -> String {
        guard let typeString = UserDefaults.standard.string(forKey: CacheKey.web3NetStoreKey),
              let model = Web3NetModel.deserialize(from: typeString) else {
            return "Main"
        }
        let type = Web3NetEnum(model: model)
        return type.name
    }

    class func fetchFromCache() -> Web3NetEnum {
        guard let typeString = UserDefaults.standard.string(forKey: CacheKey.web3NetStoreKey),
              let model = Web3NetModel.deserialize(from: typeString) else {
            return .main
        }

        let type = Web3NetEnum(model: model)
        return type
    }

    // MARK: - Update

 
}
