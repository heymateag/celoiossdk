public enum CeloError: Error {
    case accountDoesNotExist
    case invalidPath
    case invalidKey
    case invalidMnemonics
    case invalidAddress
    case malformedKeystore
    case encryptFailure
    case networkFailure
    case conversionFailure
    case notEnoughBalance
    case contractFailure
    case unexpectedResult
    case unKnown
}
