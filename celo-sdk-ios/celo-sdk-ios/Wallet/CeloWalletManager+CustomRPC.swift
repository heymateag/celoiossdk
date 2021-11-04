import Foundation


extension CeloWalletManager {
    func addCeloServer(model: CeloServerModel) {
        CeloWalletManager.customNetworkList.append(model)
        storeCeloServerToCache()
    }

    func updateCeloServer(oldModel: CeloServerModel, newModel: CeloServerModel) {
        guard let index = CeloWalletManager.customNetworkList.firstIndex(of: oldModel) else {
            return
        }
        CeloWalletManager.customNetworkList[index] = newModel

        if CeloWalletManager.currentNetwork.model == oldModel {
            CeloWalletManager.currentNetwork = CeloServerEnum(model: newModel)
        }

        storeCeloServerToCache()
    }

    func deleteCeloServer(model: CeloServerModel) {
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
            guard let list = CeloServerModelList.deserialize(from: string) else {
                return
            }
            WalletManager.customNetworkList = list.list
        }
    }

    func storeCeloServerToCache() {
        let list = CeloServerModelList(list: CeloWalletManager.customNetworkList)
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
