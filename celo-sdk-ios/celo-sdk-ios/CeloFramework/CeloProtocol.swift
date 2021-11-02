
//
//  ICOProtocol.swift
//  ICO
//
//  Created by SREEDEEP PAUL on 02/08/18.
//  Copyright © 2018 SREEDEEP PAUL. All rights reserved.
//

import UIKit

public protocol CeloProtocol {
    // One way of passing configuration from client app

  func getAddress(completion: @escaping (_ result: CeloResult<Bool>) -> Void)

  func getBalance(completion: @escaping (_ result: CeloResult<CeloBalance>) -> Void)
    
   

}
