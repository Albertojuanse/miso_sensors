//
//  Averager.h
//  Sensors test
//
//  Created by MISO on 2/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class Averager
 @discussion This class defines a signal processin block that given an array of values calculate some average of them; is enabled by default.
 */
@interface Averager: NSObject {
    BOOL isOutput;
}

@property NSMutableArray * input;
@property NSNumber * output;
@property BOOL enabled;

- (instancetype)init;
- (void) execute;
- (void) executeWithInput:(NSMutableArray *)input;
- (void) executeWithInput:(NSMutableArray *)input
              andEnabling:(BOOL)enabling;
- (BOOL) isOutput;

@end
