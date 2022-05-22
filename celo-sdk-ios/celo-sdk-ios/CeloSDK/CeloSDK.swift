import Foundation
import SwiftyUserDefaults
import web3swift

 public class CeloSDK {
     public static let shared = CeloSDK.init()
     public static var currentAccount: Account?
     public let contractKit : ContractKit = ContractKit()
     public static let accountWithMnemonic: AccountService = CeloSDK.shared
     
//     let keystoreDirectoryName = "/keystore"
//     let keystoreFileName = "/key.json"
//     let mnemonicsKeystoreKey = "mnemonicsKeystoreKey"
     
     let keystoreDirectoryName = Setting.KeystoreDirectoryName
     let keystoreFileName = Setting.KeystoreFileName
     let mnemonicsKeystoreKey = Setting.KeyMnemonicKey
     
     var keystoreCache: EthereumKeystoreV3?
    static var Accounts: [Account]? {
        didSet {
            if oldValue == CeloSDK.Accounts {
                return
            }
            CeloSDK.storeAccountsToCache()
        }
    }

    static var currentNetwork: Web3NetEnum = .main
    static var customNetworkList: [Web3NetModel] = []


//     public static var web3Net:Web3! = try! Web3.new(URL(string: Setting.web3url)!)
     public static var web3Net:web3!

    var keystore: BIP32Keystore?

     public init() {
         Configuration.changeEnvironment(isProduction: false)
         print("###### celo sdk address #####")
         print(Setting.web3url)
         do {
             if let url = URL(string: Setting.web3url) {
                 CeloSDK.web3Net = try Web3.new(url)
             }
         } catch {
             print("unable to create web3 url \(error)")
         }
     }
     
     public func initializeWalletConnect(onCompletion:@escaping(() -> Void))
     {
         onBackgroundThread {
             CeloSDK.loadFromCache()
             if CeloSDK.hasWallet() {
                 print("already has wallet")
                 WalletCore.shared.loadFromCache()
                 onMainThread {
                     onCompletion()
                     Configuration.saveWalletAddress(CeloSDK.currentAccount?.address)
                 }
             } else {
                 CeloSDK.createWallet { () -> Void in
                     print("created wallert")
                     WalletCore.shared.loadFromCache()
                     onMainThread {
                         onCompletion()
                         Configuration.saveWalletAddress(CeloSDK.currentAccount?.address)
                     }
                 }
             }
         }
//         UserDefaults.standard.set(CeloSDK.currentAccount?.address, forKey: "WalletAddress")
     }
     
     
    static func hasWallet() -> Bool {
//        if CeloSDK.currentAccount != nil, CeloSDK.Accounts!.count > 0 {
//
//            let address = (CeloSDK.currentAccount?.address)!
//            print("###################### Address ############################")
//            print(address)
//            print("###################### Printed ############################")
//
//            return true
//        }
//        return false
        let address = (CeloSDK.currentAccount?.address)
        print("###################### Address ############################")
        print(address ?? "NO address available")
        print("###################### Printed ############################")
        
        
        return CeloSDK.currentAccount != nil && (CeloSDK.Accounts ?? []).count > 0
    }

    class func addKeyStoreIfNeeded() {
        
//        if !CeloSDK.hasWallet() {
//            return
//        }

        guard let keystore = CeloSDK.shared.keystore,
              CeloSDK.hasWallet(),
              CeloSDK.web3Net.provider.attachedKeystoreManager != nil else {
                  print("addKeyStoreIfNeeded failured guard statement")
            return
        }

//        if CeloSDK.web3Net.provider.attachedKeystoreManager != nil {
//            return
//        }

        CeloSDK.web3Net.addKeystoreManager(KeystoreManager([keystore]))
    }

    class func loadFromCache() {
        guard let keystore = try? CeloSDK.shared.loadKeystore() else {
            return
        }
        // Load web3 net from user default
        web3Net = CeloSDK.fetchFromCache()
        CeloSDK.shared.loadRPCFromCache()
        CeloSDK.shared.keystore = keystore

        do {
            let accounts = try CeloSDK.fetchAccountsFromCache().wait()
            var index = Defaults[\.defaultAccountIndex]
            // fix defaultAccountIndex is out of range
            if index > accounts.count - 1 {
                Defaults[\.defaultAccountIndex] = 0
                index = 0
            }
            CeloSDK.currentAccount = accounts[index]
            CeloSDK.addKeyStoreIfNeeded()

        } catch {
            print("Waiting for account loading fail")
        }
    }

    // MARK: - Wallet

    class func createWallet(completion: VoidBlock?) {


        if CeloSDK.hasWallet() {
            HUDManager.shared.showError(text: "You already had a wallet")
            return
        }

        do {
            let bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
            let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!

            KeychainHepler.shared.saveToKeychain(value: mnemonics, key: Setting.MnemonicsKey)

            let keystore = try BIP32Keystore(mnemonics: mnemonics)
            let defaultAccount = Defaults[\.defaultAccountIndex]
            let address = keystore!.addresses![defaultAccount].address
            let wallet = Account(address: address)

            CeloSDK.Accounts = [wallet]
            CeloSDK.currentAccount = wallet
            CeloSDK.shared.keystore = keystore
            try! CeloSDK.shared.saveKeystore(keystore!)
            CeloSDK.addKeyStoreIfNeeded()

            guard let completion = completion else { return }
            completion!()

        } catch {
            HUDManager.shared.showError(text: "Create Wallet Failed")
        }
    }

    class func importWallet(mnemonics: String, completion: VoidBlock?) throws {
        if CeloSDK.hasWallet() {
            return
        }

        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics) else {
            throw CeloError.malformedKeystore
        }

        do {
            KeychainHepler.shared.saveToKeychain(value: mnemonics, key: Setting.MnemonicsKey)
            if (keystore.addresses ?? []).count > 0, let address = keystore.addresses?.first?.address {
                let wallet = Account(address: address)

                CeloSDK.Accounts = [wallet]

                CeloSDK.currentAccount = wallet

                CeloSDK.shared.keystore = keystore
                try CeloSDK.shared.saveKeystore(keystore)

                CeloSDK.web3Net.addKeystoreManager(KeystoreManager([keystore]))
//                guard let completion = completion else { return }
                if let unwrapped = completion {
                    unwrapped!()
                }
            }
        } catch {
            HUDManager.shared.showError(text: "Import Wallet Failed")
        }
    }
}
