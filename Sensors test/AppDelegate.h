//
//  AppDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "StateMachine.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    // Orchestrator
    StateMachine * stateMachine;
}

@property (strong, nonatomic) UIWindow * window;

@end

