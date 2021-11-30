import web3swift
import BigInt

public protocol BalanceService {
    func celoBalanceSync() throws -> String
    func getCeloBalance(completion: @escaping (String?) -> ())
    func celoUSDBalanceSync() throws -> String
    func getGoldToken(completion: @escaping (String?) -> ())
}

extension CeloSDK: BalanceService {
    public func celoBalanceSync() throws -> String {
        guard let address = address else { throw CeloError.accountDoesNotExist }
        guard let ethereumAddress = EthereumAddress(address) else { throw CeloError.invalidAddress }
        
        guard let balanceInWei = try? web3Instance.eth.getBalance(address: ethereumAddress) else {
            throw CeloError.networkFailure
        }
        
        guard let balanceInCeloUnitStr = Web3.Utils.formatToEthereumUnits(balanceInWei, toUnits: Web3.Utils.Units.eth, decimals: 8, decimalSeparator: ".") else { throw CeloError.conversionFailure }
        
        return balanceInCeloUnitStr
    }
    
    public func getCeloBalance(completion: @escaping (String?) -> ()) {
        DispatchQueue.global().async {
            let balance = try? self.celoBalanceSync()
            DispatchQueue.main.async {
                completion(balance)
            }
        }
    }
    
    public func celoUSDBalanceSync() throws -> String {
        let contractCeloAddress = EthereumAddress("0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1")
        guard let address = address else { throw CeloError.accountDoesNotExist }
        guard let celoAddress = EthereumAddress(address) else { throw CeloError.invalidAddress }
        let bundle = Bundle(identifier: "com.heymate.celo-sdk-ios")
        let bundlePath = bundle!.path(forResource: "registry_contracts", ofType: "json")
        let jsonString = try! String(contentsOfFile: bundlePath!)
        let contract = web3Instance.contract(jsonString, at: contractCeloAddress, abiVersion: 2)!
        var options = TransactionOptions.defaultOptions
        options.from = celoAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        let method = "balanceOf"
        let tx = contract.read(
            method,
            parameters: [address] as [AnyObject],
            extraData: Data(),
            transactionOptions: options)!
        let tokenBalance = try! tx.call()
      let balanceBigUInt = tokenBalance["0"] as! BigUInt
        let balanceString = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3)!
        
        return "\(balanceString)"
    }
    
    public func getGoldToken(completion: @escaping (String?) -> ()) {
        DispatchQueue.global().async {
            let balance = try? self.celoUSDBalanceSync()
            DispatchQueue.main.async {
                completion(balance)
            }
        }
    }
}
