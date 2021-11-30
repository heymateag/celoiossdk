# celoiossdk
iOS SDK for the Celo blockchain

# Requirements
Install XCode 12.4 and IOS 12+ (Not tested in IOS 15 and Xcode 13)


# Installation
1.The project is supplied as a workspace with both the SDK and Sample app included
<img width="1390" alt="imgs1" src="https://user-images.githubusercontent.com/22989626/144111104-666babae-6239-4dc2-8cf3-771741d4b526.png">


2.Please select the celo-refernce-app like this and run the application 

<img width="1075" alt="imgs2" src="https://user-images.githubusercontent.com/22989626/144111328-6f4409ca-7d64-494a-9a78-0e2634cbd260.png">

3.(Not a needed Step) But in case of any changes performed in framework ,please select the celo-sdk-ios and build the application
<img width="1251" alt="imgs3" src="https://user-images.githubusercontent.com/22989626/144112368-637a9cc8-69da-4a9c-b0cd-7938c703e674.png">

Post that replace the new framework in Sample app in Framework,Libraries and Embedded Content
<img width="695" alt="Imgs5" src="https://user-images.githubusercontent.com/22989626/144112520-8a50d183-45de-4e65-845a-171257b65aad.png">

4.The SDK connects to Alfajores network.This can be changed in SDK if needed 

# Workflow

The SDK for Milestone 1 exposes lot of utility functions and public methods to create a new Wallet,restore the Wallet,fetch balances for address and managing Keys

1.Explored Creation of new Wallet  and fetching the Address ,Balances and Mnemonic

<img width="363" alt="imgs7" src="https://user-images.githubusercontent.com/22989626/144113633-222b0721-9fa6-457b-ad96-2883786c9d38.png">

2.Post funding the wallet .It can be tested by Importing the Wallet with the password and Mnemonic

<img width="346" alt="imgs9" src="https://user-images.githubusercontent.com/22989626/144113652-db82a21a-7981-4d89-8a7a-332426d61998.png">





