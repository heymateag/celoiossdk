//
//  CeloLog.swift
//  celo-sdk-ios
//
//  Created by Sreedeep on 27/12/21.
//

import Foundation

public func CeloLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    items.forEach {
        Swift.print($0, separator: separator, terminator: terminator)
    }
    #endif
}

