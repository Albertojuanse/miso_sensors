//
//  main.m
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        // Routine for cleaning user default database
        /*
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
        NSLog(@"[MAIN] Cleaning users default memory.");
        for(NSString * key in keys){
            if ([key containsString:@"es.uam.miso"]) {
                [userDefaults removeObjectForKey:key];
                NSLog(@"[MAIN] Removed the content of key %@.", key);
            }
        }
        */
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
