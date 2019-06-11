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
        viewController = viewControllerFromAppDelegate;
        motion = [[MotionManager alloc] initWithViewController:viewControllerFromAppDelegate];
        [motion configure];
        location = [[LocationManagerDelegate alloc] init];
        [location configure];
        
        // Properties
        self.started = NO;
        
        // Threading
        // Start with the thread locked
        self.lock = YES;
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
        
        // Action state machine evolution
        [self evaluateState];
        
        // Lock the condition again and release
        self.lock = YES;
        [self.condition signal];
        [self.condition unlock];
    }
}

/*!
 @method evaluateState
 @discussion This method evaluates the current state of the state machine and decides its evolution.
 */
- (void) evaluateState {
    // Check the current state and perform the rule verification for each of them
    NSLog(@"[INFO][SM] Evaluating state. Current state %@", state);
    if ([state isEqualToString:STATES[0]]) {  // IDLE
        if ([self isStarted]){  // UNLOCATED?
            state = STATES[1];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[0], state);
        }
    }
    if ([state isEqualToString:STATES[1]]) {  // UNLOCATED
        if ([self isStopped]){  // IDLE?
            state = STATES[0];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[1], state);
        }
        if ([self isLocated]){  // LOCATED?
            state = STATES[2];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[1], state);
        }
    }
    if ([state isEqualToString:STATES[2]]) {  // LOCATED
        if ([self isStopped]){  // IDLE?
            state = STATES[0];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[2], state);
        }
        if ([self isMeasuring]){  // MEASURING?
            state = STATES[3];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[2], state);
        }
        if ([self isTraveling]){  // TRAVELING?
            state = STATES[4];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[2], state);
        }
    }
    if ([state isEqualToString:STATES[3]]) {  // MEASURING
        if ([self isStopped]){  // IDLE?
            state = STATES[0];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[3], state);
        }
        if ([self isMeasured]){  // LOCATED?
            state = STATES[2];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[3], state);
        }
    }
    if ([state isEqualToString:STATES[4]]) {  // TRAVELING
        if ([self isStopped]){  // IDLE?
            state = STATES[0];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[4], state);
        }
        if ([self isTraveled]){  // UNLOCATED?
            state = STATES[1];
            NSLog(@"[INFO][SM] -> From state %@ to %@", STATES[4], state);
        }
    }
}

/*!
 @method isStarted
 @discussion This method is called when the device is IDLE and checks if the state machine should evolve to the UNLOCATED state.
 */
- (BOOL) isStarted{
    [viewController.labelStatus setText:@"UNLOCATED; tap 'Measure' or 'Travel' to start."];
    return self.started;
}

/*!
 @method isStopped
 @discussion This method is called in every state and checks if the state machine should evolve to the IDLE state.
 */
- (BOOL) isStopped{
    return !self.started;
}

/*!
 @method isLocated
 @discussion This method is called when the device is UNLOCATED and checks if the state machine should evolve to the LOCATED state.
 */
- (BOOL) isLocated{
    if ([location isLocated]) {
        [viewController.labelStatus setText:@"LOCATED; tap 'Measure' or 'Travel' to start."];
        // Control tapping
        [viewController.buttonMeasure setEnabled:YES];
        [viewController.buttonTravel setEnabled:YES];
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
    if (userWantsToStartMeasure) {
        [viewController.labelStatus setText:@"MEASURING; tap 'Measure' again for stop the measure."];
        // Control tapping
        [viewController.buttonMeasure setEnabled:YES];
        [viewController.buttonTravel setEnabled:NO];
        // Ask location manager to start measuring
        [location startMeasuring];
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method isMeasured
 @discussion This method is called when the device is MEASURING and checks if the state machine should evolve to the LOCATED state.
 */
- (BOOL) isMeasured{
    if(userWantsToStopMeasure) {
        [viewController.labelStatus setText:@"LOCATED; tap 'Measure' or 'Travel' to start."];
        // Ask location manager to stop measuring
        [location stopMeasuring];
        // Control tapping
        [viewController.buttonMeasure setEnabled:YES];
        [viewController.buttonTravel setEnabled:YES];
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method isTraveling
 @discussion This method is called when the device is LOCATED and checks if the state machine should evolve to the TRAVELING state.
 */
- (BOOL) isTraveling{
    if (userWantsToStartTravel) {
        [viewController.labelStatus setText:@"TRAVELING; tap 'Travel' again for stop the travel."];
        // Prevent new tapping
        [viewController.buttonMeasure setEnabled:NO];
        [viewController.buttonTravel setEnabled:YES];
        // Ask motion manager to start taveling
        [location setLocated:NO];
        RDPosition * currentPosition = [location getPosition];
        [motion startTravelingFrom:currentPosition];
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method isTraveled
 @discussion This method is called when the device is TRAVELING and checks if the state machine should evolve to the UNLOCATED state.
 */
- (BOOL) isTraveled {
    if(userWantsToStopTravel) {
        [viewController.labelStatus setText:@"UNLOCATED; tap 'Measure' or 'Travel' to start."];
        // Ask motion manager to stop t
        [location stopMeasuring];
        // Control tapping
        [viewController.buttonMeasure setEnabled:NO];
        [viewController.buttonTravel setEnabled:NO];
        [location setPosition:[motion getFinalPosition]];
        [location setLocated:YES];
        return YES;
    } else {
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
                userWantsToStartTravel = YES;
                userWantsToStopTravel = NO;
            } else if (userWantsToStartTravel && userWantsToStopTravel) {
                NSLog(@"[ERROR][SM] Both 'userWantsToStartTravel' && 'userWantsToStopTravel' flags are YES");
                userWantsToStartTravel = NO;
                userWantsToStopTravel = NO;
            }
        }
        
        // Unlock the thread for recycle
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
                userWantsToStartMeasure = YES;
                userWantsToStopMeasure = NO;
            } else if (userWantsToStartMeasure && userWantsToStopMeasure) {
                NSLog(@"[ERROR][SM] Both 'userWantsToStartMeasure' && 'userWantsToStopMeasure' flags are YES");
                userWantsToStartMeasure = NO;
                userWantsToStopMeasure = NO;
            }
        }
        
        // Unlock the thread for recycle
        self.lock = NO;
        [self.condition signal];
        [self.condition unlock];
    }
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
