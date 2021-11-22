import Foundation
import PromiseKit
import web3swift

extension CeloWalletManager {
    // MARK: - Account

    class func storeAccountsDetails() {
        do {
            let data = try JSONEncoder().encode(CeloWalletManager.Accounts!)
            Defaults[\.accountsData] = data

        } catch {
            TLog(CeloError.createAccountFailure)
           
        }
    }
    
    public func celoBalanceSync() throws -> String {
        guard let address = address else { throw CeloError.accountDoesNotExist }
        guard let ethereumAddress = CeloAddress(address) else { throw CeloError.invalidAddress }
        
        guard let balanceInWei = try? web3Instance.eth.getBalance(address: ethereumAddress) else {
            throw WalletError.networkFailure
        }
        
        guard let balanceInEtherUnitStr = Web3.Utils.formatToEthereumUnits(balanceInWei, toUnits: Web3.Utils.Units.eth, decimals: 8, decimalSeparator: ".") else { throw WalletError.conversionFailure }
        
        return balanceInEtherUnitStr
    }
    
    public func celoBalance(completion: @escaping (String?) -> ()) {
        DispatchQueue.global().async {
            let balance = try? self.celoBalanceSync()
            DispatchQueue.main.async {
                completion(balance)
            }
        }
    }
    

    class func fetchAccountsFromCache() -> Promise<[Account]> {
        return Promise<[Account]> { seal in

            guard let data = Defaults[\.accountsData] else {
                if Defaults[\.isFirstTimeOpen] == false {
                    let error = CeloError.custom("Decode accounts failed")
                    seal.reject(error)
                }
                return
            }
            do {
                let accounts = try JSONDecoder().decode([Account].self, from: data)
                CeloWalletManager.Accounts = accounts
                seal.fulfill(accounts)
            } catch {
                let error = CeloError.custom("Decode accounts failed")
                seal.reject(error)
            }
        }
    }

    class func createAccount() {
        let oldPaths = CeloWalletManager.shared.keystore!.paths.keys

        do {
            try CeloWalletManager.shared.keystore?.createNewChildAccount()
            try CeloWalletManager.shared.saveKeystore(CeloWalletManager.shared.keystore!)

            let animal = Constant.randomUDID()
            let name = "\(animal.firstUppercased) Wallet"

            let newPaths = CeloWalletManager.shared.keystore!.paths.keys

            let newPath = newPaths.filter { !oldPaths.contains($0) }.first!
            let address = CeloWalletManager.shared.keystore!.paths[newPath]!.address
            let account = Account(address: address, name: name, imageName: animal)
            CeloWalletManager.Accounts?.append(account)


        } catch {
            TLog(error: CeloError.createAccountFailure)
        }
    }

    class func deleteAccount() {
        if CeloWalletManager.Accounts!.count <= 1 {
            TLog("Can't delete the last account")
            return
        }
    }

    class func switchAccount(account: Account) {
        // if same account, not change
        if account == CeloWalletManager.currentAccount {
            return
        }

        CeloWalletManager.currentAccount = account
        Defaults[\.defaultAccountIndex] = CeloWalletManager.Accounts!.firstIndex(of: account)!
        NotificationCenter.default.post(name: .accountChange, object: nil)
    }

    func walletChange() {
        Defaults[\.defaultAccountIndex] = 0
        CeloWalletManager.storeAccountsToCache()
    }

    // MARK: - Account info

    func updateAccount(account: Account, imageName: String?, name: String?) {
        guard let index = CeloWalletManager.Accounts?.firstIndex(of: account) else {
            return
        }

        if let image = imageName {
            CeloWalletManager.Accounts?[index].imageName = image
        }

        if let walletName = name {
            CeloWalletManager.Accounts![index].name = walletName
        }

        CeloWalletManager.storeAccountsToCache()

        if account == CeloWalletManager.currentAccount {
            if let image = imageName {
                CeloWalletManager.currentAccount?.imageName = image
            }

            if let walletName = name {
                CeloWalletManager.currentAccount?.name = walletName
            }
        }

    }
}
