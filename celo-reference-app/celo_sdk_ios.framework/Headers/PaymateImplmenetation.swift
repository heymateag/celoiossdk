//
//  PaymateImplmenetation.swift
//  PaymateIOS
//
//  Created by Sreedeep on 31/10/21.
//

import web3swift

import Foundation



open class PaymateImplmenetation {

    public static func initSubFramework(completion: @escaping () -> Void) {
        print("Subframework is initialized!!")

        guard let urlStr = URL(string: "https://alfajores-forno.celo-testnet.org") else { return }

        do {
            let web3 = try Web3.new(urlStr)

            let address = EthereumAddress("0xcedc9b7d6c225257eF87f06D17af1F9Ac7D50Aa6")!
            let balance = try web3.eth.getBalance(address: address)
            let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .Gwei, decimals: 3)
            
            print(balanceString)
            
        } catch {
            //handle error
            print(error)
        }
        
        
    }
    public static func initSubFramework2()
    {
      print("test")
    }
    
}




