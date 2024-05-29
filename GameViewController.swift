//
//  GameViewController.swift
//  SpriteKitCheck
//
//  Created by 1 on 28.05.2024.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    // Load the SKScene from 'GameScene.sks'
    let scene = GameScene(size: CGSize(width: 2796, height: 1290))
    
    @IBOutlet weak var reloadGameButton: UIButton!
    @IBOutlet weak var playAgainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let view = self.view as! SKView? {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            scene.gameViewControllerBridge = self
                
            // Present the scene
            view.presentScene(scene)
        }
        
    }
    
    @IBAction func reloadGameButton(sender: UIButton) {
        scene.reloadGame()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
