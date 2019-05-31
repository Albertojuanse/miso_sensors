//
//  ViewController.m
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvas];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
}

/*!
 @method didReceiveMemoryWarning
 @discussion This method dispose of any resources that can be recreated id a memory warning is recived.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 @method refreshCanvas:
 @discussion This method gets the beacons that must be represented in canvas and ask it to upload; this method is called when someone submits the 'refreshCanvas' notification.
 */
- (void) refreshCanvas:(NSNotification *) notification
{
    // [notification name] should always be @"refreshCanvas"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"refreshCanvas"]){
        NSLog(@"[NOTI][VC] Notification \"refreshCanvas\" recived");
        
        // Save beacons
        NSDictionary *data = notification.userInfo;
        rangedBeacons = [data valueForKey:@"rangedBeacons"];
        self.text.text =  [[NSString alloc] init];
        self.canvas.rangedBeacons = [[NSMutableDictionary alloc] init];
        
        // Do whatever with every beacon
        NSArray *keys = [rangedBeacons allKeys];
        for (id key in keys){
            CLBeacon *beacon = [rangedBeacons objectForKey:key];
            NSString * beaconUUID = [[beacon proximityUUID] UUIDString];
            self.text.text = [self.text.text stringByAppendingString:[beaconUUID stringByAppendingString:@"\n"]];
            [self.canvas.rangedBeacons setObject:beacon forKey:beaconUUID];
        }
    }
    [self.canvas setNeedsDisplay];
}

@end
