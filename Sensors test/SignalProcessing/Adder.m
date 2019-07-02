//
//  Adder.m
//  Sensors test
//
//  Created by MISO on 2/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "Adder.h"

@implementation Adder: NSObject

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        isOutput = NO;
        self.input1 = [NSNumber numberWithFloat:0.0];
        self.input2 = [NSNumber numberWithFloat:0.0];
        self.output = [NSNumber numberWithFloat:0.0];
        self.enabled = YES;
    }
    return self;
}

/*!
 @method execute
 @discussion This method execute the calculus performed by this class; enabling signal and inputs must be asigned before.
 */
- (void) execute
{
    self.output = [NSNumber numberWithFloat:[self.input1 floatValue] + [self.input2 floatValue]];
    isOutput = YES;
}

/*!
 @method executeWithInput1:andInput2:
 @discussion This method execute the calculus performed by this class, given its inputs.
 */
- (void) executeWithInput1:(NSNumber *)input1
                 andInput2:(NSNumber *)input2
{
    self.input1 = input1;
    self.input2 = input2;
    [self execute];
}

/*!
 @method executeWithInput1:andInput2:andEnabling:
 @discussion This method execute the calculus performed by this class, given its inputs and  the enabling signal.
 */
- (void) executeWithInput1:(NSNumber *)input1
                 andInput2:(NSNumber *)input2
               andEnabling:(BOOL)enabling;
{
    self.input1 = input1;
    self.input2 = input2;
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
