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
 @method setBeaconsRegistered:
 @discussion This method sets the NSMutableArray variable 'beaconsRegistered'.
 */
- (void) setBeaconsRegistered:(NSMutableArray *)newBeaconsRegistered {
    beaconsRegistered = newBeaconsRegistered;
}


/*!
 @method setRegionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsRegistered'.
 */
- (void) setRegionIdNumber:(NSNumber *)newRegionIdNumber {
    regionIdNumber = newRegionIdNumber;
} 

/*!
 @method handleButtonAdd:
 @discussion This method handles the Add button action and ask the main menu to add the new beacon submitted by the user.
 */
- (IBAction)handleButtonAdd:(id)sender {
    
    // Validate data
    NSString * uuidRegex = @"[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}";
    NSPredicate * uuidTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", uuidRegex];
    if ([uuidTest evaluateWithObject:[self.textUUID text]]){
        //Matches
    } else {
        self.textError.text = @"Error. UUID not valid. Please, submit a valid UUID.";
        return;
    }
    
    NSString * majorAndMinorRegex = @"[0-32768]{1}";
    NSPredicate * majorAndMinorTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", majorAndMinorRegex];
    if ([majorAndMinorTest evaluateWithObject:[self.textMajor text]]){
        //Matches
    } else {
        self.textError.text = @"Error. Major value not valid. Please, submit a valid major value.";
        return;
    }
    if ([majorAndMinorTest evaluateWithObject:[self.textMinor text]]){
        //Matches
    } else {
        self.textError.text = @"Error. Minor value not valid. Please, submit a valid minor value.";
        return;
    }
    
    // Search for it; if exist, not submit
    for (NSMutableDictionary * regionDic in beaconsRegistered) {
        if ([[self.textUUID text] isEqualToString:regionDic[@"uuid"]]) {
            if ([[self.textMajor text] isEqualToString:regionDic[@"major"]]) {
                if ([[self.textMinor text] isEqualToString:regionDic[@"minor"]]) {
                    self.textError.text = @"Error. This iBeacon is already registered. Please, submit a different one or push \"Back\".";
                    return;
                }
            }
        }
    }
    
    // This code is only reached if the Beacon is UUID compliant and it does not exist.
    NSMutableDictionary * regionBeaconDic = [[NSMutableDictionary alloc] init];
    [regionBeaconDic setValue:[self.textUUID text] forKey:@"uuid"];
    [regionBeaconDic setValue:[self.textMajor text] forKey:@"major"];
    [regionBeaconDic setValue:[self.textMinor text] forKey:@"minor"];
    regionIdNumber = [NSNumber numberWithInt:[regionIdNumber intValue] + 1];
    NSString * regionId = [@"beacon" stringByAppendingString:[regionIdNumber stringValue]];
    regionId = [regionId stringByAppendingString:@"@miso.uam.es"];
    
    [regionBeaconDic setValue:regionId forKey:@"identifier"];
    [beaconsRegistered addObject:regionBeaconDic];
    
    [self performSegueWithIdentifier:@"submitFromAddToMain" sender:sender];
}

/*!
 @method handleButtonBack:
 @discussion This method handles the Back button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender {
    [self performSegueWithIdentifier:@"backFromAddToMain" sender:sender];
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCAB] Asked segue %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"submitFromAddToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerMainMenu setBeaconsRegistered:beaconsRegistered];
        [viewControllerMainMenu setRegionIdNumber:regionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"backFromAddToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerMainMenu setBeaconsRegistered:beaconsRegistered];
        [viewControllerMainMenu setRegionIdNumber:regionIdNumber];
    }
}

@end

