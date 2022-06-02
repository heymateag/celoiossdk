//
//  AttestationsWrapper.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 29/05/22.
//

import Foundation
import BigInt
import web3swift

class AttestationsWrapper {
    class AttestationStat {
        
    }
    
    //TODO: what is remotefUnctionCall in web3 like below
//    RemoteFunctionCall<Tuple4<List<BigInteger>, List<String>, List<BigInteger>, byte[]>>
    public func getCompletableAttestations(identifier:Data, account:String) -> ([Int64],[String],[Int64],Data) {
        return ([],[],[],Data())
    }
    
    public func getAttestationStat(identifier:Data,account:String) -> AttestationsWrapper.AttestationStat {
        return AttestationsWrapper.AttestationStat()
    }
}
