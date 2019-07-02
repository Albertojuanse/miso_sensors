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
#import "Threshold.h"
#import "Buffer.h"
#import "Adder.h"
#import "Averager.h"

/*!
 @class MotionManager
 @discussion This class extends CMMotionManager object and so implements the methods that controls the acquisition of motion information and what to do with it.
 */
@interface MotionManager : CMMotionManager {
    
    // Components
    ViewController * viewController;
    SharedData * sharedData;
    
    // Configuration variables
    NSNumber * t;
    NSNumber * gx;
    NSNumber * gy;
    NSNumber * gz;
    
    // Signal processing variables
    NSNumber * acce_mea_x;
    NSNumber * acce_mea_y;
    NSNumber * acce_mea_z;
    
    NSNumber * acce_bias_x;
    NSNumber * acce_bias_y;
    NSNumber * acce_bias_z;
    
    NSNumber * gyro_mea_x;
    NSNumber * gyro_mea_y;
    NSNumber * gyro_mea_z;
    
    NSNumber * gyro_bias_x;
    NSNumber * gyro_bias_y;
    NSNumber * gyro_bias_z;
    
    NSNumber * gyro_angularSpeed_x;
    NSNumber * gyro_angularSpeed_y;
    NSNumber * gyro_angularSpeed_z;
    
    // Signal processing components
    Threshold * acce_threshold_x;
    Adder * acce_gravityAdder_x;
    Buffer * acce_measuresBuffer_x;
    Buffer * acce_biasBuffer_x;
    Averager * acce_averager_x;
    
    Threshold * gyro_threshold_x;
    Buffer * gyro_measuresBuffer_x;
    Buffer * gyro_biasBuffer_x;
    Averager * gyro_averager_x;
    Adder * gyro_biasAdder_x; // This will subtract using a inversed input
    
    Threshold * acce_threshold_y;
    Adder * acce_gravityAdder_y;
    Buffer * acce_measuresBuffer_y;
    Buffer * acce_biasBuffer_y;
    Averager * acce_averager_y;
    
    Threshold * gyro_threshold_y;
    Buffer * gyro_measuresBuffer_y;
    Buffer * gyro_biasBuffer_y;
    Averager * gyro_averager_y;
    Adder * gyro_biasAdder_y; // This will subtract using a inversed input
    
    Threshold * acce_threshold_z;
    Adder * acce_gravityAdder_z;
    Buffer * acce_measuresBuffer_z;
    Buffer * acce_biasBuffer_z;
    Averager * acce_averager_z;
    
    Threshold * gyro_threshold_z;
    Buffer * gyro_measuresBuffer_z;
    Buffer * gyro_biasBuffer_z;
    Averager * gyro_averager_z;
    Adder * gyro_biasAdder_z; // This will subtract using a inversed input
    
    // Kinematic variables
    
    // Orchestration variables
    BOOL traveling;
    RDPosition * position;
}

@property NSTimer *timer;

//  Signal processing configuration variables
@property NSNumber * acce_sensitivity_threshold;
@property NSNumber * gyro_sensitivity_threshold;

@property NSNumber * acce_measuresBuffer_capacity;
@property NSNumber * acce_biasBuffer_capacity;
@property NSNumber * gyro_measuresBuffer_capacity;
@property NSNumber * gyro_biasBuffer_capacity;

// Methods
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
