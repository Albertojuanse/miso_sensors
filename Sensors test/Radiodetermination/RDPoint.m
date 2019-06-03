//
//  RDPoint.m
//  Sensors test
//
//  Created by Alberto J. on 3/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDPoint.h"

@implementation RDPoint: NSObject

/*!
 @method toNSPoint
 @discussion This method returns a NSPoint struct type with x and y values of the point; z is ignored.
 */
- (NSPoint) toNSPoint {
    NSPoint point;
    point.x = self.x;
    point.y = self.y;
    return point;
}

@end
