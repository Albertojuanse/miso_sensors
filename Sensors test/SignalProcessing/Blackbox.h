//
//  Blackbox.m
//  Sensors test
//
//  Created by Alberto J. on 27/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @protocol Blackbox
 @discussion This protocol defines the protocol of a blackbox type system.
 */
@protocol Blackbox

- (void) queueInput;
- (void) dequeueOutput;

@end
