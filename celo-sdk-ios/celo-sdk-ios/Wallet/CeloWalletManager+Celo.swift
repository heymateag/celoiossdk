

import Foundation
import PromiseKit
import web3swift

extension CeloWalletManager {
    func getCeloAddressWithPromise(node: String) -> Promise<EthereumAddress> {
        return Promise<EthereumAddress> { seal in
            guard let ens = ENS(web3: CeloWalletManager.web3Net) else {
                throw CeloError.custom("Init Celo Failed")
            }

            let trimStr = node.trimmingCharacters(in: .whitespacesAndNewlines)
            do {
                try ens.getAddressWithPromise(forNode: trimStr).done { addr in
                    seal.fulfill(addr)
                }.catch { error in
                    seal.reject(error)
                }
            } catch {
                seal.reject(error)
            }
        }
    }
}
