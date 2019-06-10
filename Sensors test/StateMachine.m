//
//  StateMachine.m
//  Sensors test
//
//  Created by Alberto J. on 4/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "StateMachine.h"

@implementation StateMachine

#pragma mark SatateMachineMainMethods
/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)initWithViewController:(ViewController *) viewControllerFromAppDelegate
{
    self = [super init];
    if (self) {
        // Instance parameters
        STATES = @[@"IDLE", @"UNLOCATED", @"LOCATED", @"MEASURING", @"TRAVELING"];
        self.started = YES;
        
        // View controller
        viewController = viewControllerFromAppDelegate;
        
        // Motion managing initialization.
        motion = [[MotionManager alloc] initWithViewController:viewControllerFromAppDelegate];
        [motion configure];
        
        // Location manager initialization.
        // Ask location services to initialize
        location = [[LocationManagerDelegate alloc] init];
        [location configure];
    }
    return self;
}

/*!
 @method evaluateState
 @discussion This method evaluates the current state of the state machine and decides its evolution.
 */
- (void) evaluateState {
    // Check the current state and perform the rule verification for each of them
    if ([self.state isEqualToString:STATES[0]]) {  // IDLE
        if ([self isStarted]){  // UNLOCATED?
            self.state = STATES[1];
        }
    }
    if ([self.state isEqualToString:STATES[1]]) {  // UNLOCATED
        if ([self isStopped]){  // IDLE?
            self.state = STATES[0];
        }
        if ([self isLocated]){  // LOCATED?
            self.state = STATES[2];
        }
    }
    if ([self.state isEqualToString:STATES[2]]) {  // LOCATED
        if ([self isStopped]){  // IDLE?
            self.state = STATES[0];
        }
        if ([self isMeasuring]){  // MEASURING?
            self.state = STATES[3];
        }
        if ([self isTraveling]){  // TRAVELING?
            self.state = STATES[4];
        }
    }
    if ([self.state isEqualToString:STATES[3]]) {  // MEASURING
        if ([self isStopped]){  // IDLE?
            self.state = STATES[0];
        }
        if ([self isMeasured]){  // LOCATED?
            self.state = STATES[2];
        }
    }
    if ([self.state isEqualToString:STATES[4]]) {  // TRAVELING
        if ([self isStopped]){  // IDLE?
            self.state = STATES[0];
        }
        if ([self isTraveled]){  // UNLOCATED?
            self.state = STATES[1];
        }
    }
}

/*!
 @method isStarted
 @discussion This method is called when the device is IDLE and checks if the state machine should evolve to the UNLOCATED state.
 */
- (bool) isStarted{
    return self.started;
}

/*!
 @method isStopped
 @discussion This method is called in every state and checks if the state machine should evolve to the IDLE state.
 */
- (bool) isStopped{
    return !self.started;
}

/*!
 @method isLocated
 @discussion This method is called when the device is UNLOCATED and checks if the state machine should evolve to the LOCATED state.
 */
- (bool) isLocated{
    return location.isLocated;
}

/*!
 @method isMeasuring
 @discussion This method is called when the device is LOCATED and checks if the state machine should evolve to the MEASURING state.
 */
- (bool) isMeasuring{
    return YES;
}

/*!
 @method isMeasured
 @discussion This method is called when the device is MEASURING and checks if the state machine should evolve to the LOCATED state.
 */
- (bool) isMeasured{
    return YES;
}

/*!
 @method isTraveling
 @discussion This method is called when the device is LOCATED and checks if the state machine should evolve to the TRAVELING state.
 */
- (bool) isTraveling{
    return YES;
}

/*!
 @method isTraveled
 @discussion This method is called when the device is TRAVELING and checks if the state machine should evolve to the UNLOCATED state.
 */
- (bool) isTraveled{
    return YES;
}

#pragma mark AppDelegateResponseMethods
/*!
 @method applicationWillResignActive
 @discussion Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
 */
- (void) applicationWillResignActive {
    self.started = NO;
    [motion stopAccelerometers];
    [motion stopGyroscopes];
}

/*!
 @method applicationWillResignActive
 @discussion Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
 */
- (void) applicationDidEnterBackground {
    self.started = NO;
    [motion stopAccelerometers];
    [motion stopGyroscopes];
}

/*!
 @method applicationWillEnterForeground
 @discussion Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
*/
- (void) applicationWillEnterForeground {
    self.started = YES;
    [motion startAccelerometers];
    [motion startGyroscopes];
}

/*!
 @method applicationDidBecomeActive
 @discussion Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
*/
-  (void)applicationDidBecomeActive {
    self.started = YES;
    [motion startAccelerometers];
    [motion startGyroscopes];
}

/*!
 @method applicationWillTerminate
 @discussion Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:..
 */
- (void) applicationWillTerminate {
    self.started = NO;
    [motion stopAccelerometers];
    [motion stopGyroscopes];
}

@end
