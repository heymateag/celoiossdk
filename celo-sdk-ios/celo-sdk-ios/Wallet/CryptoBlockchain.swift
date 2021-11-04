

import Foundation

import web3swift

enum CryptoBlockChain: String, CaseIterable {
    case Celo

}

extension CryptoBlockChain {

    var symbol: String {
        switch self {
        case .Celo:
            return "Celo"
        }
    }

    var decimal: Int {
        switch self {
        case .Celo:
            return 18

        }
    }

    var explorer: URL {
        switch self {
        case .Celo:
            return URL(string: "https://explorer.celo.org")!
        }
    }

    var basicInfo: TokenInfo {
        var info = TokenInfo()
        info.decimals = decimal
        info.symbol = symbol
        switch self {
        case .Celo:
            info.decimals = decimal
            info.name = "Celo"
            info.symbol = symbol
            info.description = "Celo is a mobile-first platform that makes financial dApps and crypto payments accessible to anyone with a mobile phone."

        }
        return info
    }

    func txURL(txHash: String, network: Web3NetEnum? = WalletManager.currentNetwork) -> URL {
        switch self {
        case .Celo:
            return PinItem.txURL(network: network ?? CeloWalletManager.currentNetwork, txHash: txHash)
        }
    }

    func verify(address: String) -> Bool {
        switch self {
        case .Celo:
            guard let addr = web3swift.EthereumAddress(address), addr.isValid else {
                return false
            }
            return true
        }
    }
}
