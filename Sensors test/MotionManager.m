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

- (void) startAccelerometers {
    // Make sure the accelerometer hardware is available.
    if (self.isAccelerometerAvailable) {
        NSLog(@"[INFO] Accelerometer avalible");
        self.accelerometerUpdateInterval = 1.0 / 30.0;
        [self startAccelerometerUpdates];
        
        // Configure a timer to fetch the data.
        self.timer =[[NSTimer alloc] initWithFireDate:[NSDate date] interval:(1.0/60.0) target:self selector:@selector(process) userInfo:nil repeats:YES];
        
        // Add the timer to the current run loop.
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    } else {
        NSLog(@"[ERROR] Accelerometer not avalible");
    }
    NSLog(@"[ERROR] Accelerometer started");
}

- (void) stopAccelerometers {
    [self startAccelerometerUpdates];
    NSLog(@"[ERROR] Accelerometer stopped");
}

- (void) process {
    if(self.accelerometerData != nil){
        x = self.accelerometerData.acceleration.x;
        y = self.accelerometerData.acceleration.y;
        z = self.accelerometerData.acceleration.z;
        NSLog(@"[INFO] Data Avalible");
    }
}

@end
