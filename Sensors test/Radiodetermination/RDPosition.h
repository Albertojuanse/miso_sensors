//
//  Position.h
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class RDPosition
 @discussion This class defines a position in space with its cartesian coordinates.
 */
@interface RDPosition: NSObject {
    
}

@property NSNumber * x;
@property NSNumber * y;
@property NSNumber * z;

typedef double CGFloat;
typedef CGPoint NSPoint;

- (NSPoint) toNSPoint;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToRDPosition:(RDPosition *)position;

@end

