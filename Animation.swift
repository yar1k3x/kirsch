//
//  Animation.swift
//  SpriteKitCheck
//
//  Created by 1 on 29.05.2024.
//

import Foundation
import SpriteKit

class AnimationClass {
    
    func scaleZdirection(sprite: SKSpriteNode) {
        sprite.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.scale(by: 2.0, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 1.0)
                ])
            ))
    }
    
    func redColorAnimation(sprite: SKSpriteNode, animDuration: TimeInterval) {
        sprite.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: animDuration),
                SKAction.colorize(withColorBlendFactor: 0.0, duration: animDuration)
                ])
            ))
    }
    
    func shakeAndFlashAnimation(view: SKView) {
        //White flash
        let aView = UIView(frame: view.frame)
        aView.backgroundColor = UIColor.white
        view.addSubview(aView)
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            aView.alpha = 0.0
            }) { (done) in
                aView.removeFromSuperview()
        }
        
        //Shake animation
        let shake = CAKeyframeAnimation(keyPath: "transform")
        shake.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(-15, 5, 5)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(15, 5, 5))
        ]
        shake.autoreverses = true
        shake.repeatCount = 2
        shake.duration = 7/100
        
        view.layer.add(shake, forKey: nil)
    }
    
}
