//
//  MotionManager.m
//  Sensors test
//
//  Created by MISO on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "MotionManager.h"

@implementation MotionManager

- (instancetype)init {
    self = [super init];
    return self;
}

- (void) configure {
    t = 1.0/100.0;
    g = 9.7994;
    calibrationTime = 10;
    calibrationSteps = calibrationTime * 1/t;
    calibration_counter = 0;
    precision_threshold = 0.1;
    
}

- (void) startAccelerometers {
    
    // Make sure the accelerometer hardware is available.
    if (self.isAccelerometerAvailable) {
        NSLog(@"[INFO] Accelerometer avalible");
        self.accelerometerUpdateInterval = t;
        [self startAccelerometerUpdates];
        if (self.timer == nil){
        // Configure a timer to fetch the data.
            self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:(t) target:self selector:@selector(process) userInfo:nil repeats:YES];
        
            // Add the timer to the current run loop.
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
    } else {
        NSLog(@"[ERROR] Accelerometer not avalible");
    }
    NSLog(@"[INFO] Accelerometer started");
}

- (void) stopAccelerometers {
    [self.timer invalidate];
    self.timer = nil;
    [self stopAccelerometerUpdates];
    NSLog(@"[INFO] Accelerometer stopped");
}

- (void) startGyroscopes {
    // Make sure the gyroscope hardware is available.
    if (self.isGyroAvailable) {
        NSLog(@"[INFO] Gyroscope avalible");
        self.gyroUpdateInterval = t;
        [self startGyroUpdates];
        
        if (self.timer == nil){
            // Configure a timer to fetch the data.
            self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:(t) target:self selector:@selector(process) userInfo:nil repeats:YES];
            
            // Add the timer to the current run loop.
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
    } else {
        NSLog(@"[ERROR] Gyroscope not avalible");
    }
    NSLog(@"[INFO] Gyroscope started");
}

- (void) stopGyroscopes {
    [self.timer invalidate];
    self.timer = nil;
    [self stopGyroUpdates];
    NSLog(@"[INFO] Gyroscope stopped");
}

- (void) process {
    NSLog(@"; x: %f ; y: %f ; z: %f } { timestamp: ", self.gyroData.rotationRate.x, self.gyroData.rotationRate.y, self.gyroData.rotationRate.y);
    // NSLog(@"; x: %f ; y: %f ; z: %f } { timestamp: ", self.accelerometerData.acceleration.x, self.accelerometerData.acceleration.y, self.accelerometerData.acceleration.z);

    // No valid results will be while calibration process
    if (calibration_counter < calibrationSteps) {
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
        
        self.viewController.labelAX.text = [NSString stringWithFormat:@"%.2f", ax0 - ax_ave];
        self.viewController.labelAY.text = [NSString stringWithFormat:@"%.2f", ay0 - ay_ave];
        self.viewController.labelAZ.text = [NSString stringWithFormat:@"%.2f", az0 - az_ave];
        
        self.viewController.labelGX.text = [NSString stringWithFormat:@"%.2f", gp0 - gp_ave];
        self.viewController.labelGY.text = [NSString stringWithFormat:@"%.2f", gr0 - gr_ave];
        self.viewController.labelGZ.text = [NSString stringWithFormat:@"%.2f", gy0 - gy_ave];
    } else {
        self.viewController.labelCalibrated.text = @"Calibrated";
        
        // Accelerometer acquisition
        ax = self.accelerometerData.acceleration.x * g - ax_ave;
        ay = self.accelerometerData.acceleration.y * g - ay_ave;
        az = self.accelerometerData.acceleration.z * g - az_ave;
        
        self.viewController.labelAX.text = [NSString stringWithFormat:@"%.2f", ax];
        self.viewController.labelAY.text = [NSString stringWithFormat:@"%.2f", ay];
        self.viewController.labelAZ.text = [NSString stringWithFormat:@"%.2f", az];
        
        // Gyroscope acquisition
        gp = self.gyroData.rotationRate.x - gp_ave;
        gr = self.gyroData.rotationRate.y - gr_ave;
        gy = self.gyroData.rotationRate.z - gy_ave;
        
        self.viewController.labelGX.text = [NSString stringWithFormat:@"%.2f", gp];
        self.viewController.labelGY.text = [NSString stringWithFormat:@"%.2f", gr];
        self.viewController.labelGZ.text = [NSString stringWithFormat:@"%.2f", gy];
        
        // Inertial compensation
        
        
        // Attitude
        if (gp > precision_threshold) {
            dp = dp + gp * 180 / M_PI * t;
            self.viewController.labelDegP.text = [NSString stringWithFormat:@"%.2f", dp];
        }
        if (gp < -precision_threshold) {
            dp = dp + gp * 180 / M_PI * t;
            self.viewController.labelDegP.text = [NSString stringWithFormat:@"%.2f", dp];
        }
        if (gr > precision_threshold) {
            dr = dr + gr * 180 / M_PI * t;
            self.viewController.labelDegR.text = [NSString stringWithFormat:@"%.2f", dr];
        }
        if (gr < -precision_threshold) {
            dr = dr + gr * 180 / M_PI * t;
            self.viewController.labelDegR.text = [NSString stringWithFormat:@"%.2f", dr];
        }
        if (gy > precision_threshold) {
            dy = dy + gy * 180 / M_PI * t;
            self.viewController.labelDegY.text = [NSString stringWithFormat:@"%.2f", dy];
        }
        if (gy < -precision_threshold) {
            dy = dy + gy * 180 / M_PI * t;
            self.viewController.labelDegY.text = [NSString stringWithFormat:@"%.2f", dy];
        }
        
        // Position
        if (ax > precision_threshold) {
            vx = vx + ax * t;
            rx = rx + (1.0/2.0) * vx * t;
            self.viewController.labelPosX.text = [NSString stringWithFormat:@"%.2f", rx];
        }
        if (ax < -precision_threshold) {
            vx = vx + ax * t;
            rx = rx + (1.0/2.0) * vx * t;
            self.viewController.labelPosX.text = [NSString stringWithFormat:@"%.2f", rx];
        }
        
        if (ay > precision_threshold) {
            vy = vy + ay * t;
            ry = ry + (1.0/2.0) * vy * t;
            self.viewController.labelPosY.text = [NSString stringWithFormat:@"%.2f", ry];
        }
        if (ay < -precision_threshold) {
            vy = vy + ay * t;
            ry = ry + (1.0/2.0) * vy * t;
            self.viewController.labelPosY.text = [NSString stringWithFormat:@"%.2f", ry];
        }
        
        if (az > precision_threshold) {
            vz = vz + az * t;
            rz = rz + (1.0/2.0) * vz * t;
            self.viewController.labelPosZ.text = [NSString stringWithFormat:@"%.2f", rz];
        }
        if (az < -precision_threshold) {
            vz = vz + az * t;
            rz = rz + (1.0/2.0) * vz * t;
            self.viewController.labelPosZ.text = [NSString stringWithFormat:@"%.2f", rz];
        }
    }
}
@end
