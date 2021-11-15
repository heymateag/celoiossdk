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
    var address:String?
    let contractAddress = EthereumAddress("0xcedc9b7d6c225257eF87f06D17af1F9Ac7D50Aa6")
    @IBOutlet weak var addressTxt: UITextView!
    @IBOutlet weak var balanceETH: UILabel!
    @IBOutlet weak var toAddressTxt: UITextField!
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var tokenBalLabel: UILabel!
    var keystoremanager:KeystoreManager?
    var contract:web3.web3contract?
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

