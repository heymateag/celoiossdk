//
//  CGRect.swift
//   
//
//    on 3/7/19.
//   .
//

import Foundation
import UIKit

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }

    var maxEdge: CGFloat {
        return max(width, height)
    }
}
