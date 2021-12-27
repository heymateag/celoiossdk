import web3swift

import BigInt

public class CeloSDK {
    public static let shared = CeloSDK(customUrl: Constants.ALFAJORES_URL)
    public static let account: AccountService = CeloSDK.shared
    public static let balance: BalanceService = CeloSDK.shared
    public static let contractkit: ContractKit = CeloSDK.shared

    
    public var web3Main = Web3.InfuraMainnetWeb3()
    let keystoreDirectoryName = "/keystore"
    let keystoreFileName = "/key.json"
    let mnemonicsKeystoreKey = "mnemonicsKeystoreKey"
    var keystoreCache: EthereumKeystoreV3?
    
    
    public func newKitFromWeb3(_web3InstanceFromUrl: web3) ->web3swift.web3.web3contract?
    {
        let contractCeloAddress = EthereumAddress(Constants.GOLD_TOKEN_CONTRACT_ADDRESS)!
        let bundle = Bundle(identifier: Constants.SDK_PRODUCT_IDENTIFIER)
        let bundlePath = bundle!.path(forResource: "registry_contracts", ofType: "json")
        let jsonString = try! String(contentsOfFile: bundlePath!)
        let contract = CeloSDK.contractkit.getContractKit(web3Instance: _web3InstanceFromUrl,jsonString, at: contractCeloAddress)
        return contract
    }
    var web3Instance: web3 {
        return web3Main
    }
    
    public init(customUrl : String) {
        
        
        let bundle = Bundle(identifier: "com.heymate.celo-sdk-ios")
        let bundlePath = bundle!.path(forResource: "registry_contracts", ofType: "json")
        
        
//        for i in
        do {
            self.web3Main = try CeloSDK.createWeb3Instance(customURL: customUrl)
        } catch {
            print(error)
        }

    }
    
}


