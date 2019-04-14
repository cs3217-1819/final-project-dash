//
//  GameScene.swift
//  Dash
//
//  Created by Jie Liang Ang on 18/3/19.
//  Copyright © 2019 nus.cs3217. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    //nodes
    var playerNode: PlayerNode!
    var ghostNodes = [PlayerNode]()
    var backgroundNode: SKNode!
    var obstacleNode: SKNode!
    var scoreNode: ScoreNode!
    var missionNode: MissionNode!

    // model and logic
    var gameModel: GameModel!
    var gameEngine: GameEngine!
    var room: Room?

    // Mapping of Model to Node
    var walls: [ObjectIdentifier: WallNode] = [:]
    var obstacles: [ObjectIdentifier: ObstacleNode] = [:]
    var powerUps: [ObjectIdentifier: PowerUpNode] = [:]

    // gesture recognizers
    var tapGestureRecognizer: UITapGestureRecognizer!
    var longPressGestureRecognizer: UILongPressGestureRecognizer!

    var characterType = CharacterType.arrow
    private let networkManager = NetworkManager.shared
    private var handlerId: Int?
    private var pendingActions = [(ghostNode: PlayerNode, action: Action)]()
    private var startTime = 0.0
    private var currentTime = 0.0

    override func didMove(to view: SKView) {
        // Setup scene here
        initGameModel()
        initGameEngine()
        initPlayer()
        initGhost()
        //initBackground()
        initScore()
        initMission()
        
        print(characterType.rawValue)
        // Set physics world
        switch characterType {
        case .arrow:
            physicsWorld.gravity = Constants.arrowGravity
        case .flappy:
            physicsWorld.gravity = Constants.flappyGravity
        case .jetpack:
            physicsWorld.gravity = Constants.jetpackGravity
        }

    }

    override func update(_ absoluteTime: TimeInterval) {
        if startTime == 0.0 {
            startTime = absoluteTime
        }
        let nextTime = absoluteTime - startTime
        let deltaTime = nextTime - currentTime
        currentTime = nextTime

        // Called before each frame is rendered
        gameEngine.update(deltaTime, currentTime)
        playerNode.step(currentTime)
        for ghostNode in ghostNodes {
            ghostNode.step(currentTime)
        }

        let frameHeight = Double(self.frame.height)
        pendingActions = pendingActions.filter { (ghostNode, action) in
            guard currentTime > action.time + 0.1, action.type == .yPosition else {
                return true
            }
            ghostNode.position = CGPoint(x: 100, y: frameHeight * action.value)
            return false
        }

        if Int.random(in: 1...120) == 60 {
            let action = Action(time: currentTime, type: .yPosition)
            action.value = Double(playerNode.position.y) / frameHeight
            networkManager.sendAction(action)
        }

        updateScore()
    }

    func initGameModel() {
        gameModel = GameModel(characterType: characterType)
        gameModel.addObserver(self)
        gameModel.room = room
    }

    func initGameEngine() {
        gameEngine = GameEngine(gameModel)
    }

    func initPlayer() {
        playerNode = PlayerNode(gameModel.player)
        playerNode.position = CGPoint(x: CGFloat(Constants.playerOriginX), y: self.frame.height / 2)
        self.addChild(playerNode)
    }

    func initGhost() {
        guard let room = room else {
            return
        }
        room.players.forEach { player in
            let ghostNode = PlayerNode(player)
            ghostNode.position = CGPoint(x: 100, y: self.frame.height / 2)
            ghostNode.isRemote = true
            ghostNodes.append(ghostNode)
            self.addChild(ghostNode)
        }
        // TODO: Memory leak -> Remove action handler in deinit etc
        handlerId = networkManager.addActionHandler { [weak self] (peerID, action) in
            self?.ghostNodes.forEach { ghostNode in
                guard ghostNode.playerId == peerID, action.type == .yPosition else {
                    return
                }
                self?.pendingActions.append((ghostNode, action))
            }
        }
    }

    func initBackground() {
        backgroundNode = BackgroundNode(self.frame)
        self.addChild(backgroundNode)
    }

    func initScore() {
        scoreNode = ScoreNode()
        scoreNode.position = CGPoint(x: 100, y: self.frame.height - 70)
        self.addChild(scoreNode)
    }

    func initMission() {
        missionNode = MissionNode(mission: gameModel.mission)
        missionNode.position = CGPoint(x: self.frame.midX, y: 0)
        self.addChild(missionNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameEngine.hold()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameEngine.release()
    }

    func updateScore() {
        scoreNode.update(Int(gameModel.distance))
    }
}

extension GameScene: Observer {
    func onValueChanged(name: String, object: Any?) {
        // TODO: Refactor
        switch name {
        case "wall":
            // Add new walls
            for wall in gameModel.walls where walls[ObjectIdentifier(wall)] == nil {
                let wallNode = WallNode(wall: wall)
                self.addChild(wallNode)
                walls[ObjectIdentifier(wall)] = wallNode
            }
            // Remove walls
            // Object identifier of all present walls in gameModel
            let wallOids = gameModel.walls.map { ObjectIdentifier($0) }

            // Remove wallNodes that are not in the gameModel
            for wallOid in walls.keys where !wallOids.contains(wallOid) {
                guard let wallNode = walls[wallOid] else {
                    continue
                }
                wallNode.removeFromParent()
                walls.removeValue(forKey: wallOid)
            }
        case "obstacle":
            // Add new obstacles
            for obstacle in gameModel.obstacles where obstacles[ObjectIdentifier(obstacle)] == nil {
                let obstacleNode = ObstacleNode(obstacle: obstacle)
                self.addChild(obstacleNode)
                obstacles[ObjectIdentifier(obstacle)] = obstacleNode
            }
            // Remove obstacleNodes that are not in the gameModel
            let obstacleOids = gameModel.obstacles.map { ObjectIdentifier($0) }
            for obstacleOid in obstacles.keys where !obstacleOids.contains(obstacleOid) {
                guard let obstacleNode = obstacles[obstacleOid] else {
                    continue
                }
                obstacleNode.removeFromParent()
                obstacles.removeValue(forKey: obstacleOid)
            }
        case "powerUp":
            // Add new power ups
            for powerUp in gameModel.powerUps where powerUps[ObjectIdentifier(powerUp)] == nil {
                let powerUpNode = PowerUpNode(powerUp: powerUp)
                self.addChild(powerUpNode)
                powerUps[ObjectIdentifier(powerUp)] = powerUpNode
            }
            // Remove powerUpNodes that are not in the gameModel
            let powerUpOids = gameModel.powerUps.map { ObjectIdentifier($0) }
            for powerUpOid in powerUps.keys where !powerUpOids.contains(powerUpOid) {
                guard let powerUpNode = powerUps[powerUpOid] else {
                    continue
                }
                powerUpNode.removeFromParent()
                powerUps.removeValue(forKey: powerUpOid)
            }
        default:
            break
        }
    }
}
