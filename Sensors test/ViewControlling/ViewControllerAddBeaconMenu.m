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
    
    // If 'uuidChosenByUser' exists, it is the edit mode
    for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
        if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
            if ([regionDic[@"uuid"] isEqualToString:uuidChosenByUser]) {
                self.textUUID.text = regionDic[@"uuid"];
                self.textMajor.text = regionDic[@"major"];
                self.textMinor.text = regionDic[@"minor"];
            }
        }
    }
    
}

/*!
 @method setbeaconsAndPositionsRegistered:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setbeaconsAndPositionsRegistered:(NSMutableArray *)newbeaconsAndPositionsRegistered {
    beaconsAndPositionsRegistered = newbeaconsAndPositionsRegistered;
}

/*!
 @method setRegionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionIdNumber:(NSNumber *)newRegionIdNumber {
    regionIdNumber = newRegionIdNumber;
}

/*!
 @method setUuidChosenByUser:
 @discussion This method sets the NSString variable 'uuidChosenByUser'.
 */
- (void) setUuidChosenByUser:(NSString *)newUuidChosenByUser {
    uuidChosenByUser = newUuidChosenByUser;
}

#pragma marks - Buttons event handles

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
    
    NSString * majorAndMinorRegex = @"[0-9]{1}|[0-9]{1}[0-9]{1}|[0-9]{1}[0-9]{1}[0-9]{1}|[0-9]{1}[0-9]{1}[0-9]{1}[0-9]{1}";
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
    
    NSString * floatRegex = @"[+-]?([0-9]*[.])?[0-9]+";
    NSPredicate * floatTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", floatRegex];
    if ([floatTest evaluateWithObject:[self.textX text]]){
        //Matches
    } else {
        self.textError.text = @"Error. X value not valid. Please, use decimal dot: 0.01";
        return;
    }
    if ([floatTest evaluateWithObject:[self.textY text]]){
        //Matches
    } else {
        self.textError.text = @"Error. Y value not valid. Please, use decimal dot: 0.01";
        return;
    }
    if ([floatTest evaluateWithObject:[self.textZ text]]){
        //Matches
    } else {
        self.textError.text = @"Error. Z value not valid. Please, use decimal dot: 0.01";
        return;
    }
    
    // If 'uuidChosenByUser' exists, it is the edit mode
    if (!uuidChosenByUser) {
        // Search for it; if exist, not submit
        for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
            if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
                if ([[self.textUUID text] isEqualToString:regionDic[@"uuid"]]) {
                    if ([[self.textMajor text] isEqualToString:regionDic[@"major"]]) {
                        if ([[self.textMinor text] isEqualToString:regionDic[@"minor"]]) {
                            
                            // If exists but there are the three coordinate values
                            if (
                                ![[self.textX text] isEqualToString:@""] &&
                                ![[self.textY text] isEqualToString:@""] &&
                                ![[self.textZ text] isEqualToString:@""]
                                )
                            {
                                regionDic[@"x"] = [self.textX text];
                                regionDic[@"y"] = [self.textY text];
                                regionDic[@"y"] = [self.textZ text];
                            }
                            
                            // If exists but there are not all the three coordinate values
                            if (
                                ![[self.textX text] isEqualToString:@""] ||
                                ![[self.textY text] isEqualToString:@""] ||
                                ![[self.textZ text] isEqualToString:@""]
                                )
                            {
                                self.textError.text = @"Error. Coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                                return;
                            }
                            
                            // If coordinate values missing, and so, triying to double register a beacon
                            if (
                                [[self.textX text] isEqualToString:@""] &&
                                [[self.textY text] isEqualToString:@""] &&
                                [[self.textZ text] isEqualToString:@""]
                                )
                            {
                                self.textError.text = @"Error. This iBeacon is already registered. Please, submit a different one or push \"Back\".";
                                return;
                            }
                            
                        }
                    }
                }
            }
        }
    
        // This code is only reached if the Beacon is UUID compliant and it does not exist.
        NSMutableDictionary * newRegionDic = [[NSMutableDictionary alloc] init];
        [newRegionDic setValue:@"beacon" forKey:@"type"];
        [newRegionDic setValue:[self.textUUID text] forKey:@"uuid"];
        [newRegionDic setValue:[self.textMajor text] forKey:@"major"];
        [newRegionDic setValue:[self.textMinor text] forKey:@"minor"];
        regionIdNumber = [NSNumber numberWithInt:[regionIdNumber intValue] + 1];
        NSString * regionId = [@"beacon" stringByAppendingString:[regionIdNumber stringValue]];
        regionId = [regionId stringByAppendingString:@"@miso.uam.es"];
    
        [newRegionDic setValue:regionId forKey:@"identifier"];
        
        // If exists but there are the three coordinate values
        if (
            ![[self.textX text] isEqualToString:@""] &&
            ![[self.textY text] isEqualToString:@""] &&
            ![[self.textZ text] isEqualToString:@""]
            )
        {
            newRegionDic[@"x"] = [self.textX text];
            newRegionDic[@"y"] = [self.textY text];
            newRegionDic[@"y"] = [self.textZ text];
        }
        
        // If exists but there are not all the three coordinate values
        if (
            ![[self.textX text] isEqualToString:@""] ||
            ![[self.textY text] isEqualToString:@""] ||
            ![[self.textZ text] isEqualToString:@""]
            )
        {
            self.textError.text = @"Error. Coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
            return;
        }
        
        [beaconsAndPositionsRegistered addObject:newRegionDic];
    } else {
        // Search for it and upload the data
        for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
            if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
                if ([uuidChosenByUser isEqualToString:regionDic[@"uuid"]]) {
                    regionDic[@"uuid"] = [self.textUUID text];
                    regionDic[@"major"] = [self.textMajor text];
                    regionDic[@"minor"] = [self.textMinor text];
                    
                    // If exists but there are the three coordinate values
                    if (
                        ![[self.textX text] isEqualToString:@""] &&
                        ![[self.textY text] isEqualToString:@""] &&
                        ![[self.textZ text] isEqualToString:@""]
                        )
                    {
                        regionDic[@"x"] = [self.textX text];
                        regionDic[@"y"] = [self.textY text];
                        regionDic[@"y"] = [self.textZ text];
                    }
                    
                    // If exists but there are not all the three coordinate values
                    if (
                        ![[self.textX text] isEqualToString:@""] ||
                        ![[self.textY text] isEqualToString:@""] ||
                        ![[self.textZ text] isEqualToString:@""]
                        )
                    {
                        self.textError.text = @"Error. Coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                        return;
                    }
                }
            }
        }
    }

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
        [viewControllerMainMenu setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setRegionIdNumber:regionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"backFromAddToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerMainMenu setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setRegionIdNumber:regionIdNumber];
    }
}

@end

