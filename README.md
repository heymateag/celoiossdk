# Celo iOS SDK (alpha v1.0.1)

iOS SDK for the Celo blockchain

- [Learn more about Celo](https://docs.celo.org/)
- <img width="355" alt="Screenshot 2022-03-24 at 9 20 11 PM" src="https://user-images.githubusercontent.com/22989626/159956526-728fd78f-2ce3-4104-8126-00b1b2581cf4.png">




## Requirements

- XCode 13.1+ with IOS compiler supporting v14 or v15.
- Apple developer account
  - Register your developer account with Apple and associate with the project build settings for a digital signature to compile.
    - Download developer management app from AppStore
    - Another option is to utilize the web portal
      - https://developer.apple.com/enroll/app
     - If issues prevent registration or activation of your developer account, contact Apple developer program 1-800-692-7753 for manual review
    - Once approved, associate project build settings with your developer account.

## Installation

- Fork/Clone Github repository
- Adjust build settings to include your developer account
- Known issues with M1 mac (Arm64)
  - To increase compatibility, run Xcode with Rosetta enabled. 
    - Right click on the Xcode icon, in popup window make sure that Open using Rosetta is checked.
  - Known project dependencies that needed to be refreshed to work on M1 chipset
    - https://github.com/skywinder/web3swift
    - https://github.com/jrendel/SwiftKeychainWrapper 
- Build & Test!
- You may run on device as well.Please unzip the frameworks for arm64 and replace in Framework folder in SDK and Sample app

## Structure
The SDK connects to alfajores network by default. This can be changed in SDK like this

```swift
Configuration.changeEnvironment(isProduction: false) -- Alfajores
Configuration.changeEnvironment(isProduction: true) -- Mainnet
```

[Learn more about Celo's networks](https://docs.celo.org/getting-started/choosing-a-network)

### Workspace
The project is supplied as a workspace with both the SDK and Sample reference app. Utilize the CeloIOSWorkspace.xcworkspace

![image](https://user-images.githubusercontent.com/22989626/144111104-666babae-6239-4dc2-8cf3-771741d4b526.png)

Select the celo-refernce-app and run the application

![image](https://user-images.githubusercontent.com/22989626/144111328-6f4409ca-7d64-494a-9a78-0e2634cbd260.png)

(Not a needed Step) But in case of any changes performed in framework ,please select the celo-sdk-ios and build the application

![image](https://user-images.githubusercontent.com/22989626/144112368-637a9cc8-69da-4a9c-b0cd-7938c703e674.png)

Post that replace the new framework in Sample app in Framework,Libraries and Embedded Content

![image](https://user-images.githubusercontent.com/22989626/144112520-8a50d183-45de-4e65-845a-171257b65aad.png)


## SDK Usage

Import the SDK
```swift
 import celo_sdk_ios
```


Import PromiseKit.Promises simplify asynchronous programming.
```swift
 import PromiseKit
```



Initialize and generate current Account without any password
```swift
CeloSDK.shared.initializeWalletConnect {
            print("address\(CeloSDK.currentAccount?.address)")
}
```
Get current account wallet address
```swift
CeloSDK.currentAccount?.address
```

Initialize contract kit instance
```swift
let contractkit = CeloSDK.shared.contractKit
```
```swift
(Important step to be done after generating wallet)
```swift
First fetch the Stable Token Address ,this will internally set it as the FeeCurrency in the ContractKit 
```swift
 firstly {
   StableTokenWrapper().getStableTokenAddress()
        }.then { address in
  print(address)
            
        }
```

Set the feeCurrency by passing the Celo FeeCurrency for specific Stable Token
```swift
contractkit.setFeeCurrency(feeCurrency: mFeeCurrency)
 mFeeCurrency - CUSD Fee Currency
```

Get the feeCurrency for specific Stable Token
```swift
contractkit.getFeeCurrency()
```


Get CUSD Balance for an address
```swift
 firstly {
  contractkit.getStableTokenBalanceOf(currentAddress:mAddress)
    }.done { balance in
  print(balance)
    }
 mAddress - User's wallet Address
```

Get Native Celo Balance

```swift
 contractkit.calculateCELO()

```

Get GasPriceMinimum for a Token 

```swift
 firstly {
     CeloSDK.shared.contractKit.getGaspriceMinimum(tokenType:CeloContractClass.StableToken)
        }.done {gasPrice in
        print(gasPrice)
       }
```

Token transfer/Transaction 

```swift
firstly {
       CeloSDK.shared.contractKit.transfer(amount: self.fromAddressField.text!, toAddress: self.toAddressField.text!)
        }.done { txRecieptHash in
            print(txRecieptHash)
        }
```

Initialize contract kit instance for a specific web3 instance and abi hosted in your network
```swift
let contract = CeloSDK.shared.contractKit.getContractKit(web3Instance: CeloSDK.web3Net, abi, at: EthereumAddress(contractAddress)!)
```

To set web3 url instance

```swift
let web3net = try CeloSDK.customNet(url: "")
This can be accessed from SDK via CeloSDK.web3Net
```


Returns an array of attestations that can be completed, along with the issuers' attestation service urls
   * @param identifier Attestation identifier (e.g. phone hash)
   * @param account Address of the account


```swift
contractKit.contracts.getAttestations().getCompletableAttestations(identifier: identifier, account: CeloSDK.currentAccount!.address)

```

Returns the attestation stats of a identifer/account pair
   * @param identifier Attestation identifier (e.g. phone hash)
   * @param account Address of the account


```swift
contractKit.contracts.getAttestations().getAttestationStats(identifier: identifier, account: CeloSDK.currentAccount!.address)

```

Returns the list of accounts associated with an identifier
   * @param identifier Attestation identifier (e.g. phone hash)



```swift
contractKit.contracts.getAttestations().lookupAccountsForIdentifier(identifier: identifier)

```

Returns the unselected attestation request for an identifier/account pair, if any.
   * @param identifier Attestation identifier (e.g. phone hash)
   * @param account Address of the account



```swift
contractKit.contracts.getAttestations().getUnselectedRequest(identifier: identifier,account: CeloSDK.currentAccount!.address)

```

Returns the time an attestation can be completable before it is considered expired.



```swift
contractKit.contracts.getAttestations().getAttestationExpiryBlocks()

```

```

Requests a new attestation.
   * @param identifier Attestation identifier (e.g. phone hash)
   * @param attestationsRequested The number of attestations to request
   * @param attestationRequestFeeToken Attestattion fee



```swift
contractKit.contracts.getAttestations().request(identifier:Data,attestationsRequested:BigUInt,attestationRequestFeeToken:String)

```

Requests a new attestation.
   * @param token Stable Token address



```swift
contractKit.contracts.getAttestations().getAttestationFeeRequired(token:String)

```

Selects the issuers for previously requested attestations for a phone number
   * @param identifier Attestation identifier (e.g. phone hash)



```swift
contractKit.contracts.getAttestations().selectIssuers(identifier:Data)

```

Returns the time an Issuer can be assigned for a given attestation



```swift
contractKit.contracts.getAttestations().selectIssuersWaitBlocks(identifier:Data)

```

Completes an attestation with the corresponding code
   * @param identifier Attestation identifier (e.g. phone hash)
   * Signatures v,r,s to be calculated from account,issuer and code



```swift
contractKit.contracts.getAttestations().complete(identifier:Data,v:BigUInt,r:Data,s:Data)

```

Validates a given code by the issuer on-chain
   * @param identifier Attestation identifier (e.g. phone hash)
   * Signatures v,r,s to be calculated from account,issuer and code



```swift
contractKit.contracts.getAttestations().validateAttestationCode(identifier:Data,v:BigUInt,r:Data,s:Data)

```


Generating a new account with password
```swift
CeloSDK.account.generateAccount(password)
```

Import account with password and mnemonic
```swift
CeloSDK.account.importAccount(mnemonics, password)
CeloSDK.account.importAccount(privateKey, password)
```

Get mnemonics
```swift
CeloSDK.shared.mnemonics
```

Get private key with Password
```swift
CeloSDK.shared.privateKey(password: mPassWord)
```


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
