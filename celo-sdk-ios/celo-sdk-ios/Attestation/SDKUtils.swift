//
//  SDKUtils.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 23/05/22.
//

import Foundation

struct SDKUtils {
    
    static let shared = SDKUtils()
    
    func getValueForKey(_ key:String) -> Any? {
        return UserDefaults.standard.value(forKey:key)
    }
    
}
