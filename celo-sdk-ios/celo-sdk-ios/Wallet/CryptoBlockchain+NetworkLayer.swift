
import BigInt
import Foundation
import PromiseKit
import web3swift

extension CryptoBlockChain: NetworkLayer {
    func getBalance() -> Promise<BigUInt> {
        return Promise<BigUInt> { seal in
            switch self {
            case .Celo:
                guard let address = WalletManager.currentAccount?.address else {
                    seal.reject(WalletError.accountDoesNotExist)
                    return
                }
                guard let ethereumAddress = EthereumAddress(address) else {
                    seal.reject(WalletError.invalidAddress)
                    return
                }
                firstly {
                    WalletManager.web3Net.eth.getBalancePromise(address: ethereumAddress)
                }.done { balanceStr in
                    seal.fulfill(balanceStr)
                }.catch { error in
                    seal.reject(error)
                }
    
            default:
                seal.fulfill(0)
            }
        }
    }


}
