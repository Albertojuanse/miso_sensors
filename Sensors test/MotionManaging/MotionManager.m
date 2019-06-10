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
{
self = [super init];
if (self) {
    // View controller
    viewController = viewControllerFromStateMachine;
    }
    return self;
}

/*!
 @method configure
 @discussion This method initializes some variables of the object and must be called when the object is created.
 */
- (void) configure {
    t = 1.0/100.0;
    g = 9.7994;
    calibrationTime = 10;
    calibrationSteps = calibrationTime * 1/t;
    calibration_counter = 0;
    precision_threshold = 0.1;
}

/*!
 @method startAccelerometers
 @discussion This method manages how the accelerometer status acquisition starts and its error's control.
 */
- (void) startAccelerometers {
    
    // Make sure the accelerometer hardware is available.
    if (self.isAccelerometerAvailable) {
        NSLog(@"[INFO][MM] Accelerometer avalible");
        self.accelerometerUpdateInterval = t;
        [self startAccelerometerUpdates];
        if (self.timer == nil){
        // Configure a timer to fetch the data.
            self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:(t) target:self selector:@selector(process) userInfo:nil repeats:YES];
        
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
        self.gyroUpdateInterval = t;
        [self startGyroUpdates];
        
        if (self.timer == nil){
            // Configure a timer to fetch the data.
            self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:(t) target:self selector:@selector(process) userInfo:nil repeats:YES];
            
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
    // NSLog(@"; x: %f ; y: %f ; z: %f } { timestamp: ", self.gyroData.rotationRate.x, self.gyroData.rotationRate.y, self.gyroData.rotationRate.y);
    // NSLog(@"; x: %f ; y: %f ; z: %f } { timestamp: ", self.accelerometerData.acceleration.x, self.accelerometerData.acceleration.y, self.accelerometerData.acceleration.z);
    
    // No valid results will be while calibration process.
    // The calibration procces calculate the average of the signals in order od subtracting them.
    if (calibration_counter < calibrationSteps) {
        
        // Starts at zero; is needed to increase the counter here.
        calibration_counter++;
        
        // Accelerometer calibration
        ax0 = self.accelerometerData.acceleration.x * g;
        ax_ave_sum += ax0;
        ax_ave = ax_ave_sum / calibration_counter;
        
        ay0 = self.accelerometerData.acceleration.y * g;
        ay_ave_sum += ay0;
        ay_ave = ay_ave_sum / calibration_counter;
        
        az0 = self.accelerometerData.acceleration.z * g;
        az_ave_sum += az0;
        az_ave = az_ave_sum / calibration_counter;
        
        // Gyroscope calibration
        gp0 = self.gyroData.rotationRate.x;
        gp_ave_sum += gp0;
        gp_ave = gp_ave_sum / calibration_counter;
        
        gr0 = self.gyroData.rotationRate.y;
        gr_ave_sum += gr0;
        gr_ave = gr_ave_sum / calibration_counter;
        
        gy0 = self.gyroData.rotationRate.z;
        gy_ave_sum += gy0;
        gy_ave = gy_ave_sum / calibration_counter;
        
        viewController.labelAX.text = [NSString stringWithFormat:@"%.2f", ax0 - ax_ave];
        viewController.labelAY.text = [NSString stringWithFormat:@"%.2f", ay0 - ay_ave];
        viewController.labelAZ.text = [NSString stringWithFormat:@"%.2f", az0 - az_ave];
        
        viewController.labelGX.text = [NSString stringWithFormat:@"%.2f", gp0 - gp_ave];
        viewController.labelGY.text = [NSString stringWithFormat:@"%.2f", gr0 - gr_ave];
        viewController.labelGZ.text = [NSString stringWithFormat:@"%.2f", gy0 - gy_ave];
    } else if (calibration_counter == calibrationSteps) {
        viewController.labelCalibrated.text = @"Calibrated";
        NSLog(@"[INFO][MM] Calibrated.");
        calibration_counter++;
    } else if (calibration_counter > calibrationSteps) {
        calibration_counter++;
        
        // Gyroscope acquisition
        gp = self.gyroData.rotationRate.x - gp_ave;
        gr = self.gyroData.rotationRate.y - gr_ave;
        gy = self.gyroData.rotationRate.z - gy_ave;
        
        viewController.labelGX.text = [NSString stringWithFormat:@"%.2f", gp];
        viewController.labelGY.text = [NSString stringWithFormat:@"%.2f", gr];
        viewController.labelGZ.text = [NSString stringWithFormat:@"%.2f", gy];
        
        // Attitude
        if (gp > (precision_threshold/10)) {
            dp = dp + gp * t;
            viewController.labelDegP.text = [NSString stringWithFormat:@"%.2f", dp * 180 / M_PI];
        }
        if (gp < -(precision_threshold/10)) {
            dp = dp + gp * t;
            viewController.labelDegP.text = [NSString stringWithFormat:@"%.2f", dp * 180 / M_PI];
        }
        if (gr > (precision_threshold/10)) {
            dr = dr + gr * t;
            viewController.labelDegR.text = [NSString stringWithFormat:@"%.2f", dr * 180 / M_PI];
        }
        if (gr < -(precision_threshold/10)) {
            dr = dr + gr * t;
            viewController.labelDegR.text = [NSString stringWithFormat:@"%.2f", dr * 180 / M_PI];
        }
        if (gy > (precision_threshold/10)) {
            dy = dy + gy * t;
            viewController.labelDegY.text = [NSString stringWithFormat:@"%.2f", dy * 180 / M_PI];
        }
        if (gy < -(precision_threshold/10)) {
            dy = dy + gy * t;
            viewController.labelDegY.text = [NSString stringWithFormat:@"%.2f", dy * 180 / M_PI];
        }
        
        // Inertial compensation; the matrix is in order: dy, dp, dr
        // http://planning.cs.uiuc.edu/node102.html
        double ax_ave_t = ax_ave;
        double ay_ave_t = ay_ave;
        double az_ave_t = az_ave;
        double gyt = gy * t;
        double gpt = gp * t;
        double grt = gr * t;
        
        ax_ave = ax_ave_t * (1 + sin(grt));
        az_ave = az_ave_t * (1 - sin(grt));
        
        /*
        ax_ave = ax_ave_t * cos(gyt) * cos(gpt) + ay_ave_t * (cos(gyt) * sin(gpt) * sin(grt) - sin(gyt) * cos(grt)) + az_ave_t * (cos(gyt) * sin(gpt) * cos(grt) + sin(gyt) * sin(grt));
        ay_ave = ax_ave_t * sin(gyt) * cos(gpt) + ay_ave_t * (sin(gyt) * sin(gpt) * sin(grt) + cos(gyt) * cos(grt)) + az_ave_t * (sin(gyt) * sin(gpt) * cos(grt) - cos(gyt) * sin(grt));
        az_ave = ax_ave_t * -sin(gpt) + ay_ave_t * cos(gpt) * sin(grt) + az_ave_t * cos(gpt) * cos(grt);
        
        
        ax_ave = ax_ave_t * (cos(gyt) * cos(gpt) * cos(grt) - sin(gyt) * sin(grt)) + ay_ave_t * (-cos(grt) * sin(gyt) - cos(gyt) * cos(gpt) * sin(grt)) + az_ave_t * (cos(gyt) * sin(gpt));
        ay_ave = ax_ave_t * (cos(gyt) * sin(grt) + cos(gpt) * cos(grt) * sin(gyt)) + ay_ave_t * (cos(gyt) * cos(grt) - cos(gpt) * sin(gyt) * sin(grt)) + az_ave_t * (sin(gyt) * sin(gpt));
        az_ave = ax_ave_t * (-cos(grt) * sin(gpt)) + ay_ave_t * (sin(gpt) * sin (grt)) + az_ave_t * (cos(gpt));
        */
        
        // Accelerometer acquisition
        ax = self.accelerometerData.acceleration.x * g - ax_ave;
        ay = self.accelerometerData.acceleration.y * g - ay_ave;
        az = self.accelerometerData.acceleration.z * g - az_ave;
        
        viewController.labelAX.text = [NSString stringWithFormat:@"%.2f", ax];
        viewController.labelAY.text = [NSString stringWithFormat:@"%.2f", ay];
        viewController.labelAZ.text = [NSString stringWithFormat:@"%.2f", az];
        
        // Position
        // If the refenrence system is the one described by Apple in documentation, the acceleration measures are negative.
        // https://developer.apple.com/documentation/coremotion/getting_raw_gyroscope_events?language=objc
        if (ax < - precision_threshold) {
            vx = vx - ax * t;
            rx = rx + (1.0/2.0) * vx * t;
            viewController.labelPosX.text = [NSString stringWithFormat:@"%.2f", rx];
        }
        if (ax > precision_threshold) {
            vx = vx - ax * t;
            rx = rx + (1.0/2.0) * vx * t;
            viewController.labelPosX.text = [NSString stringWithFormat:@"%.2f", rx];
        }
        
        if (ay < - precision_threshold) {
            vy = vy - ay * t;
            ry = ry + (1.0/2.0) * vy * t;
            viewController.labelPosY.text = [NSString stringWithFormat:@"%.2f", ry];
        }
        if (ay > precision_threshold) {
            vy = vy - ay * t;
            ry = ry + (1.0/2.0) * vy * t;
            viewController.labelPosY.text = [NSString stringWithFormat:@"%.2f", ry];
        }
        
        if (az < -precision_threshold) {
            vz = vz - az * t;
            rz = rz + (1.0/2.0) * vz * t;
            viewController.labelPosZ.text = [NSString stringWithFormat:@"%.2f", rz];
        }
        if (az > precision_threshold) {
            vz = vz - az * t;
            rz = rz + (1.0/2.0) * vz * t;
            viewController.labelPosZ.text = [NSString stringWithFormat:@"%.2f", rz];
        }
    }
}

/*!
 @method simulateTraveling
 @discussion This method simulate a traveling in space from a given 'RDPosition'.
 */
+ (RDPosition *) simulateTraveling:(RDPosition*)initialPosition {
    RDPosition * newPosition = [[RDPosition alloc] init];
    newPosition.x = [NSNumber numberWithFloat:[initialPosition.x floatValue] + 50];
    newPosition.y = [NSNumber numberWithFloat:[initialPosition.y floatValue] + 50];
    newPosition.z = [NSNumber numberWithFloat:[initialPosition.y floatValue]];
    return newPosition;
}

@end
