//
//  RDPosition.m
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDPosition.h"

/*!
 @class RDPosition
 @discussion This class defines a position in space with its cartesian coordinates.
 */
@implementation RDPosition : NSObject

/*!
 @method init
 @discussion Constructor
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.x = [[NSNumber alloc] initWithFloat:0.0];
        self.y = [[NSNumber alloc] initWithFloat:0.0];
        self.z = [[NSNumber alloc] initWithFloat:0.0];        
    }
    return self;
}

/*!
 @method toNSPoint
 @discussion This method returns a NSPoint struct type with x and y values of the point; z is ignored.
 */
- (NSPoint) toNSPoint {
    NSPoint point;
    point.x = [self.x floatValue];
    point.y = [self.y floatValue];
    return point;
}

/*!
 @method isEqual
 @discussion This method overwrites the isEqual super method.
 */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToRDPosition:other];
}

/*!
 @method isEqualToRDPosition
 @discussion This method compares two RDPosition objects.
 */
- (BOOL)isEqualToRDPosition:(RDPosition *)position {
    if (position == self) {
        return YES;
    }
    if ([self.x isEqual:position.x] && [self.y isEqual:position.y] && [self.z isEqual:position.z]) {
        return YES;
    }
    return NO;
}

@end
