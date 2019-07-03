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
 @discussion Constructor.
 */
- (instancetype)initWithViewController:(ViewController *) viewControllerFromStateMachine
                         andSharedData:(SharedData *)initSharedData
{
self = [super init];
if (self) {
    // Components
    viewController = viewControllerFromStateMachine;
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
    
    // Orchestration variables
    traveling = NO;
    position = [[RDPosition alloc] init];
    }
    return self;
}

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
        if (self.timer == nil){
        // Configure a timer to fetch the data.
            self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:([t doubleValue])
                                                    target:self
                                                  selector:@selector(process)
                                                  userInfo:nil
                                                   repeats:YES];
        
            // Add the timer to the current run loop.
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
    } else {
        NSLog(@"[ERROR][MM] Accelerometer not avalible");
    }
    NSLog(@"[INFO][MM] Accelerometer started");
}

/*!
 @method stopAccelerometers
 @discussion This method manages how the accelerometer status acquisition stops and its error's control.
 */
- (void) stopAccelerometers {
    [self.timer invalidate];
    self.timer = nil;
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
        
        if (self.timer == nil){
            // Configure a timer to fetch the data.
            self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:([t doubleValue])
                                                    target:self
                                                  selector:@selector(process)
                                                  userInfo:nil
                                                   repeats:YES];
            
            // Add the timer to the current run loop.
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
    } else {
        NSLog(@"[ERROR][MM] Gyroscope not avalible");
    }
    NSLog(@"[INFO][MM] Gyroscope started");
}

/*!
 @method stopGyroscopes
 @discussion This method manages how the gyroscope status acquisition stops and its error's control.
 */
- (void) stopGyroscopes {
    [self.timer invalidate];
    self.timer = nil;
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
    
    /*
    viewController.labelAX.text = [NSString stringWithFormat:@"%.2f", ax0 - ax_ave];
    viewController.labelGX.text = [NSString stringWithFormat:@"%.2f", gp0 - gp_ave];
    viewController.labelCalibrated.text = @"Calibrated";
    NSLog(@"[INFO][MM] Calibrated.");
    viewController.labelGX.text = [NSString stringWithFormat:@"%.2f", gp];
    viewController.labelDegP.text = [NSString stringWithFormat:@"%.2f", dp * 180 / M_PI];
    viewController.labelPosX.text = [NSString stringWithFormat:@"%.2f", rx];
    */
    
    /*
    ax_ave = ax_ave_t * cos(gyt) * cos(gpt) + ay_ave_t * (cos(gyt) * sin(gpt) * sin(grt) - sin(gyt) * cos(grt)) + az_ave_t * (cos(gyt) * sin(gpt) * cos(grt) + sin(gyt) * sin(grt));
    ay_ave = ax_ave_t * sin(gyt) * cos(gpt) + ay_ave_t * (sin(gyt) * sin(gpt) * sin(grt) + cos(gyt) * cos(grt)) + az_ave_t * (sin(gyt) * sin(gpt) * cos(grt) - cos(gyt) * sin(grt));
    az_ave = ax_ave_t * -sin(gpt) + ay_ave_t * cos(gpt) * sin(grt) + az_ave_t * cos(gpt) * cos(grt);
    
    
    ax_ave = ax_ave_t * (cos(gyt) * cos(gpt) * cos(grt) - sin(gyt) * sin(grt)) + ay_ave_t * (-cos(grt) * sin(gyt) - cos(gyt) * cos(gpt) * sin(grt)) + az_ave_t * (cos(gyt) * sin(gpt));
    ay_ave = ax_ave_t * (cos(gyt) * sin(grt) + cos(gpt) * cos(grt) * sin(gyt)) + ay_ave_t * (cos(gyt) * cos(grt) - cos(gpt) * sin(gyt) * sin(grt)) + az_ave_t * (sin(gyt) * sin(gpt));
    az_ave = ax_ave_t * (-cos(grt) * sin(gpt)) + ay_ave_t * (sin(gpt) * sin (grt)) + az_ave_t * (cos(gpt));
    */
    
    // TO DO. Rotation matrix
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
                [acce_averager_x executeWithInput:acce_biasBuffer_x.arrayOutput];
                
                if ([acce_averager_x isOutput]) {
                    acce_bias_x = [NSNumber numberWithFloat:[acce_averager_x.output floatValue]];
                    acce_biasBuffer_x.disabledInput = [NSNumber numberWithFloat:[acce_averager_x.output floatValue]];
                    viewController.labelAX.text = [NSString stringWithFormat:@"%.3f", [acce_mea_x floatValue]];
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
                    viewController.labelAY.text = [NSString stringWithFormat:@"%.3f", [acce_mea_y floatValue]];
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
                    viewController.labelAZ.text = [NSString stringWithFormat:@"%.3f", [acce_mea_z floatValue]];
                    
                }
            }
        }
    }
    
    
    // Fourth channel: gyroscope in x axis
    gyro_mea_x = [NSNumber numberWithFloat:self.gyroData.rotationRate.x];
    
    [gyro_threshold_x executeWithInput:gyro_mea_x];
    NSLog(@"[INFO][MM] -- gyro_mea_x: %.3f", [gyro_mea_x floatValue]);
    
    [gyro_measuresBuffer_x executeWithInput:gyro_mea_x];
    
    NSLog([gyro_threshold_x isOutput] ? @"[INFO][MM]  [gyro_threshold_x isOutput] is YES" :
          @"[INFO][MM]  [gyro_threshold_x isOutput] is NO");
    if([gyro_threshold_x isOutput]) {
        NSLog(@"[INFO][MM]  [gyro_threshold_x.output floatValue]: %.3f",  [gyro_threshold_x.output floatValue]);
        NSLog(gyro_threshold_x.enabling ? @"[INFO][MM]  gyro_threshold_x.enabling is YES" :
              @"[INFO][MM]  gyro_threshold_x.enablingis NO");
        [gyro_biasBuffer_x executeWithInput:gyro_threshold_x.output
                                andEnabling:gyro_threshold_x.enabling];
        
        NSLog([gyro_biasBuffer_x isOutput] ? @"[INFO][MM]  [gyro_biasBuffer_x isOutput] is YES" :
              @"[INFO][MM]  [gyro_biasBuffer_x isOutput] is NO");
        if ([gyro_biasBuffer_x isOutput]) {
            [gyro_averager_x executeWithInput:gyro_biasBuffer_x.arrayOutput];
            
            NSLog([gyro_averager_x isOutput] ? @"[INFO][MM]  [gyro_averager_x isOutput] is YES" :
                  @"[INFO][MM]  [gyro_averager_x isOutput] is NO");
            if ([gyro_averager_x isOutput]) {
                NSLog(@"[INFO][MM]  [gyro_averager_x.output floatValue]: %.3f",  [gyro_averager_x.output floatValue]);
                gyro_bias_x = [NSNumber numberWithFloat:[gyro_averager_x.output floatValue]];
                gyro_biasBuffer_x.disabledInput = [NSNumber numberWithFloat:[gyro_averager_x.output floatValue]];
                
                NSLog(@"[INFO][MM]  [gyro_measuresBuffer_x.singleOutput floatValue]: %.3f",  [gyro_measuresBuffer_x.singleOutput floatValue]);
                [gyro_biasAdder_x executeWithInput1:gyro_measuresBuffer_x.singleOutput
                                          andInput2:[NSNumber numberWithFloat:-[gyro_bias_x floatValue]]];
                
                NSLog([gyro_biasAdder_x isOutput] ? @"[INFO][MM]  [gyro_biasAdder_x isOutput] is YES" :
                      @"[INFO][MM]  [gyro_biasAdder_x isOutput] is NO");
                if ([gyro_biasAdder_x isOutput]) {
                    gyro_angularSpeed_x = [NSNumber numberWithFloat:[gyro_biasAdder_x.output floatValue]];
                    viewController.labelGX.text = [NSString stringWithFormat:@"%.3f", [gyro_mea_x floatValue]];
                    viewController.labelDegP.text = [NSString stringWithFormat:@"%.3f", [gyro_angularSpeed_x floatValue]];
                    
                    NSLog(@"[INFO][MM] [gyro_angularSpeed_x floatValue]: %.3f", [gyro_angularSpeed_x floatValue]);
                    NSLog(@"[INFO][MM] [gyro_mea_x floatValue]: %.3f",  [gyro_mea_x floatValue]);
                }
            }
        }
    }
    
    
}

/*!
 @method startTravelingFrom
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
- (void) startTravelingFrom:(RDPosition*)initialPosition {
    NSLog(@"[INFO][MM] Starting traveling from position: %@", initialPosition);
    traveling = YES;
    float low_bound = -1.00;
    float high_bound = 1.00;
    float rndValue1 = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
    float rndValue2 = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
    position.x = [NSNumber numberWithFloat:[initialPosition.x floatValue] + rndValue1];
    position.y = [NSNumber numberWithFloat:[initialPosition.y floatValue] + rndValue2];
    position.z = [NSNumber numberWithFloat:[initialPosition.z floatValue]];
    
    // Notify the event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needEvaluateState"
                                                        object:nil];
}

/*!
 @method simulateTraveling
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
- (void) stopTraveling {
    NSLog(@"[INFO][MM] Stopping traveling");
    traveling = NO;
    
    // Notify the event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needEvaluateState"
                                                        object:nil];
}

/*!
 @method simulateTraveling
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
- (RDPosition *) getFinalPosition {
    RDPosition * newPosition = [[RDPosition alloc] init];
    newPosition.x = [NSNumber numberWithFloat:[position.x floatValue]];
    newPosition.y = [NSNumber numberWithFloat:[position.y floatValue]];
    newPosition.z = [NSNumber numberWithFloat:[position.z floatValue]];
    NSLog(@"[INFO][MM] The travel finished at position: %@", newPosition);
    
    // Notify the event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needEvaluateState"
                                                        object:nil];
    return newPosition;
}

@end
