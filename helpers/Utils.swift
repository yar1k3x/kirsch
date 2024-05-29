//
//  Utils.swift
//  SpriteKitCheck
//
//  Created by 1 on 29.05.2024.
//

import Foundation
import CoreGraphics

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}


