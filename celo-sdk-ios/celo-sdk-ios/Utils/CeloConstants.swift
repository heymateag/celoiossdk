
//

import UIKit
import Foundation
import SwiftyUserDefaults
import HandyJSON

typealias VoidBlock = (() -> Void)?
typealias StringBlock = ((String) -> Void)


public struct Environment {

        public static let CELO_ENVIRONMENT = "CELO_ENVIRONMENT"

    }

public struct Configuration
{
   public static func changeEnvironment(isProduction:Bool) {

        UserDefaults.standard.setValue(isProduction, forKey: Environment.CELO_ENVIRONMENT)

    }



    public static func isProductionEnvironment() -> Bool {

        return UserDefaults.standard.bool(forKey: Environment.CELO_ENVIRONMENT)

    }
    
    static func saveWalletAddress(_ address:String?) {
        UserDefaults.standard.set(address, forKey: Setting.KeyWalletAddress)
    }

    static func getGasPriceMinimumAddress() -> String? {
        return UserDefaults.standard.value(forKey: Setting.KeyGasPriceMinAddress) as? String
    }
    
    static func getStableTokenAddress() -> String? {
        return UserDefaults.standard.value(forKey: Setting.KeyStableTokenAddress) as? String
    }
    
    static func setPreviousSession(session:Data?) {
        return UserDefaults.standard.setValue(session, forKey: Setting.KeyPreviousSession)
    }
    
    static func getPreviousSession() -> Data? {
        return UserDefaults.standard.data(forKey: Setting.KeyPreviousSession)
    }
    
}


extension Notification.Name {
    static let wallectConnectServerConnect = Notification.Name("wallectConnectServerConnect")
    static let wallectConnectServerDisconnect = Notification.Name("wallectConnectServerDisconnect")

    static let wallectConnectClientConnect = Notification.Name("wallectConnectClientConnect")
    static let wallectConnectClientDisconnect = Notification.Name("wallectConnectClientDisconnect")
}
public class STABLE_TOKEN
{
    static let FUNCTION_BALANCE_OF = "balanceOf"
    static let FUNCTION_TOKEN_TRANSFER = "transfer"
}
public class GAS_PRICE_MINIMUM
{
    static let FUNCTION_GET_GASPRICE_MINIMUM = "getGasPriceMinimum"

}
public class Setting {
    public static let ALFAJORES_URL = "https://alfajores-forno.celo-testnet.org"
    public static let MAINNET_URL = "https://forno.celo.org"
    public static let MAINNET_CHAINID = 42220
    public static let ALFAJORES_CHAINID = 44787
    static let HeymateKeychainPrefix = "HeymateKeychain"
    static let MnemonicsKey = "HeymateMnemonics"
    static let WalletName = "Heymate X"
    static let KeystoreDirectoryName = "/keystore"
    static let KeystoreFileName = "/key.json"
    static let KeyMnemonicKey = "mnemonicsKeystoreKey"
    static let KeyGasPriceMinAddress = "GAS_PRICE_MIN_ADDRESS"
    static let KeyStableTokenAddress = "STABLE_TOKEN_ADDRESS"
    static let KeyPreviousSession = "P_SESSION"
    public static let password = "web3swift"
    static let KeyWalletAddress = "WalletAddress"
    public static let web3url = Configuration.isProductionEnvironment() ? MAINNET_URL:ALFAJORES_URL
    public static let celoChainid = Configuration.isProductionEnvironment() ?  MAINNET_CHAINID:ALFAJORES_CHAINID
    static let termURL = URL(string: "https://www.Heymatedapp.com/terms-of-service")!
    static let privacyURL = URL(string: "https://www.Heymatedapp.com/privacy-policy")!
    
    static let TXActionGetAddressFor = "getAddressFor"
    static let RegistryContractAddress = "0x000000000000000000000000000000000000ce10"
    static let RegistryNullAddress = "0x0000000000000000000000000000000000000000"
    
}

class CeloContract
{
    static let StableToken = "0x874069fa1eb16d44d622f2e0ca25eea172369bc1"
    static let StableTokenEUR = "0x10c892a6ec43a53e45d0b916b4b7d383b1b78c0f"
}
class CacheKey {
    static let web3NetStoreKey = "Heymate.web3.net.v1"
    static let web3CustomRPCKey = "Heymate.web3.custom.rpc"
    static let web3wcurl = "wcurl"
}
typealias MainFont = Font.HelveticaNeue


enum Font {
    enum HelveticaNeue: String {
        case ultraLightItalic = "UltraLightItalic"
        case medium = "Medium"
    

        func with(size: CGFloat) -> UIFont {
            return UIFont(name: "HelveticaNeue-\(rawValue)", size: size)!
        }
    }
}
extension DefaultsKeys {
    var isFirstTimeOpen: DefaultsKey<Bool> { return .init("isFirstTimeOpen", defaultValue: true) }
    var MnemonicsBackup: DefaultsKey<Bool> { return .init("MnemonicsBackup", defaultValue: false) }
  
    var defaultAccountIndex: DefaultsKey<Int> { return .init("defaultAccountIndex", defaultValue: 0) }

    var accountsData: DefaultsKey<Data?> { return .init("accountsData") }
}


func onMainThread(_ closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
    }
}

func onBackgroundThread(_ closure: @escaping () -> Void) {
    if !Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.global(qos: .background).async {
            closure()
        }
    }
}

