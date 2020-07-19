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
        self.x = [[NSNumber alloc] initWithFloat:32.0];
        self.y = [[NSNumber alloc] initWithFloat:0.0];
        self.z = [[NSNumber alloc] initWithFloat:0.0];        
    }
    return self;
}

/*!
 @method initWithCoder:
 @discussion Constructor called when an object must be initiated with the data stored, shared... with a coding way.
 */
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.x = [decoder decodeObjectForKey:@"x"];
    self.y = [decoder decodeObjectForKey:@"y"];
    self.z = [decoder decodeObjectForKey:@"z"];
    
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
 @method toCGPoint
 @discussion This method returns a CGPoint struct type with x and y values of the point; z is ignored.
 */
- (CGPoint) toCGPoint {
    return CGPointMake([self.x floatValue], [self.y floatValue]);
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
 @method encodeWithCoder:
 @discussion This method is called when this object must be coded as a data object for storing, sharing...
 */
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.x forKey:@"x"];
    [encoder encodeObject:self.y forKey:@"y"];
    [encoder encodeObject:self.z forKey:@"z"];
}

/*!
 @method description
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)description {
    return [NSString stringWithFormat: @"(%.2f, %.2f, %.2f)", [self.x floatValue], [self.y floatValue], [self.z floatValue]];
}

@end
