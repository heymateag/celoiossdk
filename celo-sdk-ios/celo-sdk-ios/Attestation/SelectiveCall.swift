//
//  SelectiveCall.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 27/05/22.
//

import Foundation

class SignMessageResponse:Decodable {
    let success:Bool?
    let combinedSignature:String?
    
}

class SelectiveCall {
    func retryWithOffset(urlRequest request:URLRequest,noofTries:Int,dontRetry:[String],completion:@escaping(_ message:SignMessageResponse?,_ others:Any?) -> Void)  {
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
            }
        }
    }
}
