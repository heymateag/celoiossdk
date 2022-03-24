//
//  ViewController.swift
//  celo-reference-app
//
//  Created by Sreedeep on 02/11/21.
//

import UIKit
import celo_sdk_ios


var ethAddressKey:String = "ETH_ADDRESS"

class ViewController: UIViewController {
    
    @IBOutlet weak var addressTxt: UITextView!
    @IBOutlet weak var balanceETH: UILabel!
    @IBOutlet weak var toAddressTxt: UITextField!
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var tokenBalLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

//        CeloSDK.balance.getCeloBalance { balance in
//            self.balanceETH.text = "Celo Native Asset = \(String(describing: balance!))"
//               }
//        CeloSDK.balance.getGoldToken{ balance in
//            self.tokenBalLabel.text = "Celo USD = \(String(describing: balance!))"
//              }
        self.addressTxt.text = "Address = \(String(describing: CeloSDK.shared.address!))"
        self.toAddressTxt.text = "Mnemonic = \(String(describing: CeloSDK.shared.mnemonics!))"

    }


}

