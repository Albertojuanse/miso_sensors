//
//  Averager.m
//  Sensors test
//
//  Created by Alberto J. on 2/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "Averager.h"

@implementation Averager: NSObject

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        isOutput = NO;
        self.input = [[NSMutableArray alloc]init];
        self.output = [NSNumber numberWithFloat:0.0];
        self.enabled = YES;
    }
    return self;
}

/*!
 @method execute
 @discussion This method execute the calculus performed by this class; enabling signal and input must be asigned before.
 */
- (void) execute
{
    NSNumber * sum = [NSNumber numberWithFloat:0.0];
    for (NSNumber * item in self.input) {
        sum = [NSNumber numberWithFloat:[sum floatValue] + [item floatValue]];
    }
    NSNumber * floatCount = [NSNumber numberWithInteger:self.input.count];
    self.output = [NSNumber numberWithFloat:[sum floatValue] / [floatCount floatValue]];
    isOutput = YES;
}

/*!
 @method executeWithInput:
 @discussion This method execute the calculus performed by this class, given its input.
 */
- (void) executeWithInput:(NSMutableArray *)input
{
    self.input = input;
    [self execute];
}

/*!
 @method executeWithInput:andEnabling:
 @discussion This method execute the calculus performed by this class, given its input and the enabling signal.
 */
- (void) executeWithInput:(NSMutableArray *)input
              andEnabling:(BOOL)enabling;
{
    self.input = input;
    self.enabled = enabling;
    [self execute];
}

/*!
 @method isOutput
 @discussion This method is called to check if there is a valid value in the output.
 */
- (BOOL) isOutput {
    return isOutput;
}

@end

