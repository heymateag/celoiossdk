//
//  CGRect.swift
//   
//
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
