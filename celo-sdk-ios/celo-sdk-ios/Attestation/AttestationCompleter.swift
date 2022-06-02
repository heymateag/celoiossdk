//
//  AttestationCompleter.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 23/05/22.
//

import Foundation

class AttestationCompleter {
    private static  let TAG = "Attestation";

       // private static final String ATTESTATION_CODE_REGEX = "(.* |^)(?:celo:\\/\\/wallet\\/v\\/)?([a-zA-Z0-9=\\+\\/_-]{87,88})($| .*)";
       private static  let ATTESTATION_CODE_PREFIX = "celo://wallet/v/";

       private static  let CODE_LENGTH = 8;
       private static  let NULL_ADDRESS = "0x0000000000000000000000000000000000000000";

    

}
