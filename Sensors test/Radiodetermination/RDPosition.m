//
//  RDPosition.m
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDPosition.h"

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
 @method euclideanDistance1Dfrom:to:
 @discussion This method perfoms the calculus of the abssolute value of two NSNumbers.
 */
+ (NSNumber *) euclideanDistance1Dfrom:(NSNumber *)value1
                                   to:(NSNumber *)value2
{
    NSNumber * res = [NSNumber numberWithFloat:powf(powf([value2 floatValue] - [value1  floatValue], 2) , 0.5)];
    return res;
}

/*!
 @method euclideanDistance2Dto:
 @discussion This method perfoms the calculus of euclidean distance between this point and another 2D point.
 */
- (NSNumber *) euclideanDistance2Dto:(RDPosition *)other
{
    NSNumber * res = [NSNumber numberWithFloat:powf(
                                                    powf([other.x floatValue] - [self.x floatValue], 2) +
                                                    powf([other.y floatValue] - [self.y floatValue], 2),
                                                    0.5
                                                    )
                      ];
    return res;
}

/*!
 @method euclideanDistance3Dto:
 @discussion This method perfoms the calculus of euclidean distance between this point and another  3D points.
 */
- (NSNumber *) euclideanDistance3Dto:(RDPosition *)other
{
    NSNumber * res = [NSNumber numberWithFloat:powf(
                                                    powf([other.x floatValue] - [self.x floatValue], 2) +
                                                    powf([other.y floatValue] - [self.y floatValue], 2) +
                                                    powf([other.z floatValue] - [self.z floatValue], 2),
                                                    0.5
                                                    )
                      ];
    return res;
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

/*!
 @method description
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)description {
    return [NSString stringWithFormat: @"(%.2f, %.2f, %.2f)", [self.x floatValue], [self.y floatValue], [self.z floatValue]];
}

@end
