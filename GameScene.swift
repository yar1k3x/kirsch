//
//  GameScene.swift
//  SpriteKitCheck
//
//  Created by 1 on 28.05.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //Anims
    var animations = AnimationClass()
    
    //Variables
    var sound = true
    var gameViewControllerBridge: GameViewController!
    var moveElectricGateY = SKAction()
    var score = 0
    var highscore = 0
    var gameover = 0
    var temp = 0
    
    //Label Nodes
    var scoreLabel = SKLabelNode()
    var highscoreLabel = SKLabelNode()
    var highscoreTextLabel = SKLabelNode()
    var stageLabel = SKLabelNode()
    
    
    //Texture
    var bgTexture: SKTexture!
    var flyHeroTex: SKTexture!
    var runHeroTex: SKTexture!
    var coinTexture: SKTexture!
    var redCoinTexture: SKTexture!
    var coinHeroTex: SKTexture!
    var redCoinHeroTex: SKTexture!
    var electricGateTex: SKTexture!
    var deadHeroTex: SKTexture!
    
    //Emitters Node
    var heroEmitter = SKEmitterNode()
    
    //Sprite Nodes
    var bg = SKSpriteNode()
    var ground = SKSpriteNode()
    var sky = SKSpriteNode()
    var hero = SKSpriteNode()
    var coin = SKSpriteNode()
    var redCoin = SKSpriteNode()
    var electricGate = SKSpriteNode()
    
    //Sprite Objects
    var bgObject = SKNode()
    var groundObject = SKNode()
    var skyObject = SKNode()
    var heroObject = SKNode()
    var movingObject = SKNode()
    var heroEmitterObject = SKNode()
    var coinObject = SKNode()
    var redCoinObject = SKNode()
    var labelObject = SKNode()
    
    //Bit masks
    var heroGroup: UInt32 = 0x1 << 1
    var groundGroup: UInt32 = 0x1 << 2
    var coinGroup: UInt32 = 0x1 << 3
    var redCoinGroup: UInt32 = 0x1 << 4
    var objectGroup: UInt32 = 0x1 << 5
    
    //Textures Array for animateWithTextures
    var heroFlyTexturesArray = [SKTexture]()
    var heroRunTexturesArray = [SKTexture]()
    var coinTexturesArray = [SKTexture]()
    var electricGateTexturesArray = [SKTexture]()
    var heroDeathTexturesArray = [SKTexture]()
    
    //Timers
    var timerAddCoin = Timer()
    var timerAddRedCoin = Timer()
    var timerAddElectricGate = Timer()
    
    //sounds
    var pickCoin = SKAction()
    var electricGateCreatePreload = SKAction()
    var electricGateDeadPreload = SKAction()

    override func didMove(to view: SKView) {
        //Background texture
        bgTexture = SKTexture(imageNamed: "bg.jpeg")
        
        //Hero texture
        flyHeroTex = SKTexture(imageNamed: "Fly0.png")
        runHeroTex = SKTexture(imageNamed: "Run0.png")
        
        //Coin texture
        coinTexture = SKTexture(imageNamed: "coin.jpg")
        redCoinTexture = SKTexture(imageNamed: "coin.jpg")
        coinHeroTex = SKTexture(imageNamed: "Coin0.jpg")
        redCoinHeroTex = SKTexture(imageNamed: "Coin0.jpg")
        
        //ElectricGate texture
        electricGateTex = SKTexture(imageNamed: "ElectricGate01.png")
        
        //Emitters
        heroEmitter = SKEmitterNode(fileNamed: "engine.sks")!
        
        self.physicsWorld.contactDelegate = self
        
        //Sounds actions
        pickCoin = SKAction.playSoundFileNamed("pickCoin.mp3", waitForCompletion: false)
        electricGateCreatePreload = SKAction.playSoundFileNamed("electricCreate.wav", waitForCompletion: false)
        electricGateDeadPreload = SKAction.playSoundFileNamed("electricDead.mp3", waitForCompletion: false)
        
        
        createObjects()
        createGame()
        
    }
    
    func createObjects() {
        self.addChild(bgObject)
        self.addChild(groundObject)
        self.addChild(skyObject)
        self.addChild(heroObject)
        self.addChild(heroEmitterObject)
        self.addChild(coinObject)
        self.addChild(redCoinObject)
        self.addChild(movingObject)
        self.addChild(labelObject)
    }
    
    func createGame() {
        createBg()
        createGround()
        createSky()
        
        //show labels
        if temp == 0 {
            showScore()
            showStage()
            highscoreTextLabel.isHidden = true
        }
        temp += 1
        
        
        //generate game objects
        createHero()
        createHeroEmitter()
        timerFunc()
        addElectricGate()
        gameViewControllerBridge.reloadGameButton.isHidden = true
        
        if labelObject.children.count != 0 {
            labelObject.removeAllChildren()
        }
    }
    
    func createBg() {
        bgTexture = SKTexture(imageNamed: "bg.jpeg")
        
        let moveBg = SKAction.moveBy(x: -bgTexture.size().width, y: 0, duration: 3)
        let replaceBg = SKAction.moveBy(x: bgTexture.size().width, y: 0, duration: 0)
        let moveBgForever = SKAction.repeatForever(SKAction.sequence([moveBg, replaceBg]))
        
        for i in 0..<3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: size.width/4 + bgTexture.size().width * CGFloat(i), y: size.height/2.0)
            bg.size.height = self.frame.height
            bg.run(moveBgForever)
            bg.zPosition = -1
            
            bgObject.addChild(bg)
        }
    }
    
    func createGround() {
        ground = SKSpriteNode()
        ground.position = CGPoint.zero
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height - self.frame.height + 50))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundGroup
        ground.zPosition = 1
        
        groundObject.addChild(ground)
    }
    
    func createSky() {
        sky = SKSpriteNode()
        sky.position = CGPoint(x: 0, y: self.frame.maxY)
        sky.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: self.frame.size.height - self.frame.height + 30))
        sky.physicsBody?.isDynamic = false
        sky.zPosition = 1
        
        skyObject.addChild(sky)
    }
    
    func addHero(heroNode: SKSpriteNode, atPosition position: CGPoint) {
        hero = SKSpriteNode(texture: flyHeroTex)
        
        //Anim hero with array of 4 textures
        heroFlyTexturesArray = [SKTexture(imageNamed: "Fly0.png"), SKTexture(imageNamed: "Fly1.png"), SKTexture(imageNamed: "Fly2.png"), SKTexture(imageNamed: "Fly3.png"), SKTexture(imageNamed: "Fly4.png")]
        let heroFlyAnimation = SKAction.animate(with: heroFlyTexturesArray, timePerFrame: 0.1)
        let flyHero = SKAction.repeatForever(heroFlyAnimation)
        hero.run(flyHero)
        
        hero.position = position
        hero.size.height = 240
        hero.size.width = 360
        
        hero.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: hero.size.width - 40, height: hero.size.height - 30))
        
        hero.physicsBody?.categoryBitMask = heroGroup
        hero.physicsBody?.contactTestBitMask = groundGroup | coinGroup | redCoinGroup | objectGroup
        hero.physicsBody?.collisionBitMask = groundGroup
        
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.zPosition = 1
        
        heroObject.addChild(hero)
    }
    
    func createHero() {
        addHero(heroNode: hero, atPosition: CGPoint(x: self.size.width/4, y: 0 + flyHeroTex.size().height + 400))
    }
    
    func createHeroEmitter() {
        heroEmitter = SKEmitterNode(fileNamed: "engine.sks")!
        
//        // Настройка размера эмиттера
//        heroEmitter.particleScale = 0.3
//        heroEmitter.particleScaleRange = 0.5
        
        heroEmitterObject.zPosition = 1
        heroEmitterObject.addChild(heroEmitter)
    }
    
    @objc func addCoin() {
        coin = SKSpriteNode(texture: coinTexture)
        
        coinTexturesArray = [SKTexture(imageNamed: "Coin0.png"), SKTexture(imageNamed: "Coin1.png"), SKTexture(imageNamed: "Coin2.png"), SKTexture(imageNamed: "Coin3.png")]
        
        let coinAnimation = SKAction.animate(with: coinTexturesArray, timePerFrame: 0.1)
        let coinHero = SKAction.repeatForever(coinAnimation)
        coin.run(coinHero)
        
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2) //random coin location
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4 //location restriction
        coin.size.width = 120
        coin.size.height = 120
        coin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: coin.size.width - 20, height: coin.size.height - 20))
        coin.physicsBody?.restitution = 0
        coin.position = CGPoint(x: self.size.width + 50, y: 0 + redCoinTexture.size().height + 90 + pipeOffset)
        
        let moveCoin = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: 5) //move coin to player
        let removeAction = SKAction.removeFromParent()
        let coinMoveBgForever = SKAction.repeatForever(SKAction.sequence([moveCoin, removeAction]))
        coin.run(coinMoveBgForever)
        
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = coinGroup
        coin.zPosition = 1
        coinObject.addChild(coin)
    }
    
    @objc func addRedCoin() {
        redCoin = SKSpriteNode(texture: coinTexture)
        
        coinTexturesArray = [SKTexture(imageNamed: "Coin0.png"), SKTexture(imageNamed: "Coin1.png"), SKTexture(imageNamed: "Coin2.png"), SKTexture(imageNamed: "Coin3.png")]
        
        let redCoinAnimation = SKAction.animate(with: coinTexturesArray, timePerFrame: 0.1)
        let redCoinHero = SKAction.repeatForever(redCoinAnimation)
        redCoin.run(redCoinHero)
        
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2) //random coin location
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4 //location restriction
        redCoin.size.width = 120
        redCoin.size.height = 120
        redCoin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: coin.size.width - 10, height: coin.size.height - 10))
        redCoin.physicsBody?.restitution = 0
        redCoin.position = CGPoint(x: self.size.width + 50, y: 0 + coinTexture.size().height + 90 + pipeOffset)
        
        let moveCoin = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: 5) //move coin to player
        let removeAction = SKAction.removeFromParent()
        let coinMoveBgForever = SKAction.repeatForever(SKAction.sequence([moveCoin, removeAction]))
        redCoin.run(coinMoveBgForever)
        
        
        animations.scaleZdirection(sprite: redCoin)
        animations.redColorAnimation(sprite: redCoin, animDuration: 0.5)
        redCoin.setScale(1.3)
        redCoin.physicsBody?.isDynamic = false
        redCoin.physicsBody?.categoryBitMask = redCoinGroup
        redCoin.zPosition = 1
        redCoinObject.addChild(redCoin)
    }
    
    @objc func addElectricGate() {
        if sound == true {
            run(electricGateCreatePreload)
        }
        
        electricGate = SKSpriteNode(texture: electricGateTex)
        
        electricGateTexturesArray = [SKTexture(imageNamed: "ElectricGate01.png"), SKTexture(imageNamed: "ElectricGate02.png"), SKTexture(imageNamed: "ElectricGate03.png"), SKTexture(imageNamed: "ElectricGate04.png")]
        
        let electricGateAnimation = SKAction.animate(with: electricGateTexturesArray, timePerFrame: 0.1)
        let electricGateAnimationForever = SKAction.repeatForever(electricGateAnimation)
        electricGate.run(electricGateAnimationForever)
        
        let randomPosition = arc4random() % 2
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 5)
        let pipeOffset = self.frame.size.height / 4 + 30 - CGFloat(movementAmount)
        
        
        electricGate.size.width = 340
        
        redCoin.size.height = 120
        if randomPosition == 0 {
            electricGate.position = CGPoint(x: self.size.width + 50, y: 0 + electricGateTex.size().height/2 + 90 + pipeOffset)
            electricGate.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: electricGate.size.width - 40, height: electricGate.size.height - 20))
        } else {
            electricGate.position = CGPoint(x: self.size.width + 50, y: self.frame.size.height - electricGateTex.size().height/2 - 90 - pipeOffset)
            electricGate.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: electricGate.size.width - 40, height: electricGate.size.height - 20))
        }
        
        //Rotate
        electricGate.run(SKAction.repeatForever(SKAction.sequence([SKAction.run({
            self.electricGate.run(SKAction.rotate(byAngle: CGFloat(Double.pi * 2), duration: 0.5))
        }), SKAction.wait(forDuration: 20.0)])))
        
        //Move
        let moveAction = SKAction.moveBy(x: -self.frame.width - 300, y: 0, duration: 6)
        electricGate.run(moveAction)
        
        //Scale
        var scaleValue: CGFloat = 0.3
        
        
        let scaleRandom = arc4random() % UInt32(5)
        if scaleRandom == 1 { scaleValue = 0.9 }
        else if scaleRandom == 2 { scaleValue = 0.6 }
        else if scaleRandom == 3 { scaleValue = 0.8 }
        else if scaleRandom == 4 { scaleValue = 0.7 }
        else if scaleRandom == 0 { scaleValue = 1.0 }
        
        electricGate.setScale(scaleValue)
        
        let movementRandom = arc4random() % 9
        if movementRandom == 0 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 + 220, duration: 4)
        } else if movementRandom == 1 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 - 220, duration: 5)
        } else if movementRandom == 2 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 - 150, duration: 4)
        } else if movementRandom == 3 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 + 150, duration: 5)
        } else if movementRandom == 4 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 + 50, duration: 4)
        } else if movementRandom == 5 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 - 50, duration: 5)
        } else {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2, duration: 4)
        }
        
        electricGate.run(moveElectricGateY)
        
        electricGate.physicsBody?.restitution = 0
        electricGate.physicsBody?.isDynamic = false
        electricGate.physicsBody?.categoryBitMask = objectGroup
        electricGate.zPosition = 1
        movingObject.addChild(electricGate)
    }
    
    func showScore() {
        scoreLabel = SKLabelNode()
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 200)
        scoreLabel.fontSize = 75
        scoreLabel.fontColor = UIColor.white
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
    }
    
    func showHighscore() {
        highscoreLabel = SKLabelNode()
        highscoreLabel.position = CGPoint(x: self.frame.maxX - 350, y: self.frame.maxY - 210)
        highscoreLabel.fontSize = 75
        highscoreLabel.fontName = "Chalkduster"
        highscoreLabel.fontColor = UIColor.white
        highscoreLabel.isHidden = true
        highscoreLabel.zPosition = 1
        labelObject.addChild(highscoreLabel)
    }
    
    func showHighscoreText() {
        highscoreTextLabel = SKLabelNode()
        highscoreTextLabel.position = CGPoint(x: self.frame.maxX - 350, y: self.frame.maxY - 150)
        highscoreTextLabel.fontSize = 75
        highscoreTextLabel.fontName = "Chalkduster"
        highscoreTextLabel.fontColor = UIColor.white
        highscoreTextLabel.text = "HighScore"
        highscoreTextLabel.zPosition = 1
        labelObject.addChild(highscoreTextLabel)
    }
    
    func showStage() {
        stageLabel = SKLabelNode()
        stageLabel.position = CGPoint(x: self.frame.maxX - 250, y: self.frame.maxY - 140)
        stageLabel.fontSize = 75
        stageLabel.fontName = "Chalkduster"
        stageLabel.fontColor = UIColor.white
        stageLabel.text = "Stage 1"
        stageLabel.zPosition = 1
        self.addChild(stageLabel)
    }
    
    //create coins after some time
    func timerFunc() {
        timerAddCoin.invalidate()
        timerAddRedCoin.invalidate()
        timerAddElectricGate.invalidate()
        
        timerAddCoin = Timer.scheduledTimer(timeInterval: 2.64, target: self, selector: #selector(GameScene.addCoin), userInfo: nil, repeats: true)
        timerAddRedCoin = Timer.scheduledTimer(timeInterval: 8.246, target: self, selector: #selector(GameScene.addRedCoin), userInfo: nil, repeats: true)
        timerAddElectricGate = Timer.scheduledTimer(timeInterval: 5.234, target: self, selector: #selector(GameScene.addElectricGate), userInfo: nil, repeats: true)
    }
    
    func stopGameObject() {
        coinObject.speed = 0
        redCoinObject.speed = 0
        movingObject.speed = 0
        heroObject.speed = 0
    }
    
    func reloadGame() {
        
        self.gameViewControllerBridge.playAgainLabel.isHidden = true
        
        coinObject.removeAllChildren()
        redCoinObject.removeAllChildren()
        
        stageLabel.text = "Stage 1"
        gameover = 0
        
        scene?.isPaused = false
        
        movingObject.removeAllChildren()
        heroObject.removeAllChildren()
        
        coinObject.speed = 1
        heroObject.speed = 1
        movingObject.speed = 1
        self.speed = 1
        
        if labelObject.children.count != 0 {
            labelObject.removeAllChildren()
        }
        //reset labels
        score = 0
        scoreLabel.text = "0"
        stageLabel.isHidden = false
        highscoreTextLabel.isHidden = true
        showHighscore()
        
        createGame()
        
        
        
        timerFunc()
    }
    
    override func didFinishUpdate() {
        heroEmitter.position = hero.position - CGPoint(x: 90, y: 15)
    }
}

    

