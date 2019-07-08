//
//  ViewControllerMainMenu.m
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerMainMenu.h"

@implementation ViewControllerMainMenu

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addBeacon:)
                                                 name:@"addBeacon"
                                               object:nil];
    
    // Visualization
    [self.buttonAdd setEnabled:YES];
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
 @method addBeacon:
 @discussion This method adds to the table any beacon that user wants to submit in the adding view; it is only added if it does not exists yet.
 */
- (void)addBeacon:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"addBeacon"]){
        NSLog(@"[NOTI][VC] Notification \"addBeacon\" recived");
        
        // Save beacons
        NSDictionary *data = notification.userInfo;
    }
}

@end
