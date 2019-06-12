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
 @discussion This class implements the state machine that orchestates the whole program.
 */
@interface StateMachine : NSObject {
    
    // Intance constants
    NSArray * STATES;
    NSNumber * NUMBER_OF_MEASURES;
    
    // Intance variables
    NSString * state;
    // Orchestration variables
    BOOL userWantsToStartMeasure;
    BOOL userWantsToStopMeasure;
    BOOL userWantsToStartTravel;
    BOOL userWantsToStopTravel;
    
    // Other components
    ViewController * viewController;
    MotionManager * motion;
    LocationManagerDelegate * location;
    
}

@property BOOL started;

// Threading
@property (strong, nonatomic) NSCondition *condition;
@property (strong, nonatomic) NSThread *SMThread;
// For unlock the thread from outside; YES for blocking the thread and prevent its evolution and NO for leaving it to run.
@property (nonatomic) BOOL lock;

- (instancetype)initWithViewController:(ViewController *) viewControllerFromAppDelegate;

#pragma mark AppDelegateResponseMethods

- (void) evaluateState;
- (void) needEvaluateState;
- (void) applicationWillResignActive;
- (void) applicationDidEnterBackground;
- (void) applicationWillEnterForeground;
- (void) applicationDidBecomeActive;
- (void) applicationWillTerminate;

@end
