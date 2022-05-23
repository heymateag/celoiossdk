//
//  AttestationCompleter.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 23/05/22.
//

import Foundation

class AttestationCompleter {
    private static final let TAG = "Attestation";

       // private static final String ATTESTATION_CODE_REGEX = "(.* |^)(?:celo:\\/\\/wallet\\/v\\/)?([a-zA-Z0-9=\\+\\/_-]{87,88})($| .*)";
       private static final let ATTESTATION_CODE_PREFIX = "celo://wallet/v/";

       private static final let CODE_LENGTH = 8;
       private static final let NULL_ADDRESS = "0x0000000000000000000000000000000000000000";

    
    private static String buildSecurityCodeTypedData(String code) {
        
        let json:[String:Any] = [:]
        
        var tempArray:[Any] = []
        var types:[String:Any] = [:]
        let temp:[String:Any] = [:]
        temp["name"] = "version"
        temp["type"] = "string"
        tempArray.append(temp)
        types["EIP712Domain"] = tempArray
        
//            JSON//Object json = new JSONObject();
//
//            try {
//                JSONObject types = new JSONObject();
//
//                JSONArray tempArray = new JSONArray();
//
//                JSONObject temp = new JSONObject();
//                temp.put("name", "name");
//                temp.put("type", "string");
//                tempArray.put(temp);
//
//                temp = new JSONObject();
//                temp.put("name", "version");
//                temp.put("type", "string");
//                tempArray.put(temp);
//
//                types.put("EIP712Domain", tempArray);
//
//                tempArray = new JSONArray();
//                temp = new JSONObject();
//                temp.put("name", "code");
//                temp.put("type", "string");
//                tempArray.put(temp);
//
//                types.put("AttestationRequest", tempArray);
//
//                json.put("types", types);
//                json.put("primaryType", "AttestationRequest");
//
//                temp = new JSONObject();
//                temp.put("name", "Attestations");
//                temp./put("version", "1.0.0");
//                json.put("domain", temp);
//
//                temp = new JSONObject();
//                temp.put("code", code);
//                json.put("message", temp);
//            } catch (JSONException e) { }
//
//            return json.toString();
        }
}
