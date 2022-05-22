

import Foundation
import PromiseKit
import SwiftyUserDefaults
import web3swift

extension CeloSDK {
    // MARK: - Account

    class func storeAccountsToCache() {
        do {
            if let accounts = CeloSDK.Accounts {
                let data = try JSONEncoder().encode(accounts)
                Defaults[\.accountsData] = data
            }
        } catch {
            HUDManager.shared.showError(error: CeloError.createAccountFailure)
        }
    }

    class func fetchAccountsFromCache() -> Promise<[Account]> {
        return Promise<[Account]> { seal in

            guard let data = Defaults[\.accountsData] else {
                // Not first time open
                if Defaults[\.isFirstTimeOpen] == false {
                    let error = CeloError.custom("Decode accounts failed")
                    HUDManager.shared.showError(error: error)
                    seal.reject(error)
                }
                return
            }
            do {
                let accounts = try JSONDecoder().decode([Account].self, from: data)
                CeloSDK.Accounts = accounts
                seal.fulfill(accounts)
            } catch {
                let error = CeloError.custom("Decode accounts failed")
                HUDManager.shared.showError(error: error)
                seal.reject(error)
            }
        }
    }

    class func createAccount() {


        do {
            if let oldPaths = CeloSDK.shared.keystore?.paths.keys,let keystore = CeloSDK.shared.keystore {
                try CeloSDK.shared.keystore?.createNewChildAccount()
                try CeloSDK.shared.saveKeystore(keystore)
                let newPaths = keystore.paths.keys
                let newPath = newPaths.filter { !oldPaths.contains($0) }.first!
                if let address = keystore.paths[newPath]?.address {
                    let account = Account(address: address)
                    CeloSDK.Accounts?.append(account)
                }
            }
        } catch {
            HUDManager.shared.showError(error: CeloError.createAccountFailure)
        }
    }
}
