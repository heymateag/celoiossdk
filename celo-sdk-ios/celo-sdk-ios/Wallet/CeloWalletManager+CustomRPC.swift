

import Foundation


extension CeloWalletManager {
    func addCeloServer(model: Web3NetModel) {
        CeloWalletManager.customNetworkList.append(model)
        storeCeloServerToCache()
    }

    func updateCeloServer(oldModel: Web3NetModel, newModel: Web3NetModel) {
        guard let index = CeloWalletManager.customNetworkList.firstIndex(of: oldModel) else {
            return
        }
        CeloWalletManager.customNetworkList[index] = newModel

        if CeloWalletManager.currentNetwork.model == oldModel {
            CeloWalletManager.currentNetwork = Web3NetEnum(model: newModel)
        }

        storeCeloServerToCache()
    }

    func deleteCeloServer(model: Web3NetModel) {
        guard let index = CeloWalletManager.customNetworkList.firstIndex(of: model) else {
            return
        }
        CeloWalletManager.customNetworkList.remove(at: index)

        if CeloWalletManager.currentNetwork.model == model {
            CeloWalletManager.currentNetwork = .main
        }

        storeCeloServerToCache()
    }

    func loadCeloServerFromCache() {
        Shared.stringCache.fetch(key: CacheKey.web3CustomCeloServerKey).onSuccess { string in
            guard let list = Web3NetModelList.deserialize(from: string) else {
                return
            }
            WalletManager.customNetworkList = list.list
        }
    }

    func storeCeloServerToCache() {
        let list = Web3NetModelList(list: CeloWalletManager.customNetworkList)
        guard let listString = list.toJSONString() else {
            return
        }
        Shared.stringCache.set(value: listString, key: CacheKey.web3CustomCeloServerKey)
        NotificationCenter.default.post(name: .customCeloServerChange, object: nil)
    }

    func removeAllCeloServer() {
        CeloWalletManager.customNetworkList = []
        Shared.stringCache.remove(key: CacheKey.web3CustomCeloServerKey)
    }
}
