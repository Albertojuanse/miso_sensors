//
//  StateMachine.h
//  Sensors test
//
//  Created by Alberto J. on 4/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StateMachine.h"
#import "ViewController.h"
#import "MotionManager.h"
#import "LocationManagerDelegate.h"

/*!
 @class StateMachine
 @discussion This class implements the state machine that orquestates the whole app.
 */
@interface StateMachine : NSObject {
    
    // The possible states of the state machine
    NSArray * STATES;
    // Other components
    MotionManager * motion;
    LocationManagerDelegate * location;
    ViewController * viewController;
    
}

@property BOOL started;
@property NSString * state;

- (instancetype)initWithViewController:(ViewController *) viewControllerFromAppDelegate;
- (void) evaluateState;
- (void) applicationWillResignActive;
- (void) applicationDidEnterBackground;
- (void) applicationWillEnterForeground;
- (void) applicationDidBecomeActive;
- (void) applicationWillTerminate;

@end
