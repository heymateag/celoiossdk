//
//  ViewController.swift
//  celo-reference-app
//
//  Created by Sreedeep on 02/11/21.
//

import UIKit
import celo_sdk_ios
import PromiseKit


var ethAddressKey:String = "ETH_ADDRESS"

class ViewController: UIViewController {
    
    @IBOutlet weak var addressTxt: UITextView!
    @IBOutlet weak var balanceETH: UILabel!
    @IBOutlet weak var toAddressTxt: UITextField!
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var tokenBalLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
 

            let nativeAsset = CeloSDK.shared.contractKit.calculateCELO(address: CeloSDK.shared.address!)
            self.balanceETH.text = "Celo Balance = \(nativeAsset)"
            self.addressTxt.text = "Address = \(String(describing: CeloSDK.shared.address!))"
            self.toAddressTxt.text = "Mnemonic = \(String(describing: CeloSDK.shared.mnemonics!))"
     
        
    

    }


}

