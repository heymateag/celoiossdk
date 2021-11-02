//
//  ICOFramework.swift
//  ICO
//
//  Created by SREEDEEP PAUL on 02/08/18.
//  Copyright © 2018 SREEDEEP PAUL. All rights reserved.
//

import UIKit


final public class CeloFramework: CeloProtocol {
    
    static public let sharedInstance = CeloFramework()

  
    public func getAddress(completion: @escaping (_ result: CeloResult<Bool>) -> Void)
    {

    }
    public func getBalance(completion: @escaping (_ result: CeloResult<CeloBalance>) -> Void)
    {
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
    
}


