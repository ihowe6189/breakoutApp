//
//  Block.swift
//  breakout
//
//  Created by Ian W. Howe on 5/2/16.
//  Copyright © 2016 Ian W. Howe. All rights reserved.
//

import Foundation
import UIKit

class Block {
    
    var blockStatus: Int
    var view: UIView
    var behavior: UICollisionBehavior
    
    init() {
        blockStatus = 2
        view = UIView()
        view.frame = CGRectMake(0, 0, 40, 10)
        view.backgroundColor = UIColor.yellowColor()
        
    }
    
    init(x: CGFloat, y: CGFloat) {
        blockStatus = 2
        view = UIView()
        view.frame = CGRectMake(x, y, 40, 10)
        view.backgroundColor = UIColor.yellowColor()
    }
    
    init(frame: CGRect) {
        blockStatus = 2
        view = UIView()
        view.frame = frame
        view.backgroundColor = UIColor.yellowColor()
    }
    
    func blockHit() {
        blockStatus -= 1
        if blockStatus == 1 {
            view.backgroundColor = UIColor.redColor()
        }
        if blockStatus == 0 {
            view.removeFromSuperview()
        }
    }
    
}