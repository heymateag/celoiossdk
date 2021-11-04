//
//  KaychainHelper.swift
//  Celo SDK
//
//  Created by sreedeeppaul on 10/6/21.
//  Copyright © 2021 sreedeeppaul. All rights reserved.
//

import Foundation


class KeychainHepler {
    static let shared = KeychainHepler()

    var keychain: Keychain?

    private init() {
        keychain = Keychain(service: Setting.CeloKeychainPrefix)
            .label("Celo Mnemonic")
            .synchronizable(true)
    }

    func saveToKeychain(value: String, key: String) {
        do {
            try keychain?.synchronizable(true).set(value, key: key)
        } catch {
            TLog("Save mnemonic to keychain failed")
        }
    }

    func fetchKeychain(key: String) -> String? {
        do {
            let value = try keychain?.get(key)
            return value
        } catch {
            TLog("Fetch mnemonic from keychain failed")
        }
        return nil
    }
}
