//
//  ViewController.swift
//  breakout
//
//  Created by Ian W. Howe on 5/2/16.
//  Copyright © 2016 Ian W. Howe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    var ball = UIView()
    var paddle = UIView()
    var dynamicAnimator = UIDynamicAnimator()
    var blockArray = [Block]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        //Add a black ball object to the view
        ball = UIView(frame: CGRectMake(view.center.x, view.center.y, 20, 20))
        ball.backgroundColor = UIColor.blackColor()
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        //Add a red paddle object to the view
        paddle = UIView(frame: CGRectMake(view.center.x , view.center.y * 1.7, 80, 20))
        paddle.layer.cornerRadius = 5
        paddle.clipsToBounds = true
        paddle.backgroundColor = UIColor.redColor()
        view.addSubview(paddle)
        
        //Setup Block Array
        
        let totalWidth = view.frame.width - 30
        let totalHeight = view.frame.height / 3
        let widthIncrement = totalWidth / 5
        let heightIncrement = totalHeight / 8
        var counter = 0
        for i in 0...4 {
            for j in 0...3 {
                let blockFrame = CGRectMake(15 + CGFloat(i) * widthIncrement, 15 + CGFloat(j) * heightIncrement, widthIncrement - 15, heightIncrement - 15)
                let newBlock = Block(frame: blockFrame)
                newBlock.view.tag = counter
                counter += 1
                blockArray.append(newBlock)
                view.addSubview((blockArray.last?.view)!)
                
            }
        }
        
        resetAnimator()
        
    }

    func resetAnimator() {
        dynamicAnimator.removeAllBehaviors()
        ball.center = CGPoint(x: view.center.x , y: view.center.y)
        
        //Create dynamic behavior for the ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.density = 1.0
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        //Create a push behavior for the ball
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(ViewController.launchBall), userInfo: nil, repeats: false)
        
        //create dynamic animator for paddle
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 10000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        for blockObject in blockArray {
            let collisionBehavior = UICollisionBehavior(items: [ball, paddle, blockObject.view])
            collisionBehavior.translatesReferenceBoundsIntoBoundary = true
            collisionBehavior.collisionMode = .Everything
            collisionBehavior.collisionDelegate = self
            dynamicAnimator.addBehavior(collisionBehavior)
            
            let blockDynamicBehavior = UIDynamicItemBehavior(items: [blockObject.view])
            blockDynamicBehavior.density = 10000
            blockDynamicBehavior.resistance = 100
            blockDynamicBehavior.allowsRotation = false
            dynamicAnimator.addBehavior(blockDynamicBehavior)
        }
    }
    
    func launchBall() {
        let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        var xVector = 0.0
        var yVector = 0.0
        while xVector == 0 || yVector == 0 {
            let rng = drand48()
            if rng > 0.2 {
                if xVector != 0 {
                    yVector = rng
                }
                else {
                    xVector = rng
                }
            }
        }
        pushBehavior.pushDirection = CGVectorMake(CGFloat(xVector), CGFloat(yVector))
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
    }

    @IBAction func paddleMoved(sender: UIPanGestureRecognizer) {
        let panGesture = sender.locationInView(view)
        paddle.center = CGPointMake(panGesture.x, paddle.center.y)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }
 
//    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem) {
//        for blockObject in blockArray {
//            if item1.isEqual(blockObject) || item2.isEqual(blockObject) {
//                blockObject.blockHit()
//            }
//        }
//    }
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        print(p)
        for blockObject in blockArray {
            if item1.isEqual(blockObject) || item2.isEqual(blockObject) {
                print("block hit")
                blockObject.blockHit()
            }
        }
    }
    

}

