//
//  AppDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "MotionManager.h"
#import "LocationManagerDelegate.h"
#import "ViewController.h"
#import "StateMachine.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    // Orchestrator
    StateMachine * stateMachine;
    // Main view; its control will be delegated to the machine state, but for initialization porpuses it's instantiated here.
    
    ViewController * viewController;
}

@property (strong, nonatomic) UIWindow *window;

@end

