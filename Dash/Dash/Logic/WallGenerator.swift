//
//  WallGenerator.swift
//  Dash
//
//  Created by Jie Liang Ang on 21/3/19.
//  Copyright © 2019 nus.cs3217. All rights reserved.
//

import Foundation
import UIKit

class WallGenerator {

    var generator: SeededGenerator

    init(_ seed: UInt64) {
        generator = SeededGenerator(seed: seed)
    }

    func generateTopWallModel(path: Path, startingY: Int) -> Path {
        return generateNoise(path: path, range: 150...400, startingY: startingY)
    }

    func generateBottomWallModel(path: Path, startingY: Int) -> Path {
        return generateNoise(path: path, range: (-400)...(-150), startingY: startingY)
    }

    func makePath(path: Path) -> UIBezierPath {
        return path.generateBezierPath()
    }

    func generateNoise(path: Path, range: ClosedRange<Int>, startingY: Int) -> Path {
        let points = path.points

        var noisePoints = points.map {
            shiftPoint(point: $0, by: range)
        }
        noisePoints[0] = Point(xVal: noisePoints[0].xVal, yVal: startingY)

        return Path(points: noisePoints, length: path.length)
    }

    func shiftPoint(point: Point, by range: ClosedRange<Int>) -> Point {
        return Point(xVal: point.xVal,
                     yVal: point.yVal + Int.random(in: range, using: &generator))
    }
}
