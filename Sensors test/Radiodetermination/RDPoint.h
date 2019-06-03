//
//  RDPoint.h
//  Sensors test
//
//  Created by Alberto J. on 3/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RDPoint: NSObject

@property float x;
@property float y;
@property float z;

typedef double CGFloat;
typedef CGPoint NSPoint;

- (NSPoint) toNSPoint;

@end
