//
//  ViewController.m
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the app delegate
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvas];
    
    // This object must listen to this events.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshCanvas:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"refreshCanvas"]){
        NSLog(@"[NOTIF] Notification \"refreshCanvas\" recived");
        
        // Save beacons
        NSDictionary *data = notification.userInfo;
        rangedBeacons = [data valueForKey:@"rangedBeacons"];
        self.text.text =  [[NSString alloc] init];
        self.canvas.rangedBeacons = [[NSMutableArray alloc] init];
        
        // Do whatever with every beacon
        for (CLBeacon * beacon in rangedBeacons){
            NSString * beaconUUID = [[beacon proximityUUID] UUIDString];
            self.text.text = [self.text.text stringByAppendingString:beaconUUID];
            [self.canvas.rangedBeacons addObject:beacon];
        }
    }
    [self.canvas setNeedsDisplay];
}

@end
