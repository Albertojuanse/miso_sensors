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
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // Instance constants
        STATES = @[@"IDLE", @"UNLOCATED", @"LOCATED", @"MEASURING", @"TRAVELING"];
        NUMBER_OF_MEASURES = [NSNumber numberWithInt:10];
        
        // Instance variables
        state = STATES[0];
        // Orchestration variables
        userWantsToStartMeasure = NO;
        userWantsToStopMeasure = NO;
        userWantsToStartTravel = NO;
        userWantsToStopTravel = NO;
        
        // Other components
        sharedData = [[SharedData alloc] init];
        motion = [[MotionManager alloc] initWithSharedData:sharedData];
        
        motion.acce_sensitivity_threshold = [NSNumber numberWithFloat:0.01];
        motion.gyro_sensitivity_threshold = [NSNumber numberWithFloat:0.015];
        motion.acce_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.acce_biasBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_biasBuffer_capacity = [NSNumber numberWithInt:500];
        
        location = [[LocationManagerDelegate alloc] initWithSharedData:sharedData];
        
        // Properties
        self.started = YES;
        
        // Threading
        // Start with the thread locked
        self.lock = NO;
        // NSCondition instance
        self.condition = [[NSCondition alloc]init];
        // Create the thread and start it
        self.SMThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadLoop) object:nil];
        [self.SMThread start];
        
        // This object must listen to this events
        // From view controller
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleButtonTravel:)
                                                     name:@"handleButtonTravel"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleButtonMeasure:)
                                                     name:@"handleButtonMeasure"
                                                   object:nil];
        // From anywhere
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(needEvaluateState)
                                                     name:@"needEvaluateState"
                                                   object:nil];
    }
    return self;
}

/*!
 @method threadLoop
 @discussion This method run the main loop of the state machine thread and so evaluates the current state of the state machine and decides its evolution.
 */
- (void)threadLoop {
    while([[NSThread currentThread] isCancelled] == NO || self.started == YES) {
        // Acquire the lock
        [self.condition lock];
        // Wait if itself had been locked from outside until notification
        while(self.lock) {
            [self.condition wait];
        }
        
        // Lock the condition again and release
        self.lock = YES;
        [self.condition signal];
        [self.condition unlock];
        
        // Action state machine evolution; it must be called after release the condition
        [self evaluateState];
    }
}

/*!
 @method evaluateState
 @discussion This method evaluates the current state of the state machine and decides its evolution.
 */
- (void) evaluateState {
    // Check the current state and perform the rule verification for each of them
    
    // Acquire the lock to get the currentState
    [self.condition lock];
    NSString * currentState = [NSString stringWithString:state];
    NSString * lastState;
    [self.condition signal];
    [self.condition unlock];
    
    // Recycle the state machine
    NSLog(@"[INFO][SM] Evaluating state. Current state %@", currentState);
    if ([currentState isEqualToString:STATES[0]]) {  // IDLE
        if ([self isStarted]){  // UNLOCATED?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[1];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
    }
    if ([state isEqualToString:STATES[1]]) {  // UNLOCATED
        if ([self isStopped]){  // IDLE?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[0];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
        if ([self isLocated]){  // LOCATED?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[2];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
    }
    if ([state isEqualToString:STATES[2]]) {  // LOCATED
        if ([self isStopped]){  // IDLE?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[0];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
        if ([self isMeasuring]){  // MEASURING?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[3];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
        if ([self isTraveling]){  // TRAVELING?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[4];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
    }
    if ([state isEqualToString:STATES[3]]) {  // MEASURING
        if ([self isStopped]){  // IDLE?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[0];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
        if ([self isMeasured]){  // LOCATED?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[2];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
    }
    if ([state isEqualToString:STATES[4]]) {  // TRAVELING
        if ([self isStopped]){  // IDLE?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[0];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
        if ([self isTraveled]){  // UNLOCATED?
            [self.condition lock];
            lastState = [NSString stringWithString:state];
            state = STATES[1];
            currentState = [NSString stringWithString:state];
            [self.condition signal];
            [self.condition unlock];
            NSLog(@"[INFO][SM] -> From state %@ to %@", lastState, currentState);
        }
    }
}

/*!
 @method needEvaluateState
 @discussion Set the class' lock as NO, and so the state machine recycles one t; it must be called everyt that something happens.
 */
- (void) needEvaluateState {
    NSLog(@"[INFO][SM] Asked to recycle the state machine");
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    self.lock = NO;
    [self.condition signal];
    [self.condition unlock];
}

/*!
 @method isStarted
 @discussion This method is called when the device is IDLE and checks if the state machine should evolve to the UNLOCATED state.
 */
- (BOOL) isStarted{
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController.labelStatus setText:@"UNLOCATED; tap 'Measure' or 'Travel' to start."];
    });
    
    BOOL isStarted;
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    if (self.started) {
        isStarted = YES;
    } else {
        isStarted = NO;
    }
    [self.condition signal];
    [self.condition unlock];
    
    return isStarted;
}

/*!
 @method isStopped
 @discussion This method is called in every state and checks if the state machine should evolve to the IDLE state.
 */
- (BOOL) isStopped{
    
    BOOL isStoped;
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    if (!self.started) {
        isStoped = YES;
    } else {
        isStoped = NO;
    }
    [self.condition signal];
    [self.condition unlock];
    
    return isStoped;
}

/*!
 @method isLocated
 @discussion This method is called when the device is UNLOCATED and checks if the state machine should evolve to the LOCATED state.
 */
- (BOOL) isLocated{
    if ([location isLocated]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController.labelStatus setText:@"LOCATED; tap 'Measure' or 'Travel' to start."];
            // Control tapping
            [viewController.buttonMeasure setEnabled:YES];
            [viewController.buttonTravel setEnabled:YES];
        });
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method isMeasuring
 @discussion This method is called when the device is LOCATED and checks if the state machine should evolve to the MEASURING state.
 */
- (BOOL) isMeasuring{
    
    NSLog(@"[INFO][SM] isMeasuring method called");
    BOOL userWantsToStartMeasureFlag;
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    if (userWantsToStartMeasure) {
        userWantsToStartMeasureFlag = YES;
    } else {
        userWantsToStartMeasureFlag = NO;
    }
    [self.condition signal];
    [self.condition unlock];
    
    NSLog(userWantsToStartMeasureFlag ? @"[INFO][SM] userWantsToStartMeasureFlag is YES" : @"[INFO][SM] userWantsToStartMeasureFlag is NO");
    
    if (userWantsToStartMeasureFlag) {
        NSLog(@"[INFO][SM] Label is going to be changed");
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController.labelStatus setText:@"MEASURING; tap 'Measure' again for stop the measure."];
            // Control tapping
            [viewController.buttonMeasure setEnabled:YES];
            [viewController.buttonTravel setEnabled:NO];
        });
        // Ask location manager to start measuring
        [location startMeasuring];
        NSLog(@"[INFO][SM] Location manager has been asked to start measuring; returns YES");
        return YES;
    } else {
        NSLog(@"[INFO][SM] isMeasuring method returns NO");
        return NO;
    }
}

/*!
 @method isMeasured
 @discussion This method is called when the device is MEASURING and checks if the state machine should evolve to the LOCATED state.
 */
- (BOOL) isMeasured{
    
    NSLog(@"[INFO][SM] isMeasured method called");
        BOOL userWantsToStopMeasureFlag;
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    if (userWantsToStopMeasure) {
        userWantsToStopMeasureFlag = YES;
    } else {
        userWantsToStopMeasureFlag = NO;
    }
    [self.condition signal];
    [self.condition unlock];
    
    NSLog(userWantsToStopMeasureFlag ? @"[INFO][SM] userWantsToStopMeasureFlag is YES" : @"[INFO][SM] userWantsToStopMeasureFlag is NO");
    
    if(userWantsToStopMeasureFlag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[INFO][SM] Label is going to be changed");
            [viewController.labelStatus setText:@"LOCATED; tap 'Measure' or 'Travel' to start."];
            // Control tapping
            [viewController.buttonMeasure setEnabled:YES];
            [viewController.buttonTravel setEnabled:YES];
        });
        // Ask location manager to stop measuring
        [location stopMeasuring];
        NSLog(@"[INFO][SM] Location manager has been asked to stop measuring; returns YES");
        return YES;
    } else {
        NSLog(@"[INFO][SM] isMeasured method returns NO");
        return NO;
    }
}

/*!
 @method isTraveling
 @discussion This method is called when the device is LOCATED and checks if the state machine should evolve to the TRAVELING state.
 */
- (BOOL) isTraveling{
    
    NSLog(@"[INFO][SM] isTraveling method called");
    BOOL userWantsToStartTravelFlag;
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    if (userWantsToStartTravel) {
        userWantsToStartTravelFlag = YES;
    } else {
        userWantsToStartTravelFlag = NO;
    }
    [self.condition signal];
    [self.condition unlock];
    
    NSLog(userWantsToStartTravelFlag ? @"[INFO][SM] userWantsToStartTravelFlag is YES" : @"[INFO][SM] userWantsToStartTravelFlag is NO");
    
    if (userWantsToStartTravelFlag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[INFO][SM] Label is going to be changed");
            [viewController.labelStatus setText:@"TRAVELING; tap 'Travel' again for stop the travel."];
            // Prevent new tapping
            [viewController.buttonMeasure setEnabled:NO];
            [viewController.buttonTravel setEnabled:YES];
        });
        // Ask motion manager to start traveling
        [location setLocated:NO];
        RDPosition * currentPosition = [location getPosition];
        [motion startTravelingFrom:currentPosition];
        NSLog(@"[INFO][SM] Motion manager has been asked to start traveling; returns YES");
        return YES;
    } else {
        NSLog(@"[INFO][SM] isTraveling method returns NO");
        return NO;
    }
}

/*!
 @method isTraveled
 @discussion This method is called when the device is TRAVELING and checks if the state machine should evolve to the UNLOCATED state.
 */
- (BOOL) isTraveled {
    
    NSLog(@"[INFO][SM] isTraveled method called");
    BOOL userWantsToStopTravelFlag;
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    if (userWantsToStopTravel) {
        userWantsToStopTravelFlag = YES;
    } else {
        userWantsToStopTravelFlag = NO;
    }
    [self.condition signal];
    [self.condition unlock];
    
    NSLog(userWantsToStopTravelFlag ? @"[INFO][SM] userWantsToStopTravelFlag is YES" : @"[INFO][SM] userWantsToStopTravelFlag is NO");
    
    if(userWantsToStopTravelFlag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[INFO][SM] Label is going to be changed");
            [viewController.labelStatus setText:@"UNLOCATED; tap 'Measure' or 'Travel' to start."];
            // Control tapping
            [viewController.buttonMeasure setEnabled:NO];
            [viewController.buttonTravel setEnabled:NO];
        });
        // Ask motion manager to stop traveling
        [motion stopTraveling];
        [location setPosition:[motion getFinalPosition]];
        [location setLocated:YES];
        NSLog(@"[INFO][SM] Motion manager has been asked the final position of the travel; returns YES");
        return YES;
    } else {
        NSLog(@"[INFO][SM] isTraveled method returns NO");
        return NO;
    }
}

#pragma mark SatateMachineOrchestratorMethods
/*!
 @method handleButtonTravel
 @discussion This method handles the action in which the Measure button is pressed; it must disable both control buttons and ask motion manager to start traveling.
 */
- (void) handleButtonTravel:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"handleButtonTravel"]){
        NSLog(@"[NOTI][SM] Notification \"handleButtonTravel\" recived");
        [self.condition lock];
        
        if (state == STATES[2]) {  // LOCATED
            if (!userWantsToStartTravel && !userWantsToStopTravel) {
                userWantsToStartTravel = YES;
            } else if (userWantsToStartTravel && !userWantsToStopTravel) {
                userWantsToStartTravel = NO;
                userWantsToStopTravel = YES;
            } else if (!userWantsToStartTravel && userWantsToStopTravel) {
                NSLog(@"[ERROR][SM] 'userWantsToStartTravel' is NO && 'userWantsToStopTravel' is YES");
                userWantsToStartTravel = NO;
                userWantsToStopTravel = NO;
            } else if (userWantsToStartTravel && userWantsToStopTravel) {
                NSLog(@"[ERROR][SM] Both 'userWantsToStartTravel' && 'userWantsToStopTravel' flags are YES");
                userWantsToStartTravel = NO;
                userWantsToStopTravel = NO;
            }
        }
        
        if (state == STATES[4]) {  // TRAVELING
            if (!userWantsToStartTravel && !userWantsToStopTravel) {
                userWantsToStartTravel = YES;
            } else if (userWantsToStartTravel && !userWantsToStopTravel) {
                userWantsToStartTravel = NO;
                userWantsToStopTravel = YES;
            } else if (!userWantsToStartTravel && userWantsToStopTravel) {
                NSLog(@"[ERROR][SM] 'userWantsToStartTravel' is NO && 'userWantsToStopTravel' is YES");
                userWantsToStartTravel = NO;
                userWantsToStopTravel = NO;
            } else if (userWantsToStartTravel && userWantsToStopTravel) {
                NSLog(@"[ERROR][SM] Both 'userWantsToStartTravel' && 'userWantsToStopTravel' flags are YES");
                userWantsToStartTravel = NO;
                userWantsToStopTravel = NO;
            }
        }
        
        // Unlock the thread for recycle
        NSLog(@"[INFO][SM] Asked to recycle the state machine");
        self.lock = NO;
        [self.condition signal];
        [self.condition unlock];
    }
}

/*!
 @method handleButtonMeasure
 @discussion This method handles the action in which the Measure button is pressed; it must disable both control buttons and ask location manager delegate to start measuring.
 */
- (void) handleButtonMeasure:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"handleButtonMeasure"]){
        NSLog(@"[NOTI][SM] Notification \"handleButtonMeasure\" recived");
        [self.condition lock];
        
        if (state == STATES[2]) {  // LOCATED
            if (!userWantsToStartMeasure && !userWantsToStopMeasure) {
                userWantsToStartMeasure = YES;
            } else if (userWantsToStartMeasure && !userWantsToStopMeasure) {
                userWantsToStartMeasure = NO;
                userWantsToStopMeasure = YES;
            } else if (!userWantsToStartMeasure && userWantsToStopMeasure) {
                NSLog(@"[ERROR][SM] 'userWantsToStartMeasure' is NO && 'userWantsToStopMeasure' is YES");
                userWantsToStartMeasure = NO;
                userWantsToStopMeasure = NO;
            } else if (userWantsToStartMeasure && userWantsToStopMeasure) {
                NSLog(@"[ERROR][SM] Both 'userWantsToStartMeasure' && 'userWantsToStopMeasure' flags are YES");
                userWantsToStartMeasure = NO;
                userWantsToStopMeasure = NO;
            }
        }
        
        if (state == STATES[3]) {  // MEASURING
            if (!userWantsToStartMeasure && !userWantsToStopMeasure) {
                userWantsToStartMeasure = YES;
            } else if (userWantsToStartMeasure && !userWantsToStopMeasure) {
                userWantsToStartMeasure = NO;
                userWantsToStopMeasure = YES;
            } else if (!userWantsToStartMeasure && userWantsToStopMeasure) {
                NSLog(@"[ERROR][SM] 'userWantsToStartMeasure' is NO && 'userWantsToStopMeasure' is YES");
                userWantsToStartMeasure = NO;
                userWantsToStopMeasure = NO;
            } else if (userWantsToStartMeasure && userWantsToStopMeasure) {
                NSLog(@"[ERROR][SM] Both 'userWantsToStartMeasure' && 'userWantsToStopMeasure' flags are YES");
                userWantsToStartMeasure = NO;
                userWantsToStopMeasure = NO;
            }
        }
        
        // Unlock the thread for recycle
        NSLog(@"[INFO][SM] Asked to recycle the state machine");
        self.lock = NO;
        [self.condition signal];
        [self.condition unlock];
    }
}

#pragma mark AppDelegateResponseMethods
/*!
 @method applicationWillResignActive
 @discussion Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Use this method to pause ongoing tasks, disable trs, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
 */
- (void) applicationWillResignActive {
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    self.started = NO;
    [self.condition signal];
    [self.condition unlock];
    [motion stopAccelerometers];
    [motion stopGyroscopes];
}

/*!
 @method applicationWillResignActive
 @discussion Use this method to release shared resources, save user data, invalidate trs, and store enough application state information to restore your application to its current state in case it is terminated later. If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
 */
- (void) applicationDidEnterBackground {
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    self.started = NO;
    [self.condition signal];
    [self.condition unlock];
    [motion stopAccelerometers];
    [motion stopGyroscopes];
}

/*!
 @method applicationWillEnterForeground
 @discussion Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
*/
- (void) applicationWillEnterForeground {
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    self.started = YES;
    [self.condition signal];
    [self.condition unlock];
    [motion startAccelerometers];
    [motion startGyroscopes];
}

/*!
 @method applicationDidBecomeActive
 @discussion Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
*/
-  (void)applicationDidBecomeActive {
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    self.started = YES;
    [self.condition signal];
    [self.condition unlock];
    [motion startAccelerometers];
    [motion startGyroscopes];
}

/*!
 @method applicationWillTerminate
 @discussion Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:..
 */
- (void) applicationWillTerminate {
    // Acquire the lock
    [self.condition lock];
    // Unlock the condition again and release
    self.started = NO;
    [self.condition signal];
    [self.condition unlock];
    [motion stopAccelerometers];
    [motion stopGyroscopes];
}

@end
