//
//  AppDelegate.m
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Instance constants
    
    // Other components
    sharedData = [[SharedData alloc] init];
    motion = [[MotionManager alloc] initWithSharedData:sharedData];
    
    motion.acce_sensitivity_threshold = [NSNumber numberWithFloat:0.01];
    motion.gyro_sensitivity_threshold = [NSNumber numberWithFloat:0.015];
    motion.acce_measuresBuffer_capacity = [NSNumber numberWithInt:500];
    motion.acce_biasBuffer_capacity = [NSNumber numberWithInt:500];
    motion.gyro_measuresBuffer_capacity = [NSNumber numberWithInt:500];
    motion.gyro_biasBuffer_capacity = [NSNumber numberWithInt:500];
    
    location = [[LocationManagerDelegate alloc] initWithSharedData:sharedData];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable trs, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [motion startAccelerometers];
    [motion startGyroscopes];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate trs, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [motion stopAccelerometers];
    [motion stopGyroscopes];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [motion startAccelerometers];
    [motion startGyroscopes];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [motion startAccelerometers];
    [motion startGyroscopes];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [motion stopAccelerometers];
    [motion stopGyroscopes];
}


@end
