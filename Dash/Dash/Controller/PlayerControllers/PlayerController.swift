//
//  PlayerController.swift
//  Dash
//
//  Created by Jolyn Tan on 3/4/19.
//  Copyright © 2019 nus.cs3217. All rights reserved.
//

import SpriteKit

/*
 `PlayerController` defines the handler for player controls.
 */
protocol PlayerController {
    var playerNode: PlayerNode? { get set }
    var isHolding: Bool { get set }
    func move()
}
