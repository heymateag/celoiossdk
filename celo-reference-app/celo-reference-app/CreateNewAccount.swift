//
//  CreateNewAccount.swift
//  celo-reference-app
//
//  Created by Sreedeep on 15/11/21.
//

import Foundation
import UIKit
import celo_sdk_ios
import PromiseKit


class CreateNewAccount: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func onCreateWallet(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segue_create_wallet", sender:nil)
//        CeloSDK.shared.initializeWalletConnect {
//            print("address\(CeloSDK.currentAccount?.address)")
//            let stableToken : StableTokenWrapper = StableTokenWrapper()
//
//            firstly {
//                stableToken.getStableTokenAddress()
//            }.done { address in
//
//                CeloSDK.shared.contractKit.setFeeCurrency(feeCurrency: address)
//                self.performSegue(withIdentifier: "segue_create_wallet", sender:nil)
//            }
//        }

       
    }
    @IBAction func createNew(_ sender: UIButton) {
        
        var userIdTextField: UITextField?

          // Declare Alert message
          let dialogMessage = UIAlertController(title: "Add password", message: "Please enter your password", preferredStyle: .alert)

          // Create OK button with action handler
          let ok = UIAlertAction(title: "Create", style: .default, handler: { (action) -> Void in
              print("Ok button tapped")

              if let userInput = userIdTextField!.text {
                  print("User entered \(userInput)")
                try? CeloSDK.accountWithMnemonic.generateAccount(password: userInput)
//                  RappleActivityIndicatorView.startAnimating()
              }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
            self.present(controller!, animated: true, completion: nil)
          })

          // Create Cancel button with action handlder
          let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
              print("Cancel button tapped")
          }

          //Add OK and Cancel button to dialog message
          dialogMessage.addAction(ok)
          dialogMessage.addAction(cancel)

          // Add Input TextField to dialog message
          dialogMessage.addTextField { (textField) -> Void in

              userIdTextField = textField
              userIdTextField?.placeholder = "Type in your ID"
          }
//        RappleActivityIndicatorView.stopAnimating()
          // Present dialog message to user
          self.present(dialogMessage, animated: true, completion: nil)
        
    }
    

    @IBAction func restore(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter Mnemonics Key", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (textfiled) in
            textfiled.placeholder = "Enter mnemonics"
        })
        alert.addTextField(configurationHandler: {
            (textfield) in
            textfield.placeholder = "Enter Password"
            textfield.isSecureTextEntry = true
        })
        let genrate = UIAlertAction(title: "Genrate", style: .destructive, handler: {
            _ in
            let mnemonictxt = alert.textFields![0].text
            let passwordtxt = alert.textFields![1].text
            if mnemonictxt != "" && passwordtxt != "" {
                try? CeloSDK.accountWithMnemonic.importAccount(mnemonics: mnemonictxt!, password: passwordtxt!)

                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
                    self.present(controller!, animated: true, completion: nil)
              
            }else {
                self.present(alert, animated: true, completion: nil)
            }
        })
        alert.addAction(genrate)
        self.present(alert, animated: true, completion: nil)
    }

}
