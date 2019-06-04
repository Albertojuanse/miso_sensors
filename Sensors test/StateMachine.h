//
//  StateMachine.h
//  Sensors test
//
//  Created by Alberto J. on 4/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//


#import <Foundation/Foundation.h>

/*!
 @class StateMachine
 @discussion This class implements the state machine that orquestates the whole app.
 */
@interface StateMachine : NSObject {
    
    // The possible states of the state machine
    NSArray * STATES;
    
}

@property BOOL started;
@property NSString * state;

- (void) evaluateState;

@end
