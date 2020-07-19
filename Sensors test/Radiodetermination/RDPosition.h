//
//  RDPosition.h
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @protocol RDPosition
 @discussion Abstract definition of any position in space with its cartesian coordinates.
 */
@protocol RDPosition

@required
@property NSNumber * x;
@property NSNumber * y;
@property NSNumber * z;

@optional
- (BOOL)isEqual:(id)other;
- (NSString *)description;
- (NSString *)stringValue;

@end

/*!
 @class RDPosition
 @discussion This class defines a position in space with its cartesian coordinates.
 */
@interface RDPosition: NSObject <RDPosition, NSCoding> {
    
}

@property NSNumber * x;
@property NSNumber * y;
@property NSNumber * z;

typedef CGPoint NSPoint;

- (NSPoint) toNSPoint;
- (CGPoint) toCGPoint;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToRDPosition:(RDPosition *)position;
+ (NSNumber *) euclideanDistance1Dfrom:(NSNumber *)value1
                                    to:(NSNumber *)value2;
- (NSNumber *) euclideanDistance2Dto:(RDPosition *)other;
- (NSNumber *) euclideanDistance3Dto:(RDPosition *)other;
@end

