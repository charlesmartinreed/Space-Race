//
//  GameScene.swift
//  Project23
//
//  Created by Charles Martin Reed on 8/25/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

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
    }
    
   
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    }
    
}
