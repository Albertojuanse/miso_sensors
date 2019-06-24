//
//  MotionManager.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#include <stdlib.h>
#import "ViewController.h"
#import "SharedData.h"

/*!
 @class MotionManager
 @discussion This class extends CMMotionManager object and so implements the methods that controls the acquisition of motion information and what to do with it.
 */
@interface MotionManager : CMMotionManager {
    
    // Components
    ViewController * viewController;
    SharedData * sharedData;
    
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
    
    double gp0;
    double gr0;
    double gy0;
    
    double ax_ave_sum;
    double ay_ave_sum;
    double az_ave_sum;
    
    double ax_ave;
    double ay_ave;
    double az_ave;
    
    double gp_ave_sum;
    double gr_ave_sum;
    double gy_ave_sum;
    
    double gp_ave;
    double gr_ave;
    double gy_ave;
    
    // Kinematic variables
    double ax;
    double ay;
    double az;
    
    double gp;
    double gr;
    double gy;
    
    double vx;
    double vy;
    double vz;
    
    double rx;
    double ry;
    double rz;
    
    double dp;
    double dr;
    double dy;
    
    BOOL traveling;
    RDPosition * position;
}

@property NSTimer *timer;

- (instancetype) initWithViewController:(ViewController *) viewControllerFromStateMachine
                          andSharedData:(SharedData *)initSharedData;
- (void) startAccelerometers;
- (void) stopAccelerometers;
- (void) startGyroscopes;
- (void) stopGyroscopes;
- (void) startTravelingFrom:(RDPosition*)initialPosition;
- (void) stopTraveling;
- (RDPosition *) getFinalPosition;

@end
