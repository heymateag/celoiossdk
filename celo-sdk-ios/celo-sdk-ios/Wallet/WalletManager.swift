

import Foundation
import web3swift

class WalletManager {
    static let shared = WalletManager()
    static var currentAccount: Account?
    static var Accounts: [Account]? {
        didSet {
            if oldValue == WalletManager.Accounts {
                return
            }
            WalletManager.storeAccountsToCache()
        }
    }

    static var currentNetwork: Web3NetEnum = .main
    static var customNetworkList: [Web3NetModel] = []
    static var web3Net = Web3.InfuraMainnetWeb3()


    var keystore: BIP32Keystore?

    class func hasWallet() -> Bool {
        if WalletManager.currentAccount != nil, WalletManager.Accounts!.count > 0 {
            return true
        }
        return false
    }

    class func addKeyStoreIfNeeded() {
        if !WalletManager.hasWallet() {
            return
        }

        guard let keystore = WalletManager.shared.keystore else {
            return
        }

        if WalletManager.web3Net.provider.attachedKeystoreManager != nil {
            return
        }

        WalletManager.web3Net.addKeystoreManager(KeystoreManager([keystore]))
    }

    class func loadFromCache() {
        guard let keystore = try? WalletManager.shared.loadKeystore() else {
            return
        }

        web3Net = WalletManager.fetchFromCache()

        WalletManager.shared.loadRPCFromCache()

        WalletManager.shared.keystore = keystore
        // Wait for acccunt loaded
        do {
            let accounts = try WalletManager.fetchAccountsFromCache().wait()
            var index = Defaults[\.defaultAccountIndex]
            if index > accounts.count - 1 {
                Defaults[\.defaultAccountIndex] = 0
                index = 0
            }
            WalletManager.currentAccount = accounts[index]
            WalletManager.addKeyStoreIfNeeded()

        } catch {
            print("Waiting for account loading fail")
        }
    }

    // MARK: - Wallet

    class func createWallet(completion: VoidBlock?) {
//        let Mnemonics =  KeychainHepler.fetchKeychain(key: Setting.MnemonicsKey)

        if WalletManager.hasWallet() {
            TLog(text: "You already had a wallet")
            return
        }

        do {
            let bitsOfEntropy: Int = 128
            let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!

            KeychainHepler.shared.saveToKeychain(value: mnemonics, key: Setting.MnemonicsKey)

            let keystore = try BIP32Keystore(mnemonics: mnemonics)
            let animal = Constant.randomAnimal()
            let name = "\(animal.firstUppercased) Wallet"
            let defaultAccount = Defaults[\.defaultAccountIndex]
            let address = keystore!.addresses![defaultAccount].address
            let wallet = Account(address: address, name: name, imageName: animal)

            WalletManager.Accounts = [wallet]
            WalletManager.currentAccount = wallet
            WalletManager.shared.keystore = keystore
            try! WalletManager.shared.saveKeystore(keystore!)
            WalletManager.addKeyStoreIfNeeded()

            guard let completion = completion else { return }
            completion!()

        } catch {
            TLog(text: "Create Wallet Failed")
        }
    }

    class func importWallet(mnemonics: String, completion: VoidBlock?) throws {
        if WalletManager.hasWallet() {

            return
        }

        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics) else {
            throw WalletError.malformedKeystore
        }

        do {
            KeychainHepler.shared.saveToKeychain(value: mnemonics, key: Setting.MnemonicsKey)

            let animal = Constant.randomAnimal()
            let name = "\(animal.firstUppercased) Wallet"
            let address = keystore.addresses!.first!.address
            let wallet = Account(address: address, name: name, imageName: animal)

            WalletManager.Accounts = [wallet]
            WalletManager.currentAccount = wallet

            WalletManager.shared.keystore = keystore
            try WalletManager.shared.saveKeystore(keystore)

            WalletManager.web3Net.addKeystoreManager(KeystoreManager([keystore]))

            guard let completion = completion else { return }
            completion!()
        } catch {
            TLog(text: "Import Wallet Failed")
        }
    }

    class func replaceWallet(mnemonics: String, completion _: VoidBlock?) {
        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics) else {
            // TODO: ENSURE

            TLog(text: WalletError.malformedKeystore.errorDescription)
            return
        }

        do {
            KeychainHepler.shared.saveToKeychain(value: mnemonics, key: Setting.MnemonicsKey)
            let animal = Constant.randomAnimal()
            let name = "\(animal.firstUppercased) Wallet"

            let address = keystore.addresses!.first!.address
            let wallet = Account(address: address, name: name, imageName: animal)

            WalletManager.currentAccount = wallet
            WalletManager.Accounts = [wallet]


            WalletManager.shared.keystore = keystore
            try WalletManager.shared.saveKeystore(keystore)

            WalletManager.web3Net.addKeystoreManager(KeystoreManager([keystore]))

            TLog(text: "Replace wallet success")

            WalletManager.shared.walletChange()

        } catch {
            TLog(text: "Replace Wallet Failed")
        }
    }


    // MARK: - Check Mnemonic

    func checkMnemonic() {
        /// Fist time open app
        if Defaults[\.isFirstTimeOpen] {
            guard let mnemonic = KeychainHepler.shared.fetchKeychain(key: Setting.MnemonicsKey) else {
                return
            }

            if WalletManager.hasWallet() {
                return
            }
            return
        }

        /// Not Fist time open app
        guard let mnemonic = KeychainHepler.shared.fetchKeychain(key: Setting.MnemonicsKey) else {
            /// Mnemonics LOST !!!

            do {
                let keystore = try WalletManager.shared.loadKeystore()
                let jsonData = try JSONEncoder().encode(keystore.keystoreParams)
                let jsonString = String(data: jsonData, encoding: .utf8)!




            } catch {
                TLog("Celo Mnemonic not found in your Keychain")
            }

            return
        }
    }
}
