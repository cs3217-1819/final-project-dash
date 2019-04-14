//
//  Player.swift
//  Dash
//
//  Created by Jie Liang Ang on 20/3/19.
//  Copyright © 2019 nus.cs3217. All rights reserved.
//

import Foundation

class Player: Observable {
    var observers = [ObjectIdentifier : Observer]()
    var id = ""
    var type: CharacterType

    var isHolding = false {
        didSet {
            notifyObservers(name: Constants.notificationStateChange, object: self)
        }
    }
    var actionIndex = 0
    var actionList = [Action]()

    init(type: CharacterType) {
        self.type = type
    }

    func step(_ time: Double) {
        guard actionIndex < actionList.count else {
            return
        }

        let nextAction = actionList[actionIndex]
        guard nextAction.time < time else {
            return
        }

        switch nextAction.type {
        case .hold:
            isHolding = true
        case .release:
            isHolding = false
        default:
            break
        }
        actionIndex += 1
    }
}
