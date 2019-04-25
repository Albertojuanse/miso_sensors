//
//  MotionManager.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface MotionManager : CMMotionManager {
    double x;
    double y;
    double z;
}

@property NSTimer *timer;

- (void) startAccelerometers;
- (void) stopAccelerometers;

@end
