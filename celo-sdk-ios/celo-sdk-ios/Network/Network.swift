import web3swift
extension CeloSDK {
    class func createWeb3Instance(customURL: String) throws -> web3 {
        let net = try CeloSDK.customNet(url:customURL)
        return net
    }

    class func customNet(url: String) throws -> web3 {
        guard let URL = URL(string: url), let web3Url = Web3HttpProvider(URL) else {
            throw CeloError.conversionFailure
        }

        let net = web3(provider: web3Url)
        return net
    }

 
   
}
