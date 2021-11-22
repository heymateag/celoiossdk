

import Foundation
import web3swift

class CeloWalletManager {
    static let shared = CeloWalletManager()
    public static let account: AccountService = CeloWalletManager.shared
    public static let balance: BalanceService = CeloWalletManager.shared
    public static let address: AddressService = CeloWalletManager.shared
    public static let contractkit: ContractKit = CeloWalletManager.shared
    static var currentAccount: Account?
    static var Accounts: [Account]? {
        didSet {
            if oldValue == CeloWalletManager.Accounts {
                return
            }
            CeloWalletManager.storeAccountsToCache()
        }
    }

    static var currentNetwork: CeloServerEnum = .main
    static var customNetworkList: [CeloServerModel] = []
    
    var web3ServerUrl = Web3.InfuraMainnetWeb3()

    guard let urlStr = URL(string: "https://alfajores-forno.celo-testnet.org") else { return }

    do {
        web3ServerUrl = try Web3.new(urlStr)
        
    } catch {
        Tlog("error initializing")
    }
    
    var keystore: BIP32Keystore?

    class func hasWallet() -> Bool {
        if CeloWalletManager.currentAccount != nil, CeloWalletManager.Accounts!.count > 0 {
            return true
        }
        return false
    }

    class func addKeyStoreIfNeeded() {
        if !CeloWalletManager.hasWallet() {
            return
        }

        guard let keystore = CeloWalletManager.shared.keystore else {
            return
        }

        if CeloWalletManager.web3ServerUrl.provider.attachedKeystoreManager != nil {
            return
        }

        CeloWalletManager.web3ServerUrl.addKeystoreManager(KeystoreManager([keystore]))
    }

    class func loadFromCache() {
        guard let keystore = try? CeloWalletManager.shared.loadKeystore() else {
            return
        }

        web3ServerUrl = CeloWalletManager.fetchFromCache()

        CeloWalletManager.shared.loadCeloServerFromCache()

        CeloWalletManager.shared.keystore = keystore
        // Wait for acccunt loaded
        do {
            let accounts = try CeloWalletManager.fetchAccountsFromCache().wait()
            var index = Defaults[\.defaultAccountIndex]
            if index > accounts.count - 1 {
                Defaults[\.defaultAccountIndex] = 0
                index = 0
            }
            CeloWalletManager.currentAccount = accounts[index]
            CeloWalletManager.addKeyStoreIfNeeded()

        } catch {
            print("Waiting for account loading fail")
        }
    }

    // MARK: - Wallet

    class func createWallet(completion: VoidBlock?) {
//        let Mnemonics =  KeychainHepler.fetchKeychain(key: Setting.MnemonicsKey)

        if CeloWalletManager.hasWallet() {
            TLog("You already had a wallet")
            return
        }

        do {
            let bitsOfEntropy: Int = 128
            let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!

            KeychainHepler.shared.saveToKeychain(value: mnemonics, key: Setting.MnemonicsKey)

            let keystore = try BIP32Keystore(mnemonics: mnemonics)
            let animal = Constant.randomUDID()
            let name = "\(animal.firstUppercased) Wallet"
            let defaultAccount = Defaults[\.defaultAccountIndex]
            let address = keystore!.addresses![defaultAccount].address
            let wallet = Account(address: address, name: name, imageName: animal)

            CeloWalletManager.Accounts = [wallet]
            CeloWalletManager.currentAccount = wallet
            CeloWalletManager.shared.keystore = keystore
            try! CeloWalletManager.shared.saveKeystore(keystore!)
            CeloWalletManager.addKeyStoreIfNeeded()

            guard let completion = completion else { return }
            completion!()

        } catch {
            TLog("Create Wallet Failed")
        }
    }

    class func importWallet(mnemonics: String, completion: VoidBlock?) throws {
        if CeloWalletManager.hasWallet() {

            return
        }

        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics) else {
            throw CeloError.malformedKeystore
        }

        do {
            KeychainHepler.shared.saveToKeychain(value: mnemonics, key: Setting.MnemonicsKey)

            let animal = Constant.randomUDID()
            let name = "\(animal.firstUppercased) Wallet"
            let address = keystore.addresses!.first!.address
            let wallet = Account(address: address, name: name, imageName: animal)

            CeloWalletManager.Accounts = [wallet]
            CeloWalletManager.currentAccount = wallet

            CeloWalletManager.shared.keystore = keystore
            try CeloWalletManager.shared.saveKeystore(keystore)

            CeloWalletManager.web3ServerUrl.addKeystoreManager(KeystoreManager([keystore]))

            guard let completion = completion else { return }
            completion!()
        } catch {
            TLog("Import Wallet Failed")
        }
    }



    // MARK: - Check Mnemonic

    func checkMnemonic() {
        /// Fist time open app
        if Defaults[\.isFirstTimeOpen] {
            guard let mnemonic = KeychainHepler.shared.fetchKeychain(key: Setting.MnemonicsKey) else {
                return
            }

            if CeloWalletManager.hasWallet() {
                return
            }
            return
        }

        /// Not Fist time open app
        guard let mnemonic = KeychainHepler.shared.fetchKeychain(key: Setting.MnemonicsKey) else {
            /// Mnemonics LOST !!!

            do {
                let keystore = try CeloWalletManager.shared.loadKeystore()
                let jsonData = try JSONEncoder().encode(keystore.keystoreParams)
                let jsonString = String(data: jsonData, encoding: .utf8)!




            } catch {
                TLog("Celo Mnemonic not found in your Keychain")
            }

            return
        }
    }
}
