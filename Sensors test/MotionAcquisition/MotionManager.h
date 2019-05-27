//
//  MotionManager.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioUnit/AudioUnit.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface MotionManager : CMMotionManager {
    // Data variables
    
    // Configuration variables
    double t;
    double g;
    double calibrationTime;
    int calibrationSteps;
    double precision_threshold;
    
    // Correction variables
    double calibration_counter;
    
    double ax0;
    double ay0;
    double az0;
    
    double gx0;
    double gy0;
    double gz0;
    
    double ax_ave_sum;
    double ay_ave_sum;
    double az_ave_sum;
    
    double ax_ave;
    double ay_ave;
    double az_ave;
    
    double gx_ave_sum;
    double gy_ave_sum;
    double gz_ave_sum;
    
    double gx_ave;
    double gy_ave;
    double gz_ave;
    
    // Kinematic variables
    double ax;
    double ay;
    double az;
    
    double gx;
    double gy;
    double gz;
    
    double vx;
    double vy;
    double vz;
    
    double rx;
    double ry;
    double rz;
    
    double dp;
    double dr;
    double dy;
    
    
}

@property NSTimer *timer;
@property ViewController * viewController;

- (void) configure;
- (void) startAccelerometers;
- (void) stopAccelerometers;
- (void) startGyroscopes;
- (void) stopGyroscopes;

@end
