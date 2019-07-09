//
//  AppDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MotionManager.h"
#import "LocationManagerDelegate.h"
#import "SharedData.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    // Other components
    MotionManager * motion;
    LocationManagerDelegate * location;
    SharedData * sharedData;
    
}

@property (strong, nonatomic) UIWindow * window;

@end

