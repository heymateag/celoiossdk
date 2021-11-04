
import web3swift

extension CeloWalletManager {
    func saveKeystore(_ keystore: BIP32Keystore) throws {
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw CeloError.invalidPath
        }

        guard let keystoreParams = keystore.keystoreParams else {
            throw CeloError.malformedKeystore
        }

        guard let keystoreData = try? JSONEncoder().encode(keystoreParams) else {
            throw CeloError.malformedKeystore
        }

        guard let encryp = try? CeloCryptoUtils.endcodeAESECB(dataToEncode: keystoreData, key: Setting.password) else {
            throw CeloError.encryptFailure
        }

        if !FileManager.default.fileExists(atPath: userDir + Setting.KeystoreDirectoryName) {
            do {
                try FileManager.default.createDirectory(atPath: userDir +
                    Setting.KeystoreDirectoryName, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw CeloError.invalidPath
            }
        }

        FileManager.default.createFile(atPath: userDir + Setting.KeystoreDirectoryName +
            Setting.KeystoreFileName, contents: encryp, attributes: [.protectionKey: FileProtectionType.complete])
    }

    func loadKeystore() throws -> BIP32Keystore {
        if let keystore = keystore {
            return keystore
        }

        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,
                                                                true).first else {
            throw CeloError.invalidPath
        }


        guard let keystoreManager = try? loadFile(path: userDir + Setting.KeystoreDirectoryName, scanForHDwallets: true, suffix: nil) else {
            throw CeloError.malformedKeystore
        }

        guard let address = keystoreManager.addresses?.first else {
            throw CeloError.malformedKeystore
        }
        guard let keystore = keystoreManager.walletForAddress(address) as? BIP32Keystore else {
            throw CeloError.malformedKeystore
        }

        return keystore
    }

    public func killKeystore() throws {
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw CeloError.invalidPath
        }

        if keystore != nil {
            if FileManager.default.fileExists(atPath: userDir + Setting.KeystoreDirectoryName) {
                do {
                    try FileManager.default.removeItem(atPath: userDir +
                        Setting.KeystoreDirectoryName + Setting.KeystoreFileName)
                    keystore = nil
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func loadFile(path: String, scanForHDwallets: Bool = false, suffix: String? = nil) throws -> KeystoreManager? {
        let fileManager = FileManager.default
        var bip32keystores: [BIP32Keystore] = [BIP32Keystore]()
        var isDir: ObjCBool = false
        var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if !exists, !isDir.boolValue {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        }

        if !isDir.boolValue {
            return nil
        }

        let allFiles = try fileManager.contentsOfDirectory(atPath: path)
        if suffix != nil {
            for file in allFiles where file.hasSuffix(suffix!) {
                var filePath = path
                if !path.hasSuffix("/") {
                    filePath = path + "/"
                }
                filePath += file
                guard let content = fileManager.contents(atPath: filePath) else { continue }
                guard let decode = try? CeloCryptoUtils.decodeAESECB(dataToDecode: content, key: "web3swift") else {
                    continue
                }

                if scanForHDwallets {
                    guard let bipkeystore = BIP32Keystore(decode) else { continue }
                    bip32keystores.append(bipkeystore)
                }
            }
        } else {
            for file in allFiles {
                var filePath = path
                if !path.hasSuffix("/") {
                    filePath = path + "/"
                }
                filePath += file
                guard let content = fileManager.contents(atPath: filePath) else { continue }
                guard let decode = try? CeloCryptoUtils.decodeAESECB(dataToDecode: content, key: Setting.password) else {
                    continue
                }
                if scanForHDwallets {
                    guard let bipkeystore = BIP32Keystore(decode) else { continue }
                    bip32keystores.append(bipkeystore)
                }
            }
        }

        if bip32keystores.count == 0 {
            return nil
        }

        return KeystoreManager(bip32keystores)
    }
}
