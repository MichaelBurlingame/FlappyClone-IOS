//
//  GameScene.swift
//  Final Flappy
//
//  Created by Michael Burlingame on 2/25/23.
//

import SpriteKit
import GameplayKit

enum GameSceneState {
// Track The Current Game State
    case active, gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
// -1 Due Too A Glitch Where The First Goal Rewards 2 (-1 + 2 = 1)
    var points = -1
    
// SpriteKit Objects
    var obstacleSource: SKNode!
    var obstacleLayer: SKNode!
    var scrollLayer: SKNode!
    var hero: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
// Custom Button Class
    var buttonRestart: MSButtonNode!
    
// Start Game
    var gameState: GameSceneState = .active
    
// Misc Stats
    var sinceTouch: CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    let scrollSpeed: CGFloat = 100
    
    func updateObstacles() {
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        for obstacle in obstacleLayer.children as! [SKReferenceNode] {
            
            let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
            
            if obstaclePosition.x <= -26 {
                
                obstacle.removeFromParent()
            }
        }
        
    // Create A Random Copy Of The Obstacle Causing Infinite Game
        
        if spawnTimer >= 1.5 {
            
            let newObstacle = obstacleSource.copy() as! SKNode
            obstacleLayer.addChild(newObstacle)
            
            let randomPosition =  CGPoint(x: 347, y: CGFloat.random(in: 234...382))
            
            newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
            
            spawnTimer = 0
        }
    }
    
    func scrollWorld() {
        
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            if groundPosition.x <= -ground.size.width / 2 {
                
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
    // Determine If Goal Was Passed Through If So Award Points & Return
        
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        if nodeA.name == "goal" || nodeB.name == "goal" {
            points += 1
            scoreLabel.text = String(points)
            return
        }
        
        if gameState != .active { return }
        
    // Stop The Game & Disable Controls
        
        gameState = .gameOver
        
        hero.physicsBody?.allowsRotation = false
        
        hero.physicsBody?.angularVelocity = 0
        
        hero.removeAllActions()
        
    // Dive Effect
        
        let heroDeath = SKAction.run({
            self.hero.zRotation = CGFloat(-90).degreesToRadians()
        })
        
        hero.run(heroDeath)
        
    // Call For Screen Shake
        
        let shakeScene: SKAction = SKAction.init(named: "Shake")!
        
        for node in self.children {
            node.run(shakeScene)
        }
        
    // Show Restart Button
        
        buttonRestart.state = .MSButtonNodeStateActive
        
    }
    
    override func didMove(to view: SKView) {
        
        // Node Connections
        
        hero = (self.childNode(withName: "//hero") as! SKSpriteNode)
        scrollLayer = self.childNode(withName: "scrollLayer")
        obstacleLayer = self.childNode(withName: "obstacleLayer")
        obstacleSource = self.childNode(withName: "//obstacle")
        buttonRestart = (self.childNode(withName: "buttonRestart") as! MSButtonNode)
        scoreLabel = (self.childNode(withName: "scoreLabel") as! SKLabelNode)
        
    // Reload The Scene When Button Is Pressed
        
        buttonRestart.selectedHandler = {
            
            let sKView = self.view as SKView?
            
            let scene = GameScene(fileNamed: "GameScene") as GameScene?
            
            scene?.scaleMode = .aspectFill
            
            sKView?.presentScene(scene)
            
        }
        
     // Restart Controls
        
        buttonRestart.state = .MSButtonNodeStateHidden
        hero.isPaused = false
        physicsWorld.contactDelegate = self
        scoreLabel.text = "0"
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    // If Game Is Active, Allow The Jump Controls
        
        if gameState != .active { return }
        
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
        
        hero.physicsBody?.applyAngularImpulse(1)
        
        sinceTouch = 0
        
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameState != .active { return }
        
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        if velocityY > 400 {
            hero.physicsBody?.velocity.dy = 400
        }
        
        if sinceTouch > 0.2 {
            let impulse = -20000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }
        
        hero.zRotation.clamp(v1: CGFloat(-90).degreesToRadians(), CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(v1: -1, 3)
        
        sinceTouch += fixedDelta
        scrollWorld()
        updateObstacles()
        spawnTimer += fixedDelta
    }
}
