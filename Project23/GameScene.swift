//
//  GameScene.swift
//  Project23
//
//  Created by Charles Martin Reed on 8/25/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //MARK:- PROPERTIES
    var starfield: SKEmitterNode! //used instead of a background this time.
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    
    //computed property
    var score = 0 {
        //property observer
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    //MARK:- GAME LOGIC PROPERTIES
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer!
    var isGameOver = false
    var gameOverLabel: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
       backgroundColor = UIColor.black
        
        //MARK:- BACKGROUND CREATION
        starfield = SKEmitterNode(fileNamed: "Starfield")!
        starfield.position = CGPoint(x: 1024, y: 384) //far right, halfway up
        
        //tells iOS to simulate 10s of particle effect, which, in this example, gives us a prepopulated starfield
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        //MARK:- PLAYER CREATION
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        
        //this is what we use to make PER-PIXEL COLLISION DETECTION WORK - we use the player's current texutre and size
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        
        //this will match the category bit mask we'll set for the debris later
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        //MARK:- SCORE LABEL CREATION
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        //MARK:- WORLD PHYSICS
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        //this is called when two bodies collide, so we're saying that our view will handle this behavior
        physicsWorld.contactDelegate = self
        
        //Start the timer for creating enemies
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    //MARK:- Collision detection and handling
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //use the location in touches to figure out where the user touched
        //restrict the player movement on the y axis to keep them in the game area
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    //this is used to end the game is the user stops touching the screen, but I'm not sure how I feel about it!
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isGameOver = true
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //create a particle emitter, position where the player is at time of collision, add the explosion to the scene while removing the player
        //set isGameOver to be true
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    }
    
    //MARK:- Enemy creation and destruction
    @objc func createEnemy() {
        //shuffle the possibleEnemies array, create a sprite node using the first item in the array, position it off the right edge and at a random vertical position, add node to the scene
        
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
        
        //we're using this to generate a random Y position within a certain range, so to speak. This is inclusive.
        let randomDistribution = GKRandomDistribution(lowestValue: 50, highestValue: 736)
        
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[0])
        
        //if we didn't call .nextInt(), our number would randomize once and we'd be stuck with that value everytime we called createEnemy!
        sprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        addChild(sprite)
        
        //setting up the per-pixel collision
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        
        //these values simulate the frictionless vacuum of space
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        //if any node is beyond x position of -300, it is to be removed
        //increment score if isGameOver is still false
        //remember that this takes place EVERY FRAME
        
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        } else {
            gameTimer.invalidate()
            starfield.isPaused = true
            //starfield.particleBirthRate = 0 stops the emitter from continuing, but this is a bit jarring
            
            gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverLabel.position = CGPoint(x: 512, y: 384)
            gameOverLabel.text = "Game Over!"
            gameOverLabel.fontColor = UIColor.red
            gameOverLabel.fontSize = 48
            addChild(gameOverLabel)
        }
    }
    
}
