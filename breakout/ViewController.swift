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
    var deadZone = UIView()
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
        
        //Add a paddle object to the view
        paddle = UIView(frame: CGRectMake(view.center.x , view.center.y * 1.7, 80, 20))
        paddle.layer.cornerRadius = 5
        paddle.clipsToBounds = true
        paddle.backgroundColor = UIColor.blueColor()
        view.addSubview(paddle)
        
        //Add a uiView to detect a collision at the bottom of the screen
        deadZone = UIView(frame: CGRectMake(0,view.frame.height - 10, view.frame.width, 10))
        deadZone.backgroundColor = UIColor.redColor()
        view.addSubview(deadZone)
        
        resetBlockArray()
        resetBall()
        resetBlockCollisions()
        
    }
    
    func resetBlockArray() {
        blockArray.removeAll()
        for subView in view.subviews {
            if subView.tag == 2 {
                //Instert code to remove block from view
            }
        }
        
        let totalWidth = view.frame.width - 30
        let totalHeight = view.frame.height / 3
        let widthIncrement = totalWidth / 5
        let heightIncrement = totalHeight / 8
        for i in 0...4 {
            for j in 0...3 {
                let blockFrame = CGRectMake(15 + CGFloat(i) * widthIncrement, 15 + CGFloat(j) * heightIncrement, widthIncrement - 15, heightIncrement - 15)
                let newBlock = Block(frame: blockFrame)
                newBlock.view.tag = 2
                blockArray.append(newBlock)
                view.addSubview((blockArray.last?.view)!)
                
            }
        }
    }
    

    func resetBall() {
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
    }
    
    func resetBlockCollisions() {
        //create dynamic animator for paddle
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle, deadZone])
        paddleDynamicBehavior.density = 10000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        for blockObject in blockArray {
            if blockObject.blockStatus != 0 {
                let collisionBehavior = UICollisionBehavior(items: [ball, paddle, deadZone, blockObject.view])
                collisionBehavior.translatesReferenceBoundsIntoBoundary = true
                collisionBehavior.collisionMode = .Everything
                collisionBehavior.collisionDelegate = self
                blockObject.behavior = collisionBehavior
                dynamicAnimator.addBehavior(collisionBehavior)
                
                let blockDynamicBehavior = UIDynamicItemBehavior(items: [blockObject.view])
                blockDynamicBehavior.density = 10000
                blockDynamicBehavior.resistance = 100
                blockDynamicBehavior.allowsRotation = false
                dynamicAnimator.addBehavior(blockDynamicBehavior)
            }
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
 
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        print(p)
        for blockObject in blockArray {
            let detectionArea = CGRectMake(blockObject.view.frame.origin.x - 7, blockObject.view.frame.origin.y - 7, blockObject.view.frame.width + 14, blockObject.view.frame.height + 14)
            if detectionArea.contains(p){
                print("block hit")
                blockObject.blockHit()
                if blockObject.blockStatus == 0 {
                    dynamicAnimator.removeBehavior(blockObject.behavior)
                }
                break
            }
        }
        var allBlocksCleared = true
        for blockObject in blockArray {
            if blockObject.blockStatus != 0 {
                allBlocksCleared = false
            }
        }
        if allBlocksCleared {
            createEndgameScreen(true)
        }
        else if p.y > paddle.frame.origin.y + 20 {
            createEndgameScreen(false)
        }
    }
    
    func createEndgameScreen(victory: Bool) {
        var alertController = UIAlertController()
        if victory {
            alertController = UIAlertController(title: "Oh look, You won!", message: "Would you like to play again?", preferredStyle: .Alert)
        }
        else {
            alertController = UIAlertController(title: "Unsuprisingly, you lost.", message: "Would you like to play again?", preferredStyle: .Alert)
        }
        let cancelAction = UIAlertAction(title: "Nah.", style: .Cancel, handler:
            {
                (action) -> Void in
                fatalError()
        })
        let okAction = UIAlertAction(title: "Of course!", style: .Default, handler:
            {
                (action) -> Void in
                //Add code to reset all the things
                self.dynamicAnimator.removeAllBehaviors()
                self.resetBall()
                self.resetBlockCollisions()
                self.resetBlockArray()
        })
        alertController.addAction(cancelAction)
        alertController.addAction((okAction))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}