//
//  ViewControllerAddBeaconMenu.m
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerAddBeaconMenu.h"

@implementation ViewControllerAddBeaconMenu

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visualization
    [self.buttonAdd setEnabled:YES];
}

/*!
 @method viewDidLoad
 @discussion This method handles the Add button action and ask the main menu to add the new beacon submitted by the user.
 */
- (IBAction)handleButtonAdd:(id)sender {
    NSLog(@"[NOTI][LM] Notification \"handleButtonAdd\" posted.");
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:[self.textUUID text] forKey:@"uuid"];
    [data setObject:[self.textMajor text] forKey:@"major"];
    [data setObject:[self.textMinor text] forKey:@"minor"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"handleButtonAdd"
     object:nil
     userInfo:data];
    
    [self performSegueWithIdentifier:@"fromAddToView" sender:sender];
    
}

@end

