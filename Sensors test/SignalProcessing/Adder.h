//
//  Adder.h
//  Sensors test
//
//  Created by MISO on 2/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class Adder
 @discussion This class defines a signal processin block that given two values add them; is enabled by default.
 */
@interface Adder: NSObject {
    BOOL isOutput;
}

@property NSNumber * input1;
@property NSNumber * input2;
@property NSNumber * output;
@property BOOL enabled;

- (instancetype)init;
- (void) execute;
- (void) executeWithInput1:(NSNumber *)input1
                 andInput2:(NSNumber *)input2;
- (void) executeWithInput1:(NSNumber *)input1
                 andInput2:(NSNumber *)input2
               andEnabling:(BOOL)enabling;
- (BOOL) isOutput;

@end
