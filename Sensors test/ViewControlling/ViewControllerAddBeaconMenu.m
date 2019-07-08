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
    self.textUUID.placeholder = @"12345678-1234-1234-1234-123456789012";
    self.textMajor.placeholder = @"0";
    self.textMinor.placeholder = @"0";
}

/*!
 @method viewDidLoad
 @discussion This method handles the Add button action and ask the main menu to add the new beacon submitted by the user.
 */
- (IBAction)handleButtonAdd:(id)sender {
    
    NSLog(@"[INFO][VCAM] Evaluating");
    // Validate data
    
    
    
    
    NSString * uuidRegex = @"[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}";
    NSPredicate * uuidTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", uuidRegex];
    if ([uuidTest evaluateWithObject:[self.textUUID text]]){
        //Matches
    } else {
        self.textError.text = @"Error. Please, submit a valid UUID value from the new iBeacon device.";
        return;
    }
    
    NSString * majorAndMinorRegex = @"[0-32768]{1}";
    NSPredicate * majorAndMinorTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", majorAndMinorRegex];
    if ([majorAndMinorTest evaluateWithObject:[self.textMajor text]]){
        //Matches
    } else {
        self.textError.text = @"Error. Please, submit a valid major value from the new iBeacon device.";
        return;
    }
    if ([majorAndMinorTest evaluateWithObject:[self.textMinor text]]){
        //Matches
    } else {
        self.textError.text = @"Error. Please, submit a valid minor value from the new iBeacon device.";
        return;
    }
    
    NSLog(@"[NOTI][LM] Notification \"handleButtonAdd\" posted.");
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:[self.textUUID text] forKey:@"uuid"];
    [data setObject:[self.textMajor text] forKey:@"major"];
    [data setObject:[self.textMinor text] forKey:@"minor"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"handleButtonAdd"
     object:nil
     userInfo:data];
    
    [self performSegueWithIdentifier:@"fromAddToMain" sender:sender];
}

/*!
 @method handleButtonBack:
 @discussion This method handles the Back button action and segue back to the main menu.
 */
- (IBAction)handleButtonBack:(id)sender {
    [self performSegueWithIdentifier:@"fromAddToMain" sender:sender];
}

@end

