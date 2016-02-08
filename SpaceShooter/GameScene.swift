//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Nivardo Ibarra on 2/5/16.
//  Copyright (c) 2016 Nivardo Ibarra. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var background: SKNode!
    var width = UIScreen.mainScreen().bounds.size.width
    var height = UIScreen.mainScreen().bounds.size.height
    
    var backgroundSpeed = 100.0
    var delta:NSTimeInterval =  NSTimeInterval(0)
    var timeInterval:NSTimeInterval = NSTimeInterval(0)
    
    var player:SKSpriteNode!
    var repeatAction:SKAction!
    
    let playerCategory:UInt32 = 1 << 0
    let asteroidCategory:UInt32 = 1 << 1
    let bulletCategory:UInt32 = 1 << 2
    
    var explotion:SKEmitterNode!
    var explotionAsteroid:SKEmitterNode!
    
    var gameOver = false
    var update = 0
    
    override func didMoveToView(view: SKView) {
//        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        
//        self.addChild(myLabel)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        initBackground()
        initPlayer()
        initAsteroid()
        initExplotionPlayer()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//       /* Called when a touch begins */
//        
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
//        }
        if (touches.first != nil) {
            let touch = touches.first
            let location = touch!.locationInNode(self)
            if location.x > width - width/3 {
                if gameOver == false {
                    createBullet()
                }
                
            }
        }
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (touches.first != nil) {
            let touch = touches.first
            let location = touch!.locationInNode(self)
            
            if location.x < width - width/3 {
                let newLocation:CGPoint = CGPoint(x: location.x + 80, y: location.y)
                let move = SKAction.moveTo(newLocation, duration: 0.2)
                player.runAction(move)
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        update++
        if timeInterval == 0 {
            delta = 0.0
        }else {
            delta = currentTime - timeInterval
        }
        timeInterval = currentTime
        moveBackground()
    }
    
    func initBackground() {
        background = SKNode()
        addChild(background)
        
        for i in 0...2 {
            let tile = SKSpriteNode(imageNamed: "background")
            tile.size = CGSize(width: width, height: height)
            
            tile.anchorPoint = CGPointZero
            tile.position = CGPointMake(CGFloat(i) * width, 0)
            tile.name = "bg"
            
            background.addChild(tile)
        }
    }
    
    
    func moveBackground() {
        let positionX = -backgroundSpeed * delta
        background.enumerateChildNodesWithName("bg", usingBlock: {
            (tmpSprite, stop) -> Void in
            tmpSprite.position = CGPoint(x: tmpSprite.position.x + CGFloat(positionX), y: 0)
            if tmpSprite.position.x <= -tmpSprite.frame.size.width {
                tmpSprite.position = CGPoint(x: tmpSprite.frame.size.width, y: 0)
            }
        })
    }
    
    func initPlayer() {
        player = SKSpriteNode(imageNamed: "Spaceship")
        player.position = CGPoint(x: 50, y: CGRectGetMidY(frame))
        
        let aspect = player.size.width/player.size.height
        player.size = CGSize(width: 80, height: 80/aspect)
        player.anchorPoint = CGPointMake(0.5, 0.5)
        player.zRotation = CGFloat(-M_PI_2)
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.dynamic = false
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = asteroidCategory
        player.physicsBody?.collisionBitMask = asteroidCategory
    }
    
    func createAsteroid()->SKSpriteNode {
        let asteroid = SKSpriteNode(imageNamed: "Asteroide")
        asteroid.xScale = 0.07
        asteroid.yScale = 0.07
        
        let randomY = CGFloat(arc4random_uniform(UInt32(frame.size.height)))
        asteroid.position.y = randomY + asteroid.size.height
        asteroid.position.x = frame.size.width + asteroid.size.width
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.categoryBitMask =  asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = bulletCategory
        asteroid.physicsBody?.collisionBitMask = bulletCategory
        return asteroid
    }
    
    func initAsteroid () {
        let wait = SKAction.waitForDuration(2)
        let create = SKAction.runBlock({
            () -> Void in
            let asteroid = self.createAsteroid()
            self.addChild(asteroid)
            asteroid.runAction(SKAction.moveToX(-50, duration: 2), completion: {
                asteroid.removeFromParent()
            })
        })
        
        let sequence = SKAction.sequence([wait, create])
        repeatAction = SKAction.repeatActionForever(sequence)
        runAction(repeatAction, withKey: "asteroid")
    }
    
    func createBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position.y = player.position.y
        bullet.position.x = player.position.x + 40
        bullet.xScale = 0.3
        bullet.yScale = 0.3
        bullet.runAction(SKAction.moveToX(width + 50, duration: 0.5), completion: {
            bullet.removeFromParent()
        })
        addChild(bullet)
        
        bullet.physicsBody = SKPhysicsBody(texture: bullet.texture!, size: bullet.size)
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = asteroidCategory
        bullet.physicsBody?.collisionBitMask = asteroidCategory
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if update == 0 { return }
        update = 0
        
        if contact.bodyA.categoryBitMask == asteroidCategory &&
            contact.bodyB.categoryBitMask == bulletCategory ||
            contact.bodyA.categoryBitMask == bulletCategory &&
            contact.bodyB.categoryBitMask == asteroidCategory {
                var tmpBullet:SKPhysicsBody
                var tmpAsteroid:SKPhysicsBody
                if contact.bodyA.categoryBitMask == asteroidCategory {
                    tmpAsteroid = contact.bodyA
                    tmpBullet = contact.bodyB
                }else {
                    tmpAsteroid = contact.bodyB
                    tmpBullet = contact.bodyA
                }
                
                tmpBullet.node?.removeFromParent()
                tmpAsteroid.node?.removeFromParent()
                explotionAsteroid(contact.contactPoint)
        }
        
        if contact.bodyA.categoryBitMask == playerCategory || contact.bodyB.categoryBitMask == playerCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            explotionPlayer(self.player.position)
            gameOver = true
            self.removeActionForKey("asteroid")
            self.runAction(SKAction.waitForDuration(3), completion:{
                ()-> Void in
                self.initPlayer()
                self.runAction(self.repeatAction, withKey: "asteroid")
                self.gameOver = false
            })
        }
    }
    
    func initExplotionPlayer() {
        explotion = SKEmitterNode(fileNamed: "Explorion1.sks")!
        explotionAsteroid = SKEmitterNode(fileNamed: "Explotion2.sks")
    }
    
    func explotionPlayer(position: CGPoint) {
        explotion = SKEmitterNode(fileNamed: "Explorion1.sks")!
        explotion.particlePosition = position
        self.addChild(explotion)
        self.runAction(SKAction.waitForDuration(2), completion: {
            self.explotion.removeFromParent()
        })
    }
    
    func explotionAsteroid(position: CGPoint) {
        explotionAsteroid = SKEmitterNode(fileNamed: "Explotion2.sks")!
        explotionAsteroid.particlePosition = position
        self.addChild(explotionAsteroid)
        self.runAction(SKAction.waitForDuration(2), completion: {
            self.explotionAsteroid.removeFromParent()
        })
    }

}
