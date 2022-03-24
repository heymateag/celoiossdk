//
//  WalletCoreManager.swift
//   
//

//   .
//

import Foundation
import WalletCore

class WalletCore {
    static let shared = WalletCore()
    static var wallet: HDWallet!

    class func hasWallet() -> Bool {
        if WalletCore.wallet != nil {
            return true
        }
        return false
    }

    init() {

    }

    func loadFromCache() {
        guard let mnemonic = KeychainHepler.shared.fetchKeychain(key: Setting.MnemonicsKey) else {
            return
        }
        WalletCore.wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
    }



    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func updateWallet() {
        let mnemonic = KeychainHepler.shared.fetchKeychain(key: Setting.MnemonicsKey)
        WalletCore.wallet = HDWallet(mnemonic: mnemonic!, passphrase: "")
    }
}
