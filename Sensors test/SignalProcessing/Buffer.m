//
//  Buffer.h
//  Sensors test
//
//  Created by Alberto J. on 2/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "Buffer.h"

@implementation Buffer: NSObject

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.capacity = [NSNumber numberWithInt:100];
        values = [NSMutableArray arrayWithCapacity:[self.capacity unsignedIntegerValue]];
        self.input = [NSNumber numberWithFloat:0.0];
        self.disabledInput = [NSNumber numberWithFloat:0.0];
        self.singleOutput = [NSNumber numberWithFloat:0.0];
        self.arrayOutput = [NSMutableArray arrayWithCapacity:[self.capacity unsignedIntegerValue]];
        self.enabled = NO;
        isOutput = NO;
    }
    return self;
}

/*!
 @method initWithCapacity:
 @discussion Constructor.
 */
- (instancetype)initWithCapacity:(NSNumber *)capacity
{
    self = [super init];
    if (self) {
        self.capacity = capacity;
        values = [NSMutableArray arrayWithCapacity:[self.capacity unsignedIntegerValue]];
        self.input = [NSNumber numberWithFloat:0.0];
        self.disabledInput = [NSNumber numberWithFloat:0.0];
        self.singleOutput = [NSNumber numberWithFloat:0.0];
        self.enabled = NO;
        isOutput = NO;
    }
    return self;
}

/*!
 @method execute
 @discussion This method execute the calculus performed by this class; enabling signal and input must be asigned before.
 */
- (void) execute
{
    if (self.enabled) {
        if(values.count <= [self.capacity floatValue]) {
            [values addObject:[NSNumber numberWithFloat:[self.input floatValue]]];
            isOutput = NO;
        } else {
            self.singleOutput = [NSNumber numberWithFloat:[[values objectAtIndex:0]floatValue]];
            self.arrayOutput = [NSMutableArray arrayWithCapacity:[self.capacity unsignedIntegerValue]];
            for(NSNumber * item in values) {
                [self.arrayOutput addObject:item];
            }
            [values addObject:[NSNumber numberWithFloat:[self.input floatValue]]];
            isOutput = YES;
        }
    } else {
        if(values.count <= [self.capacity floatValue]) {
            [values addObject:[NSNumber numberWithFloat:[self.disabledInput floatValue]]];
            isOutput = NO;
        } else {
            self.singleOutput = [NSNumber numberWithFloat:[[values objectAtIndex:0]floatValue]];
            self.arrayOutput = [NSMutableArray arrayWithCapacity:[self.capacity unsignedIntegerValue]];
            for(NSNumber * item in values) {
                [self.arrayOutput addObject:item];
            }
            [values addObject:[NSNumber numberWithFloat:[self.disabledInput floatValue]]];
            isOutput = YES;
        }
    }
}

/*!
 @method executeWithInput:
 @discussion This method execute the calculus performed by this class, given its input.
 */
- (void) executeWithInput:(NSNumber *)input
{
    self.input = input;
    [self execute];
}

/*!
 @method executeWithInput:andEnabling:
 @discussion This method execute the calculus performed by this class, given its input and  the enabling signal.
 */
- (void) executeWithInput:(NSNumber *)input
              andEnabling:(BOOL)enabling;
{
    self.input = input;
    self.enabled = enabling;
    [self execute];
}

/*!
 @method isOutput
 @discussion This method is called to check if there is a valid value in the singleOutput.
 */
- (BOOL) isOutput {
    return isOutput;
}

@end

