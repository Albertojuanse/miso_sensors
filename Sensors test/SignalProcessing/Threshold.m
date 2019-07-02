//
//  Threshold.m
//  Sensors test
//
//  Created by Alberto J. on 2/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "Threshold.h"

@implementation Threshold: NSObject

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        lastValue = [NSNumber numberWithFloat:0.0];
        self.input = [NSNumber numberWithFloat:0.0];
        self.output = [NSNumber numberWithFloat:0.0];
        self.threshold = [NSNumber numberWithFloat:0.01];
        self.enabling = NO;
        isOutput = NO;
    }
    return self;
}


/*!
 @method initWithThreshold:
 @discussion Constructor.
 */
- (instancetype)initWithThreshold:(NSNumber *)threshold
{
    self = [super init];
    if (self) {
        lastValue = [NSNumber numberWithFloat:0.0];
        self.input = [NSNumber numberWithFloat:0.0];
        self.output = [NSNumber numberWithFloat:0.0];
        self.threshold = threshold;
        self.enabling = NO;
        isOutput = NO;
    }
    return self;
}

/*!
 @method execute
 @discussion This method execute the calculus performed by this class; input must be asigned before.
 */
- (void) execute
{
    isOutput = NO;
    NSNumber * difference = [NSNumber numberWithFloat:[self.input floatValue] + [lastValue floatValue]];
    
    if ([difference floatValue] < [self.threshold floatValue]) {
        self.enabling = YES;
    } else {
        self.enabling = NO;
    }
    isOutput = YES;
    self.output = self.input;
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
 @method executeWithInput:andThreshold:
 @discussion This method execute the calculus performed by this class, given its input.
 */
- (void) executeWithInput:(NSNumber *)input
             andThreshold:(NSNumber *)threshold
{
    self.threshold = threshold;
    self.input = input;
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
