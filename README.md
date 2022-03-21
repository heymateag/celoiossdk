# Celo iOS SDK (alpha v0.0.1)

iOS SDK for the Celo blockchain

- [Learn more about Celo](https://docs.celo.org/)

![image](https://user-images.githubusercontent.com/2653576/149579694-5f022b1d-c600-4dca-9432-fe697b06d9d0.png)

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
  - If an error occurs regarding Swift compiler version for dependencies like Web3Swift, make sure to include dependencies within your swift package manager and remove conflicting frameworks.
  - Known project dependencies that needed to be refreshed to work on M1 chipset
    - https://github.com/skywinder/web3swift
    - https://github.com/jrendel/SwiftKeychainWrapper 
- Build & Test!

## Structure
The SDK connects to Alfajores network. This can be changed in SDK under celo-sdk-ios/celo-sdk-ios/Constants.swift when needed

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

Generating a new account
```swift
CeloSDK.account.generateAccount(password)
```

Import account
```swift
CeloSDK.account.importAccount(mnemonics, password)
CeloSDK.account.importAccount(privateKey, password)
```
Get account
```swift
CeloSDK.shared.address
```

Get mnemonics
```swift
CeloSDK.shared.mnemonics
```

Get private key
```swift
CeloSDK.shared.mnemonics
```

Get Celo balance
```swift
CeloSDK.balance.getCeloBalance
```

Get cUSD balance
```swift
CeloSDK.balance.getGoldToken
```

Initialize and generate current Account
```swift
CeloSDK.shared.initializeWalletConnect {
            print("address\(CeloSDK.currentAccount?.address)")
}
```
Initialize contract kit instance
```swift
let contractkit = CeloSDK.shared.contractKit
```
Get StableToken Balance for an address
```swift
 contractkit.getStableTokenBalanceOf(currentAddress: mAddress)
 mAddress - User's wallet Address
```
Get GasPriceMinimum for a Token 
```swift
let stableToken : StableTokenWrapper = StableTokenWrapper()
contractkit.getGasPriceMinimum(accountOwner: stableToken)
```
Get GasPriceMinimum from default feeCurrency
```swift
contractkit.getGasPriceMinimum()
```
Set feeCurrency
```swift
contractkit.setFeeCurrency(feeCurrency: StableTokenFeeCurrency)
```
Get feeCurrency
```swift
contractkit.getFeeCurrency()
```
StableToken transfer
```swift
contractkit.transfer(amount: String,toAddress :String)
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


