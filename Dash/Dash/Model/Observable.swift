//
//  Observable.swift
//  Dash
//
//  Created by Jie Liang Ang on 20/3/19.
//  Copyright © 2019 nus.cs3217. All rights reserved.
//

import Foundation

protocol Observable: class {
    var observer: Observer? { get set }
}
