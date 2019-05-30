//
//  Position.m
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.x = [[NSNumber alloc] initWithDouble:0.0];
        self.y = [[NSNumber alloc] initWithDouble:0.0];
        self.z = [[NSNumber alloc] initWithDouble:0.0];        
    }
    return self;
}

@end
