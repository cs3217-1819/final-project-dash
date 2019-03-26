//
//  GameEngine.swift
//  Dash
//
//  Created by Jie Liang Ang on 21/3/19.
//  Copyright © 2019 nus.cs3217. All rights reserved.
//

import Foundation

class GameEngine {
    var gameModel: GameModel
    let obstacleGenerator = ObstacleGenerator()
    let wallGenerator = WallGenerator()

    var gameStage = CharacterType.arrow {
        didSet {
            gameModel.player.type = gameStage
        }
    }

    init(_ model: GameModel) {
        gameModel = model
    }

    func update() {
        let increment = gameModel.speed * Constants.fps / 200
        gameModel.distance += increment
        updateObstacles()
        updateWalls()
    }

    func updateObstacles() {
        for obstacle in gameModel.obstacles {
            // update obstacle
        }
    }

    func updateWalls() {
        let nextWalls = wallGenerator.generateNextWalls()
        gameModel.walls.append(nextWalls.top)
        gameModel.walls.append(nextWalls.bottom)

        for wall in gameModel.walls {

        }
    }

    func tap() {
        gameModel.player.tap()
    }

    func longPress() {
        gameModel.player.longPress()
    }
}
