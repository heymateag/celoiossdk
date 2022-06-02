//
//  ODISSaltUtil.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 23/05/22.
//

import Foundation

class ODISSaltUtil {
    private static  let  TAG = "ODISSalt";

    private static  let  SIGN_MESSAGE_ENDPOINT = "/getBlindedMessageSig";

    private static  let  AUTHENTICATION_METHOD_WALLET_KEY = "wallet_key";
    private static  let  AUTHENTICATION_METHOD_ENCRYPTION_KEY = "encryption_key";
    private static  let  AUTHENTICATION_METHOD_CUSTOM_SIGNER = "custom_signer";

   static let  ERROR_ODIS_QUOTA = "odisQuotaError";
   static let  ERROR_ODIS_INPUT = "odisBadInputError";
   static let  ERROR_ODIS_AUTH = "odisAuthError";
   static let  ERROR_ODIS_CLIENT = "Unknown Client Error";
    private static  let ERRORS:[String] = [ERROR_ODIS_QUOTA, ERROR_ODIS_INPUT, ERROR_ODIS_AUTH, ERROR_ODIS_CLIENT]
    private static  let PEPPER_CHAR_LENGTH = 13;
    
    public static func getSalt(contractKit:ContractKit,odisUrl:String,odisPubKey:String,target:String) throws -> String {
        if let value = SDKUtils.shared.getValueForKey(target),value is String {
            return value as! String
        }
        let address = contractKit.getAdressForString(contractName: "")
        
        let jsonMsgRequest:[String:Any] = ["account":address,"timestamp":"","blindedQueryPhoneNumber":"","authenticationMethod":""]
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonMsgRequest, options: .prettyPrinted)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            print("jsonObject \(jsonObject)")
        } catch {
            throw CeloError.accountDoesNotExist
        }
        
        return ""
    }
    
}
