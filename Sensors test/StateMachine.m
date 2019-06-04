//
//  StateMachine.m
//  Sensors test
//
//  Created by Alberto J. on 4/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "StateMachine.h"

@implementation StateMachine

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        STATES = @[@"IDLE", @"UNLOCATED", @"LOCATED", @"MEASURING", @"TRAVELING"];
        self.started = YES;
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
    return YES;
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

@end
