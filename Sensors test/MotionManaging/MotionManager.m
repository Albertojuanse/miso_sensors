//
//  MotionManager.m
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "MotionManager.h"

@implementation MotionManager

/*!
 @method initWithSharedData:
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
        
        // Measuring variables
        calibration_counter = 0;
        calibrationSteps = 100;
        precision_threshold = [[NSNumber alloc] initWithFloat:0.01];
        measured_gyroscope_x = [[NSNumber alloc] initWithFloat:0.0];
        measured_gyroscope_y = [[NSNumber alloc] initWithFloat:0.0];
        measured_gyroscope_z = [[NSNumber alloc] initWithFloat:0.0];
        d_gy_p = 0.0;
        d_gy_r = 0.0;
        d_gy_y = 0.0;
        gy_p0 = 0.0;
        gy_p_ave = 0.0;
        gy_p_ave_sum = 0.0;
        gy_p = 0.0;
        gy_r0 = 0.0;
        gy_r_ave = 0.0;
        gy_r_ave_sum = 0.0;
        gy_r = 0.0;
        gy_y0 = 0.0;
        gy_y_ave = 0.0;
        gy_y_ave_sum = 0.0;
        gy_y = 0.0;
        
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
                                                 selector:@selector(startGyroscopeHeadingMeasuring:)
                                                     name:@"startGyroscopeHeadingMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopGyroscopeHeadingMeasuring:)
                                                     name:@"stopGyroscopeHeadingMeasuring"
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
        
        NSLog(@"[INFO][MM] MotionManager prepared.");
        }
    return self;
}

/*!
 @method initWithSharedData:userDic:rhoRhoSystem:rhoThetaSystem:thetaThetaSystem:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the location systems and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                      rhoRhoSystem:(RDRhoRhoSystem *)initRhoRhoSystem
                    rhoThetaSystem:(RDRhoThetaSystem *)initRhoThetaSystem
                  thetaThetaSystem:(RDThetaThetaSystem *)initThetaThetaSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [self initWithSharedData:initSharedData];
    if (self) {
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        rhoRhoSystem = initRhoRhoSystem;
        rhoThetaSystem = initRhoThetaSystem;
        thetaThetaSystem = initThetaThetaSystem;
    }
    return self;
}

/*!
 @method initWithSharedData:userDic:thetaThetaSystem:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the location systems and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                  thetaThetaSystem:(RDThetaThetaSystem *)initThetaThetaSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [self initWithSharedData:initSharedData];
    if (self) {
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        thetaThetaSystem = initThetaThetaSystem;
    }
    return self;
}

/*!
@method initWithSharedData:userDic:rhoThetaSystem:andCredentialsUserDic:
@discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the location systems and the credentials of the user for access it.
*/
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                    rhoThetaSystem:(RDRhoThetaSystem *)initRhoThetaSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [self initWithSharedData:initSharedData];
    if (self) {
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        rhoThetaSystem = initRhoThetaSystem;
    }
    return self;
}

#pragma mark - Instance methods
/*!
 @method setCredentialUserDic:
 @discussion This method sets the dictionary with the user's credentials for access the collections in shared data database.
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

#pragma mark - Location manager methods

/*!
 @method startAccelerometers
 @discussion This method manages how the accelerometer status acquisition starts and its error's control.
 */
- (void) startAccelerometers
{
    
    NSLog(@"[INFO][MM] Notification \"startAccelerometers\" recived.");
    // Make sure the accelerometer hardware is available.
    if (self.isAccelerometerAvailable) {
        NSLog(@"[INFO][MM] Accelerometer available.");
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
        NSLog(@"[ERROR][MM] Accelerometer not available.");
    }
    NSLog(@"[INFO][MM] Accelerometer started.");
}

/*!
 @method stopAccelerometers
 @discussion This method manages how the accelerometer status acquisition stops.
 */
- (void) stopAccelerometers
{
    NSLog(@"[INFO][MM] Notification \"stopAccelerometers\" recived.");
    [self.tr invalidate];
    self.tr = nil;
    [self stopAccelerometerUpdates];
    NSLog(@"[INFO][MM] Accelerometer stopped.");
}

/*!
 @method startGyroscopes
 @discussion This method manages how the gyroscope status acquisition starts and its error's control.
 */
- (void) startGyroscopes
{
    NSLog(@"[INFO][MM] Notification \"startGyroscopes\" recived.");
    // Make sure the gyroscope hardware is available.
    if (self.isGyroAvailable) {
        NSLog(@"[INFO][MM] Gyroscope available.");
        self.gyroUpdateInterval = [t doubleValue];
        [self startGyroUpdates];
        
        if (self.tr == nil){
            // Configure a tr to fetch the data.
            self.tr = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:([t doubleValue])
                                                    target:self
                                                  selector:@selector(proccesHeadingMeasure)
                                                  userInfo:nil
                                                   repeats:YES];
            
            // Add the tr to the current run loop.
            [[NSRunLoop currentRunLoop] addTimer:self.tr forMode:NSDefaultRunLoopMode];
        }
    } else {
        NSLog(@"[ERROR][MM] Gyroscope not available.");
    }
    NSLog(@"[INFO][MM] Gyroscope started.");
}

/*!
 @method stopGyroscopes
 @discussion This method manages how the gyroscope status acquisition stops.
 */
- (void) stopGyroscopes
{
    NSLog(@"[INFO][MM] Notification \"stopGyroscopes\" recived.");
    [self.tr invalidate];
    self.tr = nil;
    [self stopGyroUpdates];
    NSLog(@"[INFO] Gyroscope stopped.");
}

/*!
 @method proccesHeadingMeasure
 @discussion This method procces the acquisited data for measuring porpuses.
 */
- (void) proccesHeadingMeasure
{
    if (calibration_counter < calibrationSteps) {
        
        // Starts at zero; is needed to increase the counter here.
        calibration_counter++;
        
        // Gyroscope calibration
        gy_p0 = self.gyroData.rotationRate.x;
        gy_p_ave_sum += gy_p0;
        gy_p_ave = gy_p_ave_sum / calibration_counter;
        
        gy_r0 = self.gyroData.rotationRate.y;
        gy_r_ave_sum += gy_r0;
        gy_r_ave = gy_r_ave_sum / calibration_counter;
        
        gy_y0 = self.gyroData.rotationRate.z;
        gy_y_ave_sum += gy_y0;
        gy_y_ave = gy_y_ave_sum / calibration_counter;
        
    } else if (calibration_counter == calibrationSteps) {
        NSLog(@"[INFO][MM] Gyroscope calibrated.");
        calibration_counter++;
    } else if (calibration_counter > calibrationSteps) {
        calibration_counter++;
        
        // Gyroscope acquisition
        gy_p = self.gyroData.rotationRate.x - gy_p_ave;
        gy_r = self.gyroData.rotationRate.y - gy_r_ave;
        gy_y = self.gyroData.rotationRate.z - gy_y_ave;
        
        // Attitude
        if (gy_p > [precision_threshold floatValue]) {
            d_gy_p = d_gy_p + gy_p * [t floatValue];
            // NSLog(@"[INFO][MM] Pith %.2f", d_gy_p);
        }
        if (gy_p < -[precision_threshold floatValue]) {
            d_gy_p = d_gy_p + gy_p * [t floatValue];
            // NSLog(@"[INFO][MM] Pith %.2f", d_gy_p);
        }
        if (gy_r > [precision_threshold floatValue]) {
            d_gy_r = d_gy_r + gy_r * [t floatValue];
            // NSLog(@"[INFO][MM] Roll %.2f", d_gy_r);
        }
        if (gy_r < -[precision_threshold floatValue]) {
            d_gy_r = d_gy_r + gy_r * [t floatValue];
            // NSLog(@"[INFO][MM] Roll %.2f", d_gy_r);
        }
        if (gy_y > [precision_threshold floatValue]) {
            d_gy_y = d_gy_y + gy_y * [t floatValue];
            // NSLog(@"[INFO][MM] Yaw %.2f", d_gy_y);
        }
        if (gy_y < -[precision_threshold floatValue]) {
            d_gy_y = d_gy_y + gy_y * [t floatValue];
            // NSLog(@"[INFO][MM] Yaw %.2f", d_gy_y);
        }
        
        measured_gyroscope_x = [NSNumber numberWithFloat:d_gy_p];
        measured_gyroscope_y = [NSNumber numberWithFloat:d_gy_r];
        measured_gyroscope_z = [NSNumber numberWithFloat:d_gy_y];
        
    }
        
}

/*!
 @method procces
 @discussion This method procces the acquisited data.
 */
- (void) process
{
    // NSLog(@"; \"x\": %f, \"y\": %f, \"z\": %f, \"type\": \"gyroscope\"} {\"date\":", self.gyroData.rotationRate.x, self.gyroData.rotationRate.y, self.gyroData.rotationRate.y);
    // NSLog(@"; \"x\": %f, \"y\": %f, \"z\": %f, \"type\": \"accelerometer\"} {\"date\":", self.accelerometerData.acceleration.x, self.accelerometerData.acceleration.y, self.accelerometerData.acceleration.z);
    
    NSNumber * gravity_rotated_x = [NSNumber numberWithFloat:[gx floatValue]];
    NSNumber * gravity_rotated_y = [NSNumber numberWithFloat:[gy floatValue]];
    NSNumber * gravity_rotated_z = [NSNumber numberWithFloat:[gz floatValue]];
    
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
 @method startGyroscopeHeadingMeasuring
 @discussion This method saves the current gyrosope as an initial state for measuring.
 */
- (void) startGyroscopeHeadingMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"startGyroscopeHeadingMeasuring"]){
        NSLog(@"[NOTI][MM] Notification \"startGyroscopeHeadingMeasuring\" recived.");
        
        // TODO: Motion depending on the mode. Alberto J. 2020/07/07.
        /*
        // Get class variables to get the item's position facet from the item chosen by user to measure (locating mode)
        NSMutableDictionary * itemChosenByUserDic = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
        itemToMeasureUUID = itemChosenByUserDic[@"uuid"];
        if (itemChosenByUserDic[@"position"]) {
            itemToMeasurePosition = itemChosenByUserDic[@"position"];
        } else {
            NSLog(@"[ERROR][LMRTL] No position found in item to be measured.");
        }
        
        // Get class variables to get the item's position facet from the item chosen by user to be the device (locating mode)
        NSDictionary * dataDic = [notification userInfo];
        NSMutableDictionary * itemDic = dataDic[@"itemDic"];
        deviceUUID = itemDic[@"uuid"];
         */
        
        // Reset the gyroscope values
        calibration_counter = 0;
        d_gy_p = 0.0;
        d_gy_r = 0.0;
        d_gy_y = 0.0;
        gy_p0 = 0.0;
        gy_p_ave = 0.0;
        gy_p_ave_sum = 0.0;
        gy_p = 0.0;
        gy_r0 = 0.0;
        gy_r_ave = 0.0;
        gy_r_ave_sum = 0.0;
        gy_r = 0.0;
        gy_y0 = 0.0;
        gy_y_ave = 0.0;
        gy_y_ave_sum = 0.0;
        gy_y = 0.0;
        measured_gyroscope_x = [[NSNumber alloc] initWithFloat:0.0];
        measured_gyroscope_y = [[NSNumber alloc] initWithFloat:0.0];
        measured_gyroscope_z = [[NSNumber alloc] initWithFloat:0.0];
        return;
    }
}

/*!
 @method stopGyroscopetMeasuring
 @discussion This method compares the saved state of the gyroscope for generate a measure.
 */
- (void) stopGyroscopeHeadingMeasuring:(NSNotification *) notification {
    
    
    if ([[notification name] isEqualToString:@"stopGyroscopeHeadingMeasuring"]){
        
        NSLog(@"[NOTI][MM] Notification \"stopGyroscopeHeadingMeasuring\" recived.");
        
        // First, validate the access to the data shared collection
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            
        } else {
            /*
             [self alertUserWithTitle:@"Beacon ranged won't be procesed."
             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
             andHandler:^(UIAlertAction * action) {
             // TODO: handle intrusion situations. Alberto J. 2019/09/10.
             }
             ];
             */
            // TODO: handle intrusion situations. Alberto J. 2019/09/10.
            NSLog(@"[ERROR][VCRRM] Shared data could not be accessed while starting travel.");
            return;
        }
        
        // Different behave depending on the mode
            
        // Get the measuring mode
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        
        // If a rho type system which needs ranging
        if (
            [mode isModeKey:kModeRhoRhoModelling] ||
            [mode isModeKey:kModeRhoRhoLocating]
            )
        {
            // Do nothing
            NSLog(@"[ERROR] Gyroscope measure method called when using a rho rho type system.");
            
        }
        
        // If a rho theta type system;
        if (
            [mode isModeKey:kModeRhoThetaModelling] ||
            [mode isModeKey:kModeRhoThetaLocating]
            )
        {
            // TODO: Alberto J. 2019/10/15.
        }
        
        // If a theta theta type system; it is supposed that in this case gyroscopes are used to get the heading
        if (
            [mode isModeKey:kModeThetaThetaModelling] ||
            [mode isModeKey:kModeThetaThetaLocating]
            )
        {
            // Calculate the measure
            NSNumber * measure = [NSNumber numberWithFloat: sqrt([measured_gyroscope_x floatValue] * [measured_gyroscope_x floatValue] +
                                                                 [measured_gyroscope_y floatValue] * [measured_gyroscope_y floatValue] +
                                                                 [measured_gyroscope_z floatValue] * [measured_gyroscope_z floatValue]
                                                                 )
                                  ];
            
            // Save the measure
            // The heading measures in this mode are only saved if the user did select the item to aim to whose item dictionary is stored in session dictionary as 'itemChosenByUser'.
            NSMutableDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                                                 andCredentialsUserDic:credentialsUserDic];
            if(itemChosenByUser) {
                // If its not null retrieve the information needed.
                NSString * itemUUID = itemChosenByUser[@"uuid"];
                
                [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithFloat:[measure floatValue]]
                                              ofSort:@"heading"
                                        withItemUUID:itemUUID
                                      withDeviceUUID:deviceUUID
                                          atPosition:nil
                                      takenByUserDic:userDic
                           andWithCredentialsUserDic:credentialsUserDic];
            }
            
            [sharedData inSessionDataSetIdleUserWithUserDic:userDic andWithCredentialsUserDic:credentialsUserDic];
            
            // Ask to calculate the positions
            NSMutableDictionary * locatedPositions;
            
            // Precision is arbitrary set to 10 cm
            // TODO: Make this configurable. Alberto J. 2019/09/12.
            NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithFloat:0.1], @"xPrecision",
                                         [NSNumber numberWithFloat:0.1], @"yPrecision",
                                         [NSNumber numberWithFloat:0.1], @"zPrecision",
                                         nil];
            
            // Ask radiolocation of beacons if posible...
            locatedPositions = [thetaThetaSystem getLocationsUsingBarycenterAproximationWithPrecisions:precisions];
            // ...and save them as a located item.
            NSArray *positionKeys = [locatedPositions allKeys];
            for (id positionKey in positionKeys) {
                NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
                infoDic[@"located"] = @"YES";
                infoDic[@"sort"] = @"position";
                infoDic[@"identifier"] = [NSString
                                          stringWithFormat:@"location%@@miso.uam.es",
                                          [positionKey substringFromIndex:
                                           [positionKey length] - 4]
                                          ];
                infoDic[@"position"] = [locatedPositions objectForKey:positionKey];
                
                BOOL savedItem = [sharedData inItemDataAddItemOfSort:@"position"
                                                            withUUID:positionKey
                                                         withInfoDic:infoDic
                                           andWithCredentialsUserDic:credentialsUserDic];
                if (savedItem) {
                    
                } else {
                    NSLog(@"[ERROR][MM] Located position %@ could not be stored as an item.", infoDic[@"position"]);
                }
                
            }
            
            NSLog(@"[INFO][MM] Generated locations: %@",
                  [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                          andCredentialsUserDic:credentialsUserDic]);
            NSLog(@"[INFO][MM] Generated measures: %@",
                  [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
            
            // Ask view controller to refresh the canvas
            NSLog(@"[NOTI][MM] Notification \"canvas/refresh\" posted.");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"canvas/refresh"
             object:nil];
        }
        
        return;
    }
}

// TODO: Evaluate removing. Alberto J. 2020/07/07.
/*!
 @method startTraveling
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
/*
- (void) startTraveling:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"startTraveling"]){
        NSLog(@"[NOTI][MM] Notification \"startTraveling\" recived.");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getPosition"
                                                            object:nil];
        NSLog(@"[NOTI][MM] Notification \"getPosition\" posted.");
    }
}
*/

/*!
 @method stopTraveling
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
/*
- (void) stopTraveling:(NSNotification *) notification  {
    if ([[notification name] isEqualToString:@"stopTraveling"]){
        NSLog(@"[NOTI][MM] Notification \"stopTraveling\" recived.");
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
*/

/*!
 @method startTravelingFrom
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
/*
- (void) startTravelingFrom:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"getPositionRespond"]){
        NSLog(@"[NOTI][MM] Notification \"getPositionRespond\" recived.");
        
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
*/

@end
