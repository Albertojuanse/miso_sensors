//
//  Buffer.h
//  Sensors test
//
//  Created by Alberto J. on 2/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class Buffer
 @discussion This class defines a signal processin block that given a value stores it until a its capacity is reached; then, the oldest one is popped to the output property
 */
@interface Buffer: NSObject {
    NSMutableArray * values;
    BOOL isOutput;
}

@property NSNumber * input;
@property NSNumber * disabledInput;
@property NSNumber * output;
@property BOOL enabled;
@property NSNumber * capacity;

- (void) execute;
- (void) executeWithInput:(NSNumber *)input;
- (void) executeWithInput:(NSNumber *)input
              andEnabling:(BOOL)enabling;
- (BOOL) isOutput;

@end

