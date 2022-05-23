//
//  AttestationRequester.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 23/05/22.
//

import Foundation

class AttestationRequester {
   private static final let String TAG = "Attestation";
   public static final  let RESULT_SUCCESS = 0;
   public static final  let RESULT_NO_ADDRESS = 1;
   public static final  let RESULT_BAD_PHONE_NUMBER = 2;
   public static final  let  RESULT_NETWORK_ERROR = 3; // Check your internet connection.
   public static final  let  RESULT_INCONSISTENT_STATE = 4; // Unknown issue. Try again?
   public static final  let RESULT_TIME_OUT_WHILE_WAITING_FOR_SELECTING_ISSUERS = 5; // Try again later
    
    class AttestationResult {
        var countsAreReliable = false;
       var newAttestations = 0;
       var totalAttestations = 0;
       var completedAttestations = 0;
        
        
    }
    
    // How many attestations should be requested at maximum
       private static final let MAX_ATTESTATIONS = 3;

       static final let NUM_ATTESTATIONS_REQUIRED = 3;
       private static final let MAX_ACTIONABLE_ATTESTATIONS = 5;

       static final let double DEFAULT_ATTESTATION_THRESHOLD = 0.25d;

       private static final let CLAIM_TYPE_ATTESTATION_SERVICE_URL = "ATTESTATION_SERVICE_URL";
       private static final let CLAIM_TYPE_ACCOUNT = "ACCOUNT";
       private static final let CLAIM_TYPE_DOMAIN = "DOMAIN";
       private static final let CLAIM_TYPE_KEYBASE = "KEYBASE";
       private static final let CLAIM_TYPE_NAME = "NAME";
       private static final let CLAIM_TYPE_PROFILE_PICTURE = "PROFILE_PICTURE";
       private static final let CLAIM_TYPE_STORAGE = "STORAGE";
       private static final let CLAIM_TYPE_TWITTER = "TWITTER";

       // https://github.com/celo-org/celo-monorepo/blob/218f32526b45d77bd23d1375907b791cfdf0f619/packages/sdk/base/src/io.ts#L2
       private static final let URL_REGEX = "((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((?:\\/[\\+~%\\/\\.\\w\\-_]*)?\\??(?:[\\-\\+=&;%@\\.\\w_]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)";

    public static func requestAttestations(contractKit:ContractKit,phoneNumber:String,salt:String) -> AttestationResult {
        var result = AttestationResult.init()
        final boolean initialWithoutRevealing = true;

        var isRestarted = false;

        while (true) {
            let queue = DispatchQueue.main

            print(Setting.web3url)
            let abi = AddressRegistry().getAbiForContract(to: CeloContractClass.Registry)
            if let ethAddress = EthereumAddress(AddressRegistry.REGISTRY_CONTRACT_ADDRESS),
               let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: ethAddress),
               let cAddress = (CeloSDK.currentAccount?.address) {
                var options = ContractKitOptions.defaultOptions
    //            let address = (CeloSDK.currentAccount?.address)!
                let celoAddress = EthereumAddress(cAddress)
                options.from = celoAddress
                options.gasPrice = TransactionOptions.GasPricePolicy.automatic
                options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
                let method = Setting.TXActionGetAddressFor
                let datan = Data(contractName.utf8)
                if let tx = contract.read(
                    method,
                    parameters: [datan.sha3(.keccak256)] as [AnyObject],
                    extraData: Data(),
                    transactionOptions: options) {
                    var stableTokenBal = ""
                        firstly {
                            tx.callPromise(transactionOptions: options)
                        }.done { tokenBalance in
                            print(tokenBalance)
                            if let addressRegistry = tokenBalance["0"] as? EthereumAddress {
                                stableTokenBal  = addressRegistry.address
                                queue.async {
                                }
                            }
                        }.catch { error in
                            print(error)
                        }
                }
            }
        }]
        return result
    }
}
