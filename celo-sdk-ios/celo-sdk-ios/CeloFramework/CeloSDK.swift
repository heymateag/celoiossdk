import web3swift

import BigInt

public class CeloSDK {
    public static let shared = CeloSDK()
    public static let account: AccountService = CeloSDK.shared
    public static let balance: BalanceService = CeloSDK.shared

    
    public var web3Main = Web3.InfuraMainnetWeb3()
    let keystoreDirectoryName = "/keystore"
    let keystoreFileName = "/key.json"
    let mnemonicsKeystoreKey = "mnemonicsKeystoreKey"

    
//    var transactionOptions: TransactionOptions
    var keystoreCache: EthereumKeystoreV3?
    
    var web3Instance: web3 {
        return web3Main
    }
    
    private init() {
        guard URL(string: "https://alfajores-forno.celo-testnet.org") != nil else { return }

        do {
            let net = try CeloSDK.make(customURL: "https://alfajores-forno.celo-testnet.org")
            self.web3Main = net
         
        } catch {
            //handle error
            print(error)
        }

        

    }
    
}


