//
//  GameScene_Physics.swift
//  SpriteKitCheck
//
//  Created by 1 on 29.05.2024.
//

import Foundation
import SpriteKit

extension GameScene {
    @objc(didBeginContact:)
    func didBegin(_ contact: SKPhysicsContact) {
        
        if score > highscore {
            highscore = score
        }
        UserDefaults.standard.set(highscore, forKey: "highScore")
        
        //collision with ground
        if contact.bodyA.categoryBitMask == groundGroup || contact.bodyB.categoryBitMask == groundGroup {
            
            heroEmitter.isHidden = true
            
            heroRunTexturesArray =  [SKTexture(imageNamed: "Run0.png"), SKTexture(imageNamed: "Run1.png"), SKTexture(imageNamed: "Run2.png"), SKTexture(imageNamed: "Run3.png"), SKTexture(imageNamed: "Run4.png"), SKTexture(imageNamed: "Run5.png"), SKTexture(imageNamed: "Run6.png")]
            let heroRunAnimation = SKAction.animate(with: heroRunTexturesArray, timePerFrame: 0.1)
            let heroRun = SKAction.repeatForever(heroRunAnimation)
            
            hero.run(heroRun)
        }
        
        //collision with coin
        if contact.bodyA.categoryBitMask == coinGroup || contact.bodyB.categoryBitMask == coinGroup {
            let coinNode = contact.bodyA.categoryBitMask == coinGroup ? contact.bodyA.node : contact.bodyB.node
            
            if sound == true {
                run(pickCoin)
            }
            
            score = score + 1
            scoreLabel.text = "\(score)"
            
            coinNode?.removeFromParent()
        }
        
        //collision with redCoin
        if contact.bodyA.categoryBitMask == redCoinGroup || contact.bodyB.categoryBitMask == redCoinGroup {
            let redCoinNode = contact.bodyA.categoryBitMask == redCoinGroup ? contact.bodyA.node : contact.bodyB.node
            
            if sound == true {
                run(pickCoin)
            }
            
            score = score + 5
            scoreLabel.text = "\(score)"
            
            redCoinNode?.removeFromParent()
        }
        
        //collision with electric gate
        if contact.bodyA.categoryBitMask == objectGroup || contact.bodyB.categoryBitMask == objectGroup {
            hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            animations.shakeAndFlashAnimation(view: self.view!)
            
            if sound == true {
                run(electricGateDeadPreload)
            }
            
            hero.physicsBody?.allowsRotation = false
            
            heroEmitterObject.removeAllChildren()
            coinObject.removeAllChildren()
            redCoinObject.removeAllChildren()
            groundObject.removeAllChildren()
            movingObject.removeAllChildren()
            
            stopGameObject()
            
            timerAddCoin.invalidate()
            timerAddRedCoin.invalidate()
            timerAddElectricGate.invalidate()
            
            heroDeathTexturesArray =  [SKTexture(imageNamed: "Dead0.png"), SKTexture(imageNamed: "Dead1.png"), SKTexture(imageNamed: "Dead2.png"), SKTexture(imageNamed: "Dead3.png"), SKTexture(imageNamed: "Dead4.png"), SKTexture(imageNamed: "Dead5.png"), SKTexture(imageNamed: "Dead6.png")]
            let heroDeathAnimation = SKAction.animate(with: heroDeathTexturesArray, timePerFrame: 0.2)
            hero.run(heroDeathAnimation)
            
            self.stageLabel.isHidden = true
            showHighscore()
            gameover = 1
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.gameViewControllerBridge.reloadGameButton.isHidden = false
                self.scene?.isPaused = true
                self.heroObject.removeAllChildren()
                self.showHighscoreText()
                
                
                if self.score > self.highscore {
                    self.highscore = self.score
                }
                
                self.highscoreLabel.isHidden = false
                self.highscoreTextLabel.isHidden = false
                self.highscoreLabel.text = "\(self.highscore)"
                
                self.gameViewControllerBridge.playAgainLabel.isHidden = false
            })
        }
    }
}
