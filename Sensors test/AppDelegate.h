//
//  AppDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "MotionManager.h"
#import "LocationManagerDelegate.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MotionManager *motion;
@property (strong, nonatomic) LocationManagerDelegate *location;
@property (strong, nonatomic) ViewController *viewController;


@end

