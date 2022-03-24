//
//  CreateWalletTableViewController.swift
//  celo-reference-app
//
//  Created by Sreedeep,  Sreedeep on 18/03/22.
//

import UIKit
import celo_sdk_ios
import PromiseKit

class CreateWalletTableViewController: UITableViewController {

    @IBOutlet weak var currencyTypeBtn: UIButton!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var celBalanceLabel: UILabel!
    @IBOutlet weak var fromAddressField: UITextField!
    @IBOutlet weak var toAddressField: UITextField!
    @IBOutlet weak var btnTransfer: UIButton!
    @IBOutlet var versionInfoView: UIView!
    @IBOutlet weak var gasPrice: UILabel!
    @IBOutlet weak var feecurrency: UILabel!
    @IBOutlet weak var currentAddressLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        CeloSDK.shared.initializeWalletConnect {
            self.calculatePrices()
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTableGesture))
        self.tableView.addGestureRecognizer(gesture)
        self.tableView.tableFooterView = versionInfoView
        

    }
    
    private func calculatePrices() {

        firstly {
            StableTokenWrapper().getStableTokenAddress()
        }.then { ad in
            CeloSDK.shared.contractKit.getStableTokenBalanceOf(currentAddress: CeloSDK.currentAccount!.address)
            
        }.done { balance in
            print("balance \(balance)")
            self.currentBalanceLabel.text = balance
            let fc = CeloSDK.shared.contractKit.getFeeCurrency()
            self.feecurrency.text = fc
        }

        firstly {
            CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType: .StableToken)
        }.done { gp in
            print(gp)
            self.gasPrice.text = "\(gp)"
        }
        currentAddressLabel.text = CeloSDK.currentAccount?.address ?? ""
        celBalanceLabel.text = CeloSDK.shared.contractKit.calculateCELO()
    }
    
    @objc private func onTableGesture() {
        self.tableView.endEditing(true)
    }

    @IBAction func onTransferFunds(_ sender: Any) {
        firstly {
            CeloSDK.shared.contractKit.transfer(amount: self.fromAddressField.text!, toAddress: self.toAddressField.text!)
        }.done { transactionReciept in
            print(transactionReciept)
        }
//        do{
//        let web3net = try CeloSDK.customNet(url: "")
//        }
//        catch
//        {
//            print(error)
//        }
        
        
    }
    
    @IBAction func onCurrencyType(_ sender: Any) {
        
    }
    
}
