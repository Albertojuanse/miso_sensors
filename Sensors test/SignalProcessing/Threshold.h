//
//  Threshold.h
//  Sensors test
//
//  Created by Alberto J. on 2/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class Threshold
 @discussion This class defines a signal processin block that given a value compares it with the last one stored and specifies if their difference is greater than some value
 */
@interface Threshold: NSObject {
    NSNumber * lastValue;
}

@property NSNumber * input;
@property NSNumber * output;
@property NSNumber * threshold;
@property BOOL enabling;

- (void) execute;
- (void) executeWithInput:(NSNumber *)input;
- (void) executeWithInput:(NSNumber *)input
             andThreshold:(NSNumber *)threshold;

@end