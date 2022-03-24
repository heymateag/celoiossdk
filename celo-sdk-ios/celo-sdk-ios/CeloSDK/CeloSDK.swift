import Foundation
import SwiftyUserDefaults
import web3swift

 public class CeloSDK {
     public static let shared = CeloSDK()
     public static var currentAccount: Account?
     public let contractKit : ContractKit = ContractKit()
     public static let accountWithMnemonic: AccountService = CeloSDK.shared
     
     let keystoreDirectoryName = "/keystore"
     let keystoreFileName = "/key.json"
     let mnemonicsKeystoreKey = "mnemonicsKeystoreKey"
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


    public static var web3Net = try! Web3.new(URL(string: Setting.web3url)!)


    var keystore: BIP32Keystore?

     public init() {
         Configuration.changeEnvironment(isProduction: true)
         print("###### celo sdk address #####")
         print(Setting.web3url)
     }
     
     public func initializeWalletConnect(onCompletion:@escaping(() -> Void))
     {
         CeloSDK.loadFromCache()
         if CeloSDK.hasWallet() {
             print("already has wallet")
             WalletCore.shared.loadFromCache()
             onCompletion()

         } else {
             CeloSDK.createWallet { () -> Void in
                 print("created wallert")
                 WalletCore.shared.loadFromCache()
                 onCompletion()
             }
         }
         
       
         UserDefaults.standard.set(CeloSDK.currentAccount?.address, forKey: "WalletAddress")

     }
     
     
     
    class func hasWallet() -> Bool {
        if CeloSDK.currentAccount != nil, CeloSDK.Accounts!.count > 0 {
            
            let address = (CeloSDK.currentAccount?.address)!
            print("###################### Address ############################")
            print(address)
            print("###################### Printed ############################")

            return true
        }
        return false
    }

    class func addKeyStoreIfNeeded() {
        
        if !CeloSDK.hasWallet() {
            return
        }

        guard let keystore = CeloSDK.shared.keystore else {
            return
        }

        if CeloSDK.web3Net.provider.attachedKeystoreManager != nil {
            return
        }

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

            let address = keystore.addresses!.first!.address
            let wallet = Account(address: address)

            CeloSDK.Accounts = [wallet]

            CeloSDK.currentAccount = wallet

            CeloSDK.shared.keystore = keystore
            try CeloSDK.shared.saveKeystore(keystore)

            CeloSDK.web3Net.addKeystoreManager(KeystoreManager([keystore]))

            guard let completion = completion else { return }
            completion!()
        } catch {
            HUDManager.shared.showError(text: "Import Wallet Failed")
        }
    }


}
