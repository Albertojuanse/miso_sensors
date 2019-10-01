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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable trs, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    NSLog(@"[NOTI][AP] Notification \"startAccelerometers\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startAccelerometers" object:nil];
    NSLog(@"[NOTI][AP] Notification \"startGyroscopes\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startGyroscopes" object:nil];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate trs, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"[NOTI][AP] Notification \"stopAccelerometers\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAccelerometers" object:nil];
    NSLog(@"[NOTI][AP] Notification \"stopGyroscopes\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopes" object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"[NOTI][AP] Notification \"startAccelerometers\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startAccelerometers" object:nil];
    NSLog(@"[NOTI][AP] Notification \"startGyroscopes\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startGyroscopes" object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"[NOTI][AP] Notification \"startAccelerometers\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startAccelerometers" object:nil];
    NSLog(@"[NOTI][AP] Notification \"startGyroscopes\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startGyroscopes" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"[NOTI][AP] Notification \"stopAccelerometers\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopAccelerometers" object:nil];
    NSLog(@"[NOTI][AP] Notification \"stopGyroscopes\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopes" object:nil];
}


@end
