//
//  AttestationRequester.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 23/05/22.
//

import Foundation
import BigInt
import PromiseKit

class AttestationRequester {
   private static let TAG = "Attestation";
   public static let RESULT_SUCCESS = 0;
   public static let RESULT_NO_ADDRESS = 1;
   public static let RESULT_BAD_PHONE_NUMBER = 2;
   public static let  RESULT_NETWORK_ERROR = 3; // Check your internet connection.
   public static let  RESULT_INCONSISTENT_STATE = 4; // Unknown issue. Try again?
   public static let RESULT_TIME_OUT_WHILE_WAITING_FOR_SELECTING_ISSUERS = 5; // Try again later
    
    class AttestationResult {
        var countsAreReliable = false;
       var newAttestations = 0;
       var totalAttestations = 0;
       var completedAttestations = 0;
        
        
    }
    
    // How many attestations should be requested at maximum
       private static let MAX_ATTESTATIONS = 3;

       static let NUM_ATTESTATIONS_REQUIRED = 3;
       private static let MAX_ACTIONABLE_ATTESTATIONS = 5;

       static let DEFAULT_ATTESTATION_THRESHOLD = 0.25;

       private static let CLAIM_TYPE_ATTESTATION_SERVICE_URL = "ATTESTATION_SERVICE_URL";
       private static let CLAIM_TYPE_ACCOUNT = "ACCOUNT";
       private static let CLAIM_TYPE_DOMAIN = "DOMAIN";
       private static let CLAIM_TYPE_KEYBASE = "KEYBASE";
       private static let CLAIM_TYPE_NAME = "NAME";
       private static let CLAIM_TYPE_PROFILE_PICTURE = "PROFILE_PICTURE";
       private static let CLAIM_TYPE_STORAGE = "STORAGE";
       private static let CLAIM_TYPE_TWITTER = "TWITTER";

       // https://github.com/celo-org/celo-monorepo/blob/218f32526b45d77bd23d1375907b791cfdf0f619/packages/sdk/base/src/io.ts#L2
       private static let URL_REGEX = "((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((?:\\/[\\+~%\\/\\.\\w\\-_]*)?\\??(?:[\\-\\+=&;%@\\.\\w_]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)";

    public static func requestAttestations(contractKit:ContractKit,phoneNumber:String,salt:String) -> AttestationResult {
        let result = AttestationResult()
        let initialWithoutRevealing = true
        let isRestarted = false
        while(true) {
            let withoutRevealing = !isRestarted && initialWithoutRevealing
            let attestationStat:AttestationsWrapper.AttestationStat;
            var actionableAttestations:[ActionableAttestation] = []
            
        }
    }
    
    private static func fetchVerificationState(contractKit:ContractKit,phoneNumbe:String,salt:String) throws -> (attestrationStat:AttestationsWrapper.AttestationStat,actionableAtts:[ActionableAttestation]) {
        let attestationStat:AttestationsWrapper.AttestationStat = AttestationsWrapper.AttestationStat.init()
        contractKit.contracts.getAttestations().getAttestationStats(identifier: Data(), account: contractKit.getFeeCurrency())
        let actionableAttestations:[ActionableAttestation] = []
        return (attestationStat,actionableAttestations)
    }
    
    static func getActionableAttestationsAndNonCompliantIssuers(contractKit:ContractKit,identifier:Data) -> (attestation:[ActionableAttestation],result:[String]) {
        let lookupResults:[ActionableAttestation] = []
        return (lookupResults,[])
    }
    
    static func lookupAttestationServiceUrls(contractKit:ContractKit,identifier:Data) {
        let tries = 3;
        let attestations:AttestationsWrapper = contractKit.contracts.getAttestations();
        //bhar
        firstly {
            contractKit.contracts.getAttestations().getCompletableAttestations(identifier: identifier, account: CeloSDK.currentAccount!.address)
        }.done { (blockNumbers: [BigUInt], issuers: [String], whereToBreakTheString: [BigUInt], metadataURLs: Data) in
            let metadataURLs = parseSolidityStringArray(stringLengths: blockNumbers, stringData: metadataURLs);
            let lookupResults:[ActionableAttestation] = [];
            for i in 0..<lookupResults.count {
                
            }
        }
        
        
    }
    
    private static func parseSolidityStringArray(stringLengths:[BigUInt],stringData:Data) -> [String] {
        let strings:[String] = []
        var offset = 0
        for i in 0..<strings.count {
            let length = Int(stringLengths[i]);
            //TODO: create string with offset like below ndroid line
//            strings[i] = new String(stringData, offset, length);
//            strings[i] = String(
            offset += length;
        }
        return strings;
    }
    
    private static func lookupAttestationServiceURL(contractKit:ContractKit,blockNumber:Int64,issuer:String,metadataURL:String) -> ActionableAttestation {
        let tries = 3;
        fetchFromUrl(contractKit: contractKit, url: metadataURL, tries: tries) { message, others in
            guard others == nil else {
                return
            }
        }
        return ActionableAttestation.init()
    }
    
    private static func fetchFromUrl(contractKit:ContractKit,url:String,tries:Int,completion:@escaping(_ message:SignMessageResponse?,_ others:Any?) -> Void) -> Metadata? {
        var doNotCatch = false;
        let request = URLRequest.init(url: URL(string: url)!)
        URLSession.shared.dataTask(with: request) { mData, mUrlResponse, mError in
            guard mError == nil else {
                return
            }
            if let response = mUrlResponse,response is HTTPURLResponse {
                let converted = response as! HTTPURLResponse
                if converted.statusCode >= 200 , converted.statusCode < 300 {
                    do {
                        let msg = try JSONDecoder().decode(SignMessageResponse.self, from: mData ?? Data())
                        completion(msg,nil)
                    } catch {
                        completion(nil,nil)
                    }
                } else if converted.statusCode == 403 {
                    completion(nil,ODISSaltUtil.ERROR_ODIS_QUOTA)
//                    throw ODISSaltUtil.ERROR_ODIS_QUOTA
                } else if converted.statusCode == 400 {
                    completion(nil,ODISSaltUtil.ERROR_ODIS_INPUT)
//                    throw ODISSaltUtil.ERROR_ODIS_INPUT
                } else if converted.statusCode == 401 {
                    completion(nil,ODISSaltUtil.ERROR_ODIS_AUTH)
//                    throw ODISSaltUtil.ERROR_ODIS_AUTH
                }
            } else {
                completion(nil,ODISSaltUtil.ERROR_ODIS_AUTH)
//                throw CeloError.unexpectedResult
            }
        }
        return nil
    }
    
    private static func metadataFromRawString(contractKit:ContractKit, rawData:String) -> Metadata? {
        return nil
    }
    
    private static func asAddressType(address:String) -> String {
        if (isValidAddress(address: address)) {
            return toChecksumAddress(address: address);
        }
        return ""
    }
    
    static func toChecksumAddress(address add:String) -> String {
        let index = add.index(add.startIndex, offsetBy: 5)
        let address = add.substring(to: index).lowercased();

//        let hash = keccak(address);

//        var sb = "0x"
//        for i in add.count {
            //TODO: make right logic for following lines
//                if (Integer.parseInt(hash.substring(i, i + 1), 16) >= 8) {
//                    sb.append(address.substring(i, i + 1).toUpperCase());
//                }
//                else {
//                    sb.append(address.charAt(i));
//                }
//        }

        return address;
    }
    
    func keccak(a:String) -> String {
        let bytes = a.data(using: .utf8)
        //TODO: check for 'Keccak' class for ios app and convert following 3 lines using that mehtod
//            Keccak.Digest256 digest256 = new Keccak.Digest256();
//            bytes = digest256.digest(bytes);
//            return Numeric.toHexString(bytes, 0, bytes.length, false);
        return ""
    }
    
    static func isValidAddress(address:String) -> Bool {
//            return address.matches("^0x[0-9a-fA-F]{40}$");
        //TODO: make right validation
        return true
     }
    
    class Claim {

        var serializedClaim:String?;

        var type:String?;
        var timestamp:Int64?;

            // storage claim
        var filteredDataPaths:String?;

            // name claim
        var name:String?;

            // domain claim
        var domain:String?;

            // keybase claim
        var username:String?;

            // account claim
        var publicKey:String?;

            // account & storage claims
        var address:String?;

            // attestation service url claim
            var url:String?;

        init(json jClaim:[String:Any]) {
            serializedClaim = ""
            type = jClaim["type"] as? String;
            switch type {
                case CLAIM_TYPE_STORAGE:
                    address = jClaim["address"] as? String;
                    filteredDataPaths = jClaim["filteredDataPaths"] as? String;
                    break;
                case CLAIM_TYPE_NAME:
                    name = jClaim["name"] as? String;
                    break;
                case CLAIM_TYPE_DOMAIN:
                    domain = jClaim["domain"] as? String;
                    break;
                case CLAIM_TYPE_KEYBASE:
                    username = jClaim["username"] as? String;
                    break;
                case CLAIM_TYPE_ACCOUNT:
                    if let k = jClaim["publicKey"] as? String {
                        publicKey = k
                    }

                    address = asAddressType(address: jClaim["address"] as! String)
                    break;
                case CLAIM_TYPE_ATTESTATION_SERVICE_URL:
                    url = jClaim["url"] as? String;
                    //TODO: add right predict for below method
    //                if (!url.matches(URL_REGEX)) {
    //                    throw new Exception(url + " is not a valid url");
    //                }
                    break;
                default: break;
            }
            
            
        }
    }
    
    class Metadata {
    //
        var claims:[Claim] = [];
        var meta:Meta?;
        init(json data:[String:Any]) {
            if let jClaims = data["claims"] as? [[String:Any]] {
                claims = []
                for (i,o) in jClaims.enumerated() {
                    claims.append(Claim.init(json: o))
                }
            }
            if let m = data["meta"] as? [String:Any] {
                meta = Meta.init(json: m)
            }
        }
     }


     class Meta {
         let address:String?;
         let signature:String?;
         
         init(json data:[String:Any]) {
             address = data["address"] as? String
             signature = data["signature"] as? String
         }
    }
        
}



class ActionableAttestation {
    var isValid:Bool?
    var blockNumber:Int64?
    var issuer:String?
    var attestationServiceURL:StreamNetworkServiceTypeValue?
    var name:String?
    var version:String?
    
    static func invalid(issuer:String) -> ActionableAttestation {
        let result = ActionableAttestation();
        result.isValid = false;
        result.issuer = issuer;
        return result;
    }
    
    static func valid(blockNumber:BigUInt,issuer:String,attestationServiceUrl:String,name:String,version:String) -> ActionableAttestation {
        let result = ActionableAttestation()
        result.isValid = true
        result.blockNumber = Int64(blockNumber)
        result.issuer = issuer
//        result.attestationServiceURL = attestationServiceUrl
        result.name = name
        result.version = version
        return result
    }
}
