import web3swift

import SwiftKeychainWrapper

public protocol AccountService {
    var hasAccount: Bool { get }
    var address: String? { get }
    var mnemonics: String? { get set }
    func privateKey(password: String) throws -> String
    func verifyPassword(_ password: String) -> Bool
    func generateAccount(password: String) throws
    func importAccount(privateKey: String, password: String) throws
    func importAccount(mnemonics: String, password: String) throws
    func loadKeystore() throws -> EthereumKeystoreV3
}


extension CeloSDK: AccountService {
    public var hasAccount: Bool {
        return (try? loadKeystore()) != nil
    }
    
    public var address: String? {
        guard let keystore = try? loadKeystore() else { return nil }
        return keystore.getAddress()?.address
    }
    
    public var mnemonics: String? {
        get {
            return KeychainWrapper.standard.string(forKey: mnemonicsKeystoreKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: mnemonicsKeystoreKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: mnemonicsKeystoreKey)
            }
        }
    }
    
    public func privateKey(password: String) throws -> String {
        let keystore = try loadKeystore()
        guard let address = keystore.getAddress()?.address else {
            throw CeloError.malformedKeystore
        }
        guard let ethereumAddress = EthereumAddress(address) else {
            throw  CeloError.invalidAddress
        }
        let privateKeyData = try keystore.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
        
        return privateKeyData.toHexString()
    }
    
    public func verifyPassword(_ password: String) -> Bool {
        return (try? privateKey(password: password)) != nil
    }
    
    public func generateAccount(password: String) throws {
        guard let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: 128) else {
            throw CeloError.unexpectedResult
        }
        
        try importAccount(mnemonics: mnemonics, password: password)
    }
    
    public func importAccount(privateKey: String, password: String) throws {
        guard let privateKeyData = Data.fromHex(privateKey) else {
            throw CeloError.invalidKey
        }
        guard let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: password) else {
            throw CeloError.malformedKeystore
        }
        
        try saveKeystore(keystore)
        self.mnemonics = nil
    }
    
    public func importAccount(mnemonics: String, password: String) throws {
        guard let keystore = (try? BIP32Keystore(mnemonics: mnemonics, password: password)) ?? nil else {
            throw CeloError.invalidMnemonics
        }
        
        guard let address = keystore.addresses?.first else {
            throw CeloError.malformedKeystore
        }
        
        guard let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: address).toHexString() else {
            throw CeloError.malformedKeystore
        }
        
        try importAccount(privateKey: privateKey, password: password)
        self.mnemonics = mnemonics
    }
    
    private func saveKeystore(_ keystore: EthereumKeystoreV3) throws {
        keystoreCache = keystore
        
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw CeloError.invalidPath
        }
        guard let keystoreParams = keystore.keystoreParams else {
            throw CeloError.malformedKeystore
        }
        guard let keystoreData = try? JSONEncoder().encode(keystoreParams) else {
            throw CeloError.malformedKeystore
        }
        if !FileManager.default.fileExists(atPath: userDir + keystoreDirectoryName) {
            do {
                try FileManager.default.createDirectory(atPath: userDir + keystoreDirectoryName, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw CeloError.invalidPath
            }
        }
        
        FileManager.default.createFile(atPath: userDir + keystoreDirectoryName + keystoreFileName, contents: keystoreData, attributes: nil)

    }
    
  public func loadKeystore() throws -> EthereumKeystoreV3 {
        if let keystore = keystoreCache {
            return keystore
        }
        
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw CeloError.invalidPath
        }
        guard let keystoreManager = KeystoreManager.managerForPath(userDir + keystoreDirectoryName) else {
            throw CeloError.malformedKeystore
        }
        guard let address = keystoreManager.addresses?.first else {
            throw CeloError.malformedKeystore
        }
        guard let keystore = keystoreManager.walletForAddress(address) as? EthereumKeystoreV3 else {
            throw CeloError.malformedKeystore
        }
        
        keystoreCache = keystore
        
        return keystore
    }
}
