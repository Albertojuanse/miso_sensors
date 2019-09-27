//
//  MotionManager.m
//  Sensors test
//
//  Created by MISO on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "MotionManager.h"

@implementation MotionManager

/*!
 @method init
 @discussion Constructor given the shared data collection.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
{
    self = [super init];
    if (self) {
        // Components
        sharedData = initSharedData;
        
        // Configuration variables
        t = [NSNumber numberWithFloat:1.0/100.0];
        gx = [NSNumber numberWithFloat:0.0];
        gy = [NSNumber numberWithFloat:0.0];
        gz = [NSNumber numberWithFloat:-9.7994];
        
        //  Signal processing configuration variables
        self.acce_sensitivity_threshold = [NSNumber numberWithFloat:0.01];
        self.gyro_sensitivity_threshold = [NSNumber numberWithFloat:0.015];
        self.acce_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        self.acce_biasBuffer_capacity = [NSNumber numberWithInt:500];
        self.gyro_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        self.gyro_biasBuffer_capacity = [NSNumber numberWithInt:500];
        
        // Signal processing variables
        acce_mea_x = [NSNumber numberWithFloat:0.0];
        acce_mea_y = [NSNumber numberWithFloat:0.0];
        acce_mea_z = [NSNumber numberWithFloat:0.0];
        
        acce_bias_x = [NSNumber numberWithFloat:0.0];
        acce_bias_y = [NSNumber numberWithFloat:0.0];
        acce_bias_z = [NSNumber numberWithFloat:0.0];
        
        
        // Signal processing components
        acce_threshold_x = [[Threshold alloc] initWithThreshold:self.acce_sensitivity_threshold];
        acce_gravityAdder_x = [[Adder alloc] init];
        acce_measuresBuffer_x = [[Buffer alloc] initWithCapacity:self.acce_measuresBuffer_capacity];
        acce_measuresBuffer_x.enabled = YES;
        acce_biasBuffer_x = [[Buffer alloc] initWithCapacity:self.acce_biasBuffer_capacity];
        acce_averager_x = [[Averager alloc] init];
        
        gyro_threshold_x = [[Threshold alloc] initWithThreshold:self.gyro_sensitivity_threshold];
        gyro_measuresBuffer_x = [[Buffer alloc] initWithCapacity:self.gyro_measuresBuffer_capacity];
        gyro_measuresBuffer_x.enabled = YES;
        gyro_biasBuffer_x = [[Buffer alloc] initWithCapacity:self.gyro_biasBuffer_capacity];
        gyro_averager_x = [[Averager alloc] init];
        gyro_biasAdder_x = [[Adder alloc] init]; // This will subtract using a inversed input
        
        acce_threshold_y = [[Threshold alloc] initWithThreshold:self.acce_sensitivity_threshold];
        acce_gravityAdder_y = [[Adder alloc] init];
        acce_measuresBuffer_y = [[Buffer alloc] initWithCapacity:self.acce_measuresBuffer_capacity];
        acce_measuresBuffer_y.enabled = YES;
        acce_biasBuffer_y = [[Buffer alloc] initWithCapacity:self.acce_biasBuffer_capacity];
        acce_averager_y = [[Averager alloc] init];
        
        gyro_threshold_y = [[Threshold alloc] initWithThreshold:self.gyro_sensitivity_threshold];
        gyro_measuresBuffer_y = [[Buffer alloc] initWithCapacity:self.gyro_measuresBuffer_capacity];
        gyro_measuresBuffer_y.enabled = YES;
        gyro_biasBuffer_y = [[Buffer alloc] initWithCapacity:self.gyro_biasBuffer_capacity];
        gyro_averager_y = [[Averager alloc] init];
        gyro_biasAdder_y = [[Adder alloc] init]; // This will subtract using a inversed input
        
        acce_threshold_z = [[Threshold alloc] initWithThreshold:self.acce_sensitivity_threshold];
        acce_gravityAdder_z = [[Adder alloc] init];
        acce_measuresBuffer_z = [[Buffer alloc] initWithCapacity:self.acce_measuresBuffer_capacity];
        acce_measuresBuffer_z.enabled = YES;
        acce_biasBuffer_z = [[Buffer alloc] initWithCapacity:self.acce_biasBuffer_capacity];
        acce_averager_z = [[Averager alloc] init];
        
        gyro_threshold_z = [[Threshold alloc] initWithThreshold:self.gyro_sensitivity_threshold];
        gyro_measuresBuffer_z = [[Buffer alloc] initWithCapacity:self.gyro_measuresBuffer_capacity];
        gyro_measuresBuffer_z.enabled = YES;
        gyro_biasBuffer_z = [[Buffer alloc] initWithCapacity:self.gyro_biasBuffer_capacity];
        gyro_averager_z = [[Averager alloc] init];
        gyro_biasAdder_z = [[Adder alloc] init]; // This will subtract using a inversed input
        
        // Kinematic variables
        pos_x = [NSNumber numberWithFloat:0.0];
        pos_y = [NSNumber numberWithFloat:0.0];
        pos_z = [NSNumber numberWithFloat:0.0];
        
        vel_x = [NSNumber numberWithFloat:0.0];
        vel_y = [NSNumber numberWithFloat:0.0];
        vel_z = [NSNumber numberWithFloat:0.0];
        
        Rnb_11 = [NSNumber numberWithFloat:1.0];
        Rnb_12 = [NSNumber numberWithFloat:0.0];
        Rnb_13 = [NSNumber numberWithFloat:0.0];
        
        Rnb_21 = [NSNumber numberWithFloat:0.0];
        Rnb_22 = [NSNumber numberWithFloat:1.0];
        Rnb_23 = [NSNumber numberWithFloat:0.0];
        
        Rnb_31 = [NSNumber numberWithFloat:0.0];
        Rnb_32 = [NSNumber numberWithFloat:0.0];
        Rnb_33 = [NSNumber numberWithFloat:1.0];
        
        attitude_x = [NSNumber numberWithFloat:0.0]; // Pitch
        attitude_y = [NSNumber numberWithFloat:0.0]; // Roll
        attitude_z = [NSNumber numberWithFloat:0.0]; // Yaw
        
        // Orchestration variables
        traveling = NO;
        calibrated = NO;
        position = [[RDPosition alloc] init];
        
        // This object must listen to this events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startTraveling:)
                                                     name:@"startTraveling"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopTraveling:)
                                                     name:@"stopTraveling"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startTravelingFrom:)
                                                     name:@"getPositionRespond"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startAccelerometers)
                                                     name:@"startAccelerometers"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopAccelerometers)
                                                     name:@"stopAccelerometers"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startGyroscopes)
                                                     name:@"startGyroscopes"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopGyroscopes)
                                                     name:@"stopGyroscopes"
                                                   object:nil];
        
        NSLog(@"[INFO][MM] MotionManager prepared");
        }
    return self;
}

/*!
 @method initWithSharedData:userDic:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    credentialsUserDic = initCredentialsUserDic;
    userDic = initUserDic;
    self = [self initWithSharedData:initSharedData];
    return self;
}

#pragma mark - Instance methods
/*!
 @method setCredentialUserDic:
 @discussion This method sets the dictionary with the user's credentials for acess the collections in shared data database.
 */
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    credentialsUserDic = givenCredentialsUserDic;
    return;
}

/*!
 @method setUserDic:
 @discussion This method sets the dictionary of the user in whose name the measures are saved.
 */
- (void)setUserDic:(NSMutableDictionary *)givenUserDic
{
    userDic = givenUserDic;
    return;
}

/*!
 @method getPosition
 @discussion This method gets the device's position.
 */
- (RDPosition *) getPosition {
    RDPosition * newPosition = [[RDPosition alloc] init];
    newPosition.x = [NSNumber numberWithFloat:[position.x floatValue]];
    newPosition.y = [NSNumber numberWithFloat:[position.y floatValue]];
    newPosition.z = [NSNumber numberWithFloat:[position.z floatValue]];
    return newPosition;
}

/*!
 @method setPosition:
 @discussion This method sets the device's position.
 */
- (void) setPosition:(RDPosition *)givenPosition{
    position = [[RDPosition alloc] init];
    position.x = [NSNumber numberWithFloat:[givenPosition.x floatValue]];
    position.y = [NSNumber numberWithFloat:[givenPosition.y floatValue]];
    position.z = [NSNumber numberWithFloat:[givenPosition.z floatValue]];
}

#pragma mark - Location manager methods

/*!
 @method startAccelerometers
 @discussion This method manages how the accelerometer status acquisition starts and its error's control.
 */
- (void) startAccelerometers {
    
    // Make sure the accelerometer hardware is available.
    if (self.isAccelerometerAvailable) {
        NSLog(@"[INFO][MM] Accelerometer avalible");
        self.accelerometerUpdateInterval = [t doubleValue];
        [self startAccelerometerUpdates];
        if (self.tr == nil){
        // Configure a tr to fetch the data.
            self.tr = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:([t doubleValue])
                                                    target:self
                                                  selector:@selector(process)
                                                  userInfo:nil
                                                   repeats:YES];
        
            // Add the tr to the current run loop.
            [[NSRunLoop currentRunLoop] addTimer:self.tr forMode:NSDefaultRunLoopMode];
        }
    } else {
        NSLog(@"[ERROR][MM] Accelerometer not avalible");
    }
    NSLog(@"[INFO][MM] Accelerometer started");
}

/*!
 @method stopAccelerometers
 @discussion This method manages how the accelerometer status acquisition stops.
 */
- (void) stopAccelerometers {
    [self.tr invalidate];
    self.tr = nil;
    [self stopAccelerometerUpdates];
    NSLog(@"[INFO][MM] Accelerometer stopped");
}

/*!
 @method startGyroscopes
 @discussion This method manages how the gyroscope status acquisition starts and its error's control.
 */
- (void) startGyroscopes {
    // Make sure the gyroscope hardware is available.
    if (self.isGyroAvailable) {
        NSLog(@"[INFO][MM] Gyroscope avalible");
        self.gyroUpdateInterval = [t doubleValue];
        [self startGyroUpdates];
        
        if (self.tr == nil){
            // Configure a tr to fetch the data.
            self.tr = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:([t doubleValue])
                                                    target:self
                                                  selector:@selector(process)
                                                  userInfo:nil
                                                   repeats:YES];
            
            // Add the tr to the current run loop.
            [[NSRunLoop currentRunLoop] addTimer:self.tr forMode:NSDefaultRunLoopMode];
        }
    } else {
        NSLog(@"[ERROR][MM] Gyroscope not avalible");
    }
    NSLog(@"[INFO][MM] Gyroscope started");
}

/*!
 @method stopGyroscopes
 @discussion This method manages how the gyroscope status acquisition stops.
 */
- (void) stopGyroscopes {
    [self.tr invalidate];
    self.tr = nil;
    [self stopGyroUpdates];
    NSLog(@"[INFO] Gyroscope stopped");
}

/*!
 @method procces
 @discussion This method procces the acquisited data.
 */
- (void) process {
    // NSLog(@"; \"x\": %f, \"y\": %f, \"z\": %f, \"type\": \"gyroscope\"} {\"date\":", self.gyroData.rotationRate.x, self.gyroData.rotationRate.y, self.gyroData.rotationRate.y);
    // NSLog(@"; \"x\": %f, \"y\": %f, \"z\": %f, \"type\": \"accelerometer\"} {\"date\":", self.accelerometerData.acceleration.x, self.accelerometerData.acceleration.y, self.accelerometerData.acceleration.z);
    
    NSNumber * gravity_rotated_x = [NSNumber numberWithFloat:[gx floatValue]];
    NSNumber * gravity_rotated_y = [NSNumber numberWithFloat:[gx floatValue]];
    NSNumber * gravity_rotated_z = [NSNumber numberWithFloat:[gx floatValue]];
    
    // There will be necesary 6 processing channels: 3 for accelerometers and 3 for gyroscopes
    
    // First channel: accelerometer in x axis
    acce_mea_x = [NSNumber numberWithFloat:self.accelerometerData.acceleration.x];
    
    [acce_threshold_x executeWithInput:acce_mea_x];
    
    [acce_measuresBuffer_x executeWithInput:acce_mea_x];
    
    if([acce_threshold_x isOutput]) {
        [acce_gravityAdder_x executeWithInput1:gravity_rotated_x andInput2:acce_mea_x];
        
        if ([acce_gravityAdder_x isOutput]) {
            [acce_biasBuffer_x executeWithInput:acce_gravityAdder_x.output
                                    andEnabling:acce_threshold_x.enabling];
            
            if ([acce_biasBuffer_x isOutput]) {
                calibrated = YES; // If there is output in buasBuffer means that the t of calibrating is finished
                [acce_averager_x executeWithInput:acce_biasBuffer_x.arrayOutput];
                
                if ([acce_averager_x isOutput]) {
                    acce_bias_x = [NSNumber numberWithFloat:[acce_averager_x.output floatValue]];
                    acce_biasBuffer_x.disabledInput = [NSNumber numberWithFloat:[acce_averager_x.output floatValue]];
                    //viewController.labelAX.text = [NSString stringWithFormat:@"%.2f", [acce_measuresBuffer_x.singleOutput floatValue] - [acce_averager_x.output floatValue]];
                }
            }
        }
    }
    
    
    // Second channel: accelerometer in y axis
    acce_mea_y = [NSNumber numberWithFloat:self.accelerometerData.acceleration.y];
    
    [acce_threshold_y executeWithInput:acce_mea_y];
    
    [acce_measuresBuffer_y executeWithInput:acce_mea_y];
    
    if([acce_threshold_y isOutput]) {
        [acce_gravityAdder_y executeWithInput1:gravity_rotated_y andInput2:acce_mea_y];
        
        if ([acce_gravityAdder_y isOutput]) {
            [acce_biasBuffer_y executeWithInput:acce_gravityAdder_y.output
                                    andEnabling:acce_threshold_y.enabling];
            
            if ([acce_biasBuffer_y isOutput]) {
                [acce_averager_y executeWithInput:acce_biasBuffer_y.arrayOutput];
                
                if ([acce_averager_y isOutput]) {
                    acce_bias_y = [NSNumber numberWithFloat:[acce_averager_y.output floatValue]];
                    acce_biasBuffer_y.disabledInput = [NSNumber numberWithFloat:[acce_averager_y.output floatValue]];
                    //viewController.labelAY.text = [NSString stringWithFormat:@"%.2f", [acce_measuresBuffer_y.singleOutput floatValue] - [acce_averager_y.output floatValue]];
                }
            }
        }
    }
    
    
    // Third channel: accelerometer in z axis
    acce_mea_z = [NSNumber numberWithFloat:self.accelerometerData.acceleration.z];
    
    [acce_threshold_z executeWithInput:acce_mea_z];
    
    [acce_measuresBuffer_z executeWithInput:acce_mea_z];
    
    if([acce_threshold_z isOutput]) {
        [acce_gravityAdder_z executeWithInput1:gravity_rotated_z andInput2:acce_mea_z];
        
        if ([acce_gravityAdder_z isOutput]) {
            [acce_biasBuffer_z executeWithInput:acce_gravityAdder_z.output
                                    andEnabling:acce_threshold_z.enabling];
            
            if ([acce_biasBuffer_z isOutput]) {
                [acce_averager_z executeWithInput:acce_biasBuffer_z.arrayOutput];
                
                if ([acce_averager_z isOutput]) {
                    acce_bias_z = [NSNumber numberWithFloat:[acce_averager_z.output floatValue]];
                    acce_biasBuffer_z.disabledInput = [NSNumber numberWithFloat:[acce_averager_z.output floatValue]];
                    //viewController.labelAZ.text = [NSString stringWithFormat:@"%.2f", [acce_measuresBuffer_z.singleOutput floatValue] - [acce_averager_z.output floatValue]];
                    
                }
            }
        }
    }
    
    
    // Fourth channel: gyroscope in x axis
    gyro_mea_x = [NSNumber numberWithFloat:self.gyroData.rotationRate.x];
    
    [gyro_threshold_x executeWithInput:gyro_mea_x];
    
    [gyro_measuresBuffer_x executeWithInput:gyro_mea_x];
    
    if([gyro_threshold_x isOutput]) {
        [gyro_biasBuffer_x executeWithInput:gyro_threshold_x.output
                                andEnabling:gyro_threshold_x.enabling];
        
        if ([gyro_biasBuffer_x isOutput]) {
            [gyro_averager_x executeWithInput:gyro_biasBuffer_x.arrayOutput];
            
            if ([gyro_averager_x isOutput]) {
                
                gyro_bias_x = [NSNumber numberWithFloat:[gyro_averager_x.output floatValue]];
                gyro_biasBuffer_x.disabledInput = [NSNumber numberWithFloat:[gyro_averager_x.output floatValue]];
                
                [gyro_biasAdder_x executeWithInput1:gyro_measuresBuffer_x.singleOutput
                                          andInput2:[NSNumber numberWithFloat:-[gyro_bias_x floatValue]]];
                
                if ([gyro_biasAdder_x isOutput]) {
                    
                    // Only reasing if is not noise
                    if (!gyro_threshold_x.enabling) {
                        gyro_angularSpeed_x = [NSNumber numberWithFloat:[gyro_biasAdder_x.output floatValue]];
                    }
                    //viewController.labelGX.text = [NSString stringWithFormat:@"%.2f", [gyro_angularSpeed_x floatValue]];
                    
                }
            }
        }
    }
    
    // Fifth channel: gyroscope in y axis
    gyro_mea_y = [NSNumber numberWithFloat:self.gyroData.rotationRate.y];
    
    [gyro_threshold_y executeWithInput:gyro_mea_y];
    
    [gyro_measuresBuffer_y executeWithInput:gyro_mea_y];
    
    if([gyro_threshold_y isOutput]) {
        [gyro_biasBuffer_y executeWithInput:gyro_threshold_y.output
                                andEnabling:gyro_threshold_y.enabling];
        
        if ([gyro_biasBuffer_y isOutput]) {
            [gyro_averager_y executeWithInput:gyro_biasBuffer_y.arrayOutput];
            
            if ([gyro_averager_y isOutput]) {
                
                gyro_bias_y = [NSNumber numberWithFloat:[gyro_averager_y.output floatValue]];
                gyro_biasBuffer_y.disabledInput = [NSNumber numberWithFloat:[gyro_averager_y.output floatValue]];
                
                [gyro_biasAdder_y executeWithInput1:gyro_measuresBuffer_y.singleOutput
                                          andInput2:[NSNumber numberWithFloat:-[gyro_bias_y floatValue]]];
                
                if ([gyro_biasAdder_y isOutput]) {
                    
                    // Only reasing if is not noise
                    if (!gyro_threshold_y.enabling) {
                        gyro_angularSpeed_y = [NSNumber numberWithFloat:[gyro_biasAdder_y.output floatValue]];
                    }
                    //viewController.labelGY.text = [NSString stringWithFormat:@"%.2f", [gyro_angularSpeed_y floatValue]];
                    
                }
            }
        }
    }
    
    // Sixth channel: gyroscope in z axis
    gyro_mea_z = [NSNumber numberWithFloat:self.gyroData.rotationRate.y];
    
    [gyro_threshold_z executeWithInput:gyro_mea_z];
    
    [gyro_measuresBuffer_z executeWithInput:gyro_mea_z];
    
    if([gyro_threshold_z isOutput]) {
        [gyro_biasBuffer_z executeWithInput:gyro_threshold_z.output
                                andEnabling:gyro_threshold_z.enabling];
        
        if ([gyro_biasBuffer_z isOutput]) {
            [gyro_averager_z executeWithInput:gyro_biasBuffer_z.arrayOutput];
            
            if ([gyro_averager_z isOutput]) {
                
                gyro_bias_z = [NSNumber numberWithFloat:[gyro_averager_z.output floatValue]];
                gyro_biasBuffer_z.disabledInput = [NSNumber numberWithFloat:[gyro_averager_z.output floatValue]];
                
                [gyro_biasAdder_z executeWithInput1:gyro_measuresBuffer_z.singleOutput
                                          andInput2:[NSNumber numberWithFloat:-[gyro_bias_z floatValue]]];
                
                if ([gyro_biasAdder_z isOutput]) {
                    
                    // Only reasing if is not noise
                    if (!gyro_threshold_z.enabling) {
                        gyro_angularSpeed_z = [NSNumber numberWithFloat:[gyro_biasAdder_z.output floatValue]];
                    }
                    //viewController.labelGZ.text = [NSString stringWithFormat:@"%.2f", [gyro_angularSpeed_z floatValue]];
                }
            }
        }
    }
    
    if (calibrated) {
        //viewController.labelCalibrated.text = @"Calibrated";
        // Calculate the velocity and position; explicit matricial calculations
        // Pt+1 = Pt + t * vt + T^2/2 ( Rnb_t (measures - bias) + g )
        if (!acce_threshold_x.enabling) {
            pos_x = [NSNumber numberWithFloat:
                     [pos_x floatValue] +
                     [t floatValue] * [vel_x floatValue] +
                     [t floatValue] * [t floatValue] * 0.5 *
                     (
                      [Rnb_11 floatValue] * ([acce_measuresBuffer_x.singleOutput floatValue] - [acce_averager_x.output floatValue]) +
                      [Rnb_12 floatValue] * ([acce_measuresBuffer_y.singleOutput floatValue] - [acce_averager_y.output floatValue]) +
                      [Rnb_13 floatValue] * ([acce_measuresBuffer_z.singleOutput floatValue] - [acce_averager_z.output floatValue]) +
                      [gx floatValue]
                      )
                     ];
        }
    
        //viewController.labelPosX.text = [NSString stringWithFormat:@"%.2f", [pos_x floatValue]];
    
        if (!acce_threshold_y.enabling) {
            pos_y = [NSNumber numberWithFloat:
                     [pos_y  floatValue] +
                     [t floatValue] * [vel_y floatValue] +
                     [t floatValue] * [t floatValue] * 0.5 *
                     (
                      [Rnb_21 floatValue] * ([acce_measuresBuffer_x.singleOutput floatValue] - [acce_averager_x.output floatValue]) +
                      [Rnb_22 floatValue] * ([acce_measuresBuffer_y.singleOutput floatValue] - [acce_averager_y.output floatValue]) +
                      [Rnb_23 floatValue] * ([acce_measuresBuffer_z.singleOutput floatValue] - [acce_averager_z.output floatValue]) +
                      [gy floatValue]
                      )
                     ];
        }
    
        //viewController.labelPosY.text = [NSString stringWithFormat:@"%.2f", [pos_y floatValue]];
    
        if (!acce_threshold_z.enabling) {
            pos_z = [NSNumber numberWithFloat:
                     [pos_z  floatValue] +
                     [t floatValue] * [vel_z floatValue] +
                     [t floatValue] * [t floatValue] * 0.5 *
                     (
                      [Rnb_31 floatValue] * ([acce_measuresBuffer_x.singleOutput floatValue] - [acce_averager_x.output floatValue]) +
                      [Rnb_32 floatValue] * ([acce_measuresBuffer_y.singleOutput floatValue] - [acce_averager_y.output floatValue]) +
                      [Rnb_33 floatValue] * ([acce_measuresBuffer_z.singleOutput floatValue] - [acce_averager_z.output floatValue]) +
                      [gz floatValue]
                      )
                     ];
        }
    
        //viewController.labelPosZ.text = [NSString stringWithFormat:@"%.2f", [pos_z floatValue]];
    
        // Vt+1 = Vt + t * ( Rnb_t (measures - bias) + g )
    
        if (!acce_threshold_x.enabling) {
            vel_x = [NSNumber numberWithFloat:
                     [vel_x floatValue] +
                     [t floatValue] *
                     (
                      [Rnb_11 floatValue] * ([acce_measuresBuffer_x.singleOutput floatValue] - [acce_averager_x.output floatValue]) +
                      [Rnb_12 floatValue] * ([acce_measuresBuffer_y.singleOutput floatValue] - [acce_averager_y.output floatValue]) +
                      [Rnb_13 floatValue] * ([acce_measuresBuffer_z.singleOutput floatValue] - [acce_averager_z.output floatValue]) +
                      [gx floatValue]
                      )
                     ];
        }
    
        if (!acce_threshold_y.enabling) {
            vel_y = [NSNumber numberWithFloat:
                     [vel_y floatValue] +
                     [t floatValue] *
                     (
                      [Rnb_21 floatValue] * ([acce_measuresBuffer_x.singleOutput floatValue] - [acce_averager_x.output floatValue]) +
                      [Rnb_22 floatValue] * ([acce_measuresBuffer_y.singleOutput floatValue] - [acce_averager_y.output floatValue]) +
                      [Rnb_23 floatValue] * ([acce_measuresBuffer_z.singleOutput floatValue] - [acce_averager_z.output floatValue]) +
                      [gy floatValue]
                      )
                     ];
        }
    
        if (!acce_threshold_z.enabling) {
            vel_z = [NSNumber numberWithFloat:
                     [vel_z floatValue] +
                     [t floatValue] *
                     (
                      [Rnb_31 floatValue] * ([acce_measuresBuffer_x.singleOutput floatValue] - [acce_averager_x.output floatValue]) +
                      [Rnb_32 floatValue] * ([acce_measuresBuffer_y.singleOutput floatValue] - [acce_averager_y.output floatValue]) +
                      [Rnb_33 floatValue] * ([acce_measuresBuffer_z.singleOutput floatValue] - [acce_averager_z.output floatValue]) +
                      [gz floatValue]
                      )
                     ];
        }
        
        // Rotation matrix; the rotation matrix of this samplig t is composed with the saved matrix
        /*
         ax_ave = ax_ave_t * cos(gyt) * cos(gpt) + ay_ave_t * (cos(gyt) * sin(gpt) * sin(grt) - sin(gyt) * cos(grt)) + az_ave_t * (cos(gyt) * sin(gpt) * cos(grt) + sin(gyt) * sin(grt));
         ay_ave = ax_ave_t * sin(gyt) * cos(gpt) + ay_ave_t * (sin(gyt) * sin(gpt) * sin(grt) + cos(gyt) * cos(grt)) + az_ave_t * (sin(gyt) * sin(gpt) * cos(grt) - cos(gyt) * sin(grt));
         az_ave = ax_ave_t * -sin(gpt) + ay_ave_t * cos(gpt) * sin(grt) + az_ave_t * cos(gpt) * cos(grt);
         
         
         ax_ave = ax_ave_t * (cos(gyt) * cos(gpt) * cos(grt) - sin(gyt) * sin(grt)) + ay_ave_t * (-cos(grt) * sin(gyt) - cos(gyt) * cos(gpt) * sin(grt)) + az_ave_t * (cos(gyt) * sin(gpt));
         ay_ave = ax_ave_t * (cos(gyt) * sin(grt) + cos(gpt) * cos(grt) * sin(gyt)) + ay_ave_t * (cos(gyt) * cos(grt) - cos(gpt) * sin(gyt) * sin(grt)) + az_ave_t * (sin(gyt) * sin(gpt));
         az_ave = ax_ave_t * (-cos(grt) * sin(gpt)) + ay_ave_t * (sin(gpt) * sin (grt)) + az_ave_t * (cos(gpt));
         
         cos([t floatValue] * [gyro_angularSpeed_y floatValue]) * cos([t floatValue] * [gyro_angularSpeed_z floatValue])
         cos([t floatValue] * [gyro_angularSpeed_y floatValue]) * sin([t floatValue] * [gyro_angularSpeed_z floatValue])
         -sin([t floatValue] * [gyro_angularSpeed_y floatValue])
         
         sin([t floatValue] * [gyro_angularSpeed_x floatValue]) * sin([t floatValue] * [gyro_angularSpeed_y floatValue]) * cos([t floatValue] * [gyro_angularSpeed_z floatValue]) - cos([t floatValue] * [gyro_angularSpeed_x floatValue]) * sin([t floatValue] * [gyro_angularSpeed_z floatValue])
         sin([t floatValue] * [gyro_angularSpeed_x floatValue]) * sin([t floatValue] * [gyro_angularSpeed_y floatValue]) * sin([t floatValue] * [gyro_angularSpeed_z floatValue]) + cos([t floatValue] * [gyro_angularSpeed_x floatValue]) * cos([t floatValue] * [gyro_angularSpeed_z floatValue])
         sin([t floatValue] * [gyro_angularSpeed_x floatValue]) * cos([t floatValue] * [gyro_angularSpeed_y floatValue])
         
         cos([t floatValue] * [gyro_angularSpeed_x floatValue]) * sin([t floatValue] * [gyro_angularSpeed_y floatValue]) * cos([t floatValue] * [gyro_angularSpeed_z floatValue]) + sin([t floatValue] * [gyro_angularSpeed_x floatValue]) * sin([t floatValue] * [gyro_angularSpeed_z floatValue])
         cos([t floatValue] * [gyro_angularSpeed_x floatValue]) * sin([t floatValue] * [gyro_angularSpeed_y floatValue]) * sin([t floatValue] * [gyro_angularSpeed_z floatValue]) - sin([t floatValue] * [gyro_angularSpeed_x floatValue]) * cos([t floatValue] * [gyro_angularSpeed_z floatValue])
         cos([t floatValue] * [gyro_angularSpeed_x floatValue]) * cos([t floatValue] * [gyro_angularSpeed_y floatValue])
         
         */
        if (!gyro_threshold_x.enabling || !gyro_threshold_y.enabling || !gyro_threshold_z.enabling) {
            NSNumber * Rnb_11_i = [NSNumber numberWithFloat:
                                   cos([t floatValue] * [gyro_angularSpeed_y floatValue]) *
                                   cos([t floatValue] * [gyro_angularSpeed_z floatValue])
                                   ];
            NSNumber * Rnb_12_i = [NSNumber numberWithFloat:
                                   cos([t floatValue] * [gyro_angularSpeed_y floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_z floatValue])
                                   ];
            NSNumber * Rnb_13_i = [NSNumber numberWithFloat:
                                   -sin([t floatValue] * [gyro_angularSpeed_y floatValue])
                                   ];
            
            NSNumber * Rnb_21_i = [NSNumber numberWithFloat:
                                   sin([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_y floatValue]) *
                                   cos([t floatValue] * [gyro_angularSpeed_z floatValue]) -
                                   cos([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_z floatValue])
                                   ];
            NSNumber * Rnb_22_i = [NSNumber numberWithFloat:
                                   sin([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_y floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_z floatValue]) +
                                   cos([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   cos([t floatValue] * [gyro_angularSpeed_z floatValue])
                                   ];
            NSNumber * Rnb_23_i = [NSNumber numberWithFloat:
                                   sin([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   cos([t floatValue] * [gyro_angularSpeed_y floatValue])
                                   ];
            
            NSNumber * Rnb_31_i = [NSNumber numberWithFloat:
                                   cos([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_y floatValue]) *
                                   cos([t floatValue] * [gyro_angularSpeed_z floatValue]) +
                                   sin([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_z floatValue])
                                   ];
            NSNumber * Rnb_32_i = [NSNumber numberWithFloat:
                                   cos([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_y floatValue]) *
                                   sin([t floatValue] * [gyro_angularSpeed_z floatValue]) -
                                   sin([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   cos([t floatValue] * [gyro_angularSpeed_z floatValue])
                                   ];
            NSNumber * Rnb_33_i = [NSNumber numberWithFloat:
                                   cos([t floatValue] * [gyro_angularSpeed_x floatValue]) *
                                   cos([t floatValue] * [gyro_angularSpeed_y floatValue])
                                   ];
            
            NSNumber * Rnb_11_new = [NSNumber numberWithFloat:
                                     [Rnb_11 floatValue] * [Rnb_11_i floatValue] +
                                     [Rnb_12 floatValue] * [Rnb_21_i floatValue] +
                                     [Rnb_13 floatValue] * [Rnb_31_i floatValue]
                                     ];
            NSNumber * Rnb_12_new = [NSNumber numberWithFloat:
                                     [Rnb_11 floatValue] * [Rnb_12_i floatValue] +
                                     [Rnb_12 floatValue] * [Rnb_22_i floatValue] +
                                     [Rnb_13 floatValue] * [Rnb_32_i floatValue]
                                     ];
            NSNumber * Rnb_13_new = [NSNumber numberWithFloat:
                                     [Rnb_11 floatValue] * [Rnb_13_i floatValue] +
                                     [Rnb_12 floatValue] * [Rnb_23_i floatValue] +
                                     [Rnb_13 floatValue] * [Rnb_33_i floatValue]
                                     ];
            
            NSNumber * Rnb_21_new = [NSNumber numberWithFloat:
                                     [Rnb_21 floatValue] * [Rnb_11_i floatValue] +
                                     [Rnb_22 floatValue] * [Rnb_21_i floatValue] +
                                     [Rnb_23 floatValue] * [Rnb_31_i floatValue]
                                     ];
            NSNumber * Rnb_22_new = [NSNumber numberWithFloat:
                                     [Rnb_21 floatValue] * [Rnb_12_i floatValue] +
                                     [Rnb_22 floatValue] * [Rnb_22_i floatValue] +
                                     [Rnb_23 floatValue] * [Rnb_32_i floatValue]
                                     ];
            NSNumber * Rnb_23_new = [NSNumber numberWithFloat:
                                     [Rnb_21 floatValue] * [Rnb_13_i floatValue] +
                                     [Rnb_22 floatValue] * [Rnb_23_i floatValue] +
                                     [Rnb_23 floatValue] * [Rnb_33_i floatValue]
                                     ];
            
            NSNumber * Rnb_31_new = [NSNumber numberWithFloat:
                                     [Rnb_31 floatValue] * [Rnb_11_i floatValue] +
                                     [Rnb_32 floatValue] * [Rnb_21_i floatValue] +
                                     [Rnb_33 floatValue] * [Rnb_31_i floatValue]
                                     ];
            NSNumber * Rnb_32_new = [NSNumber numberWithFloat:
                                     [Rnb_31 floatValue] * [Rnb_12_i floatValue] +
                                     [Rnb_32 floatValue] * [Rnb_22_i floatValue] +
                                     [Rnb_33 floatValue] * [Rnb_32_i floatValue]
                                     ];
            NSNumber * Rnb_33_new = [NSNumber numberWithFloat:
                                     [Rnb_31 floatValue] * [Rnb_13_i floatValue] +
                                     [Rnb_32 floatValue] * [Rnb_23_i floatValue] +
                                     [Rnb_33 floatValue] * [Rnb_33_i floatValue]
                                     ];
            
            Rnb_11 = [NSNumber numberWithFloat:[Rnb_11_new floatValue]];
            Rnb_12 = [NSNumber numberWithFloat:[Rnb_12_new floatValue]];
            Rnb_13 = [NSNumber numberWithFloat:[Rnb_13_new floatValue]];
            
            Rnb_21 = [NSNumber numberWithFloat:[Rnb_21_new floatValue]];
            Rnb_22 = [NSNumber numberWithFloat:[Rnb_22_new floatValue]];
            Rnb_23 = [NSNumber numberWithFloat:[Rnb_23_new floatValue]];
            
            Rnb_31 = [NSNumber numberWithFloat:[Rnb_31_new floatValue]];
            Rnb_32 = [NSNumber numberWithFloat:[Rnb_32_new floatValue]];
            Rnb_33 = [NSNumber numberWithFloat:[Rnb_33_new floatValue]];
            
            attitude_x = [NSNumber numberWithFloat:
                          [attitude_x floatValue] + [t floatValue] * [gyro_angularSpeed_x floatValue]
                          ]; // Pitch
            attitude_y = [NSNumber numberWithFloat:
                          [attitude_y floatValue] + [t floatValue] * [gyro_angularSpeed_y floatValue]
                          ]; // Roll
            attitude_z = [NSNumber numberWithFloat:
                          [attitude_z floatValue] + [t floatValue] * [gyro_angularSpeed_z floatValue]
                          ]; // Yaw
        }
        
        //viewController.labelDegP.text = [NSString stringWithFormat:@"%.2f", [attitude_x floatValue] * 180.0 / M_PI];
        //viewController.labelDegR.text = [NSString stringWithFormat:@"%.2f", [attitude_y floatValue] * 180.0 / M_PI];
        //viewController.labelDegY.text = [NSString stringWithFormat:@"%.2f", [attitude_z floatValue] * 180.0 / M_PI];
    }
    
    /*
    NSLog(@"--pos_x: %.2f", [pos_x floatValue]);
    NSLog(@"pos_y: %.2f", [pos_y floatValue]);
    NSLog(@"pos_z: %.2f", [pos_z floatValue]);
    
    NSLog(@"vel_x: %.2f", [vel_x floatValue]);
    NSLog(@"vel_y: %.2f", [vel_y floatValue]);
    NSLog(@"vel_z: %.2f", [vel_z floatValue]);
    
    NSLog(@"Rnb_11: %.2f", [Rnb_11 floatValue]);
    NSLog(@"Rnb_12: %.2f", [Rnb_12 floatValue]);
    NSLog(@"Rnb_13: %.2f", [Rnb_13 floatValue]);
    NSLog(@"Rnb_21: %.2f", [Rnb_21 floatValue]);
    NSLog(@"Rnb_22: %.2f", [Rnb_22 floatValue]);
    NSLog(@"Rnb_23: %.2f", [Rnb_23 floatValue]);
    NSLog(@"Rnb_31: %.2f", [Rnb_31 floatValue]);
    NSLog(@"Rnb_32: %.2f", [Rnb_32 floatValue]);
    NSLog(@"Rnb_33: %.2f", [Rnb_33 floatValue]);
    
    NSLog(@"attitude_x: %.2f", [attitude_x floatValue]);
    NSLog(@"attitude_y: %.2f", [attitude_y floatValue]);
    NSLog(@"attitude_z: %.2f", [attitude_z floatValue]);
    */
}

#pragma mark - Notification event handles

/*!
 @method startTraveling
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
- (void) startTraveling:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"startTraveling"]){
        NSLog(@"[NOTI][MM] Notfication \"startTraveling\" recived.");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getPosition"
                                                            object:nil];
        NSLog(@"[NOTI][MM] Notification \"getPosition\" posted.");
    }
}
/*!
 @method stopTraveling
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
- (void) stopTraveling:(NSNotification *) notification  {
    if ([[notification name] isEqualToString:@"stopTraveling"]){
        NSLog(@"[NOTI][MM] Notfication \"stopTraveling\" recived.");
        traveling = NO;
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        // Create a copy of the current position for sending it; concurrence issues prevented
        RDPosition * newPosition = [[RDPosition alloc] init];
        newPosition.x = [NSNumber numberWithFloat:[position.x floatValue]];
        newPosition.y = [NSNumber numberWithFloat:[position.y floatValue]];
        newPosition.z = [NSNumber numberWithFloat:[position.z floatValue]];
        [data setObject:newPosition forKey:@"currentPosition"];
        // And send the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setPosition"
                                                            object:nil
                                                          userInfo:data];
        NSLog(@"[NOTI][MM] Notification \"setPosition\" posted.");
    }
}

/*!
 @method startTravelingFrom
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
- (void) startTravelingFrom:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"getPositionRespond"]){
        NSLog(@"[NOTI][MM] Notfication \"getPositionRespond\" recived.");
        
        NSDictionary * data = notification.userInfo;
        RDPosition * initialPosition = data[@"currentPosition"];
        
        traveling = YES;
        float low_bound = -1.00;
        float high_bound = 1.00;
        float rndValue1 = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
        float rndValue2 = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
        position.x = [NSNumber numberWithFloat:[initialPosition.x floatValue] + rndValue1];
        position.y = [NSNumber numberWithFloat:[initialPosition.y floatValue] + rndValue2];
        position.z = [NSNumber numberWithFloat:[initialPosition.z floatValue]];
    }
}

@end
