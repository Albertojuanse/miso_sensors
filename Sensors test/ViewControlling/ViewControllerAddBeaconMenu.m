//
//  ViewControllerAddBeaconMenu.m
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerAddBeaconMenu.h"

@implementation ViewControllerAddBeaconMenu

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visualization
    // Sets if the user wants to modify a beacon device or a position, or nothing
    if (uuidChosenByUser) {
        selectedSegmentIndex = 0;
    }
    if (positionChosenByUser) {
        selectedSegmentIndex = 1;
    }
    if (!uuidChosenByUser && !positionChosenByUser) { // Add new one
        selectedSegmentIndex = 0;
    }
    if (uuidChosenByUser && positionChosenByUser) {
        NSLog(@"[ERROR][VCAB] User did choose both Beacon and Position to change; UUID by default.");
        selectedSegmentIndex = 0;
    }
    [self.segmentedControl setSelectedSegmentIndex:selectedSegmentIndex];
    [self changeView];
    
    // This object must listen to this events
    [self.segmentedControl addTarget:self
                              action:@selector(uploadSegmentIndex:)
                    forControlEvents:UIControlEventValueChanged];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableEntities.delegate = self;
    self.tableEntities.dataSource = self;
    
    [self.tableEntities reloadData];
}

/*!
 @method uploadSegmentIndex:
 @discussion This method is called when the segmented control is tapped and changes the enable and view values of the forms to alternate between them.
 */
- (void) uploadSegmentIndex:(id)sender {
    
    // Upload global variable value
    selectedSegmentIndex = [self.segmentedControl selectedSegmentIndex];
    [self changeView];
    return;
}
     

/*!
 @method changeView
 @discussion This method is called when the segmented control is tapped and changes the enable and view values of the forms to alternate between them.
 */
 - (void) changeView {
     
     // Empty text boxes
     self.textUUID.text = @"";
     self.textMinor.text = @"";
     self.textMajor.text = @"";
     self.textBeaconX.text = @"";
     self.textBeaconY.text = @"";
     self.textBeaconZ.text = @"";
     self.textPositionX.text = @"";
     self.textPositionY.text = @"";
     self.textPositionZ.text = @"";
     
     // Different behaviour if position or beacon
     switch (selectedSegmentIndex) {
         case 0: // iBeacon mode
             
             // Visualization
             // Enable beacon elements
             [self.labelBeacon1 setEnabled:YES];
             [self.labelBeaconUUID setEnabled:YES];
             [self.labelBeaconMajor setEnabled:YES];
             [self.labelBeaconMinor setEnabled:YES];
             [self.textUUID setEnabled:YES];
             [self.textMajor setEnabled:YES];
             [self.textMinor setEnabled:YES];
             [self.labelBeacon2 setEnabled:YES];
             [self.labelBeaconX setEnabled:YES];
             [self.labelBeaconY setEnabled:YES];
             [self.labelBeaconZ setEnabled:YES];
             [self.textBeaconX setEnabled:YES];
             [self.textBeaconY setEnabled:YES];
             [self.textBeaconZ setEnabled:YES];
             [self.labelBeaconError setEnabled:YES];
             [self.buttonBeaconDelete setEnabled:YES];
             [self.buttonBeaconBack setEnabled:YES];
             [self.buttonBeaconAdd setEnabled:YES];
             // Disable position elements
             [self.labelPosition1 setEnabled:NO];
             [self.labelPositionX setEnabled:NO];
             [self.labelPositionY setEnabled:NO];
             [self.labelPositionZ setEnabled:NO];
             [self.textPositionX setEnabled:NO];
             [self.textPositionY setEnabled:NO];
             [self.textPositionZ setEnabled:NO];
             [self.labelPositionError setEnabled:NO];
             [self.buttonPositionDelete setEnabled:NO];
             [self.buttonPositionBack setEnabled:NO];
             [self.buttonPositionAdd setEnabled:NO];
             
             // Hints
             self.textUUID.placeholder = @"12345678-1234-1234-1234-123456789012";
             self.textMajor.placeholder = @"0";
             self.textMinor.placeholder = @"0";
             self.textBeaconX.placeholder = @"0.0";
             self.textBeaconY.placeholder = @"0.0";
             self.textBeaconZ.placeholder = @"0.0";
             self.textPositionX.placeholder = @"";
             self.textPositionY.placeholder = @"";
             self.textPositionZ.placeholder = @"";
             
             // If user did select an object to modify, search for it and display it on texts.
             if (uuidChosenByUser) {
                 
                 for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
                     if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
                         if ([regionDic[@"uuid"] isEqualToString:uuidChosenByUser]) {
                             self.textUUID.text = regionDic[@"uuid"];
                             self.textMajor.text = regionDic[@"major"];
                             self.textMinor.text = regionDic[@"minor"];
                             
                             if (regionDic[@"entity"]){
                                 self.textEntity.text = regionDic[@"entity"][@"name"];
                             }
                             
                             if (
                                 regionDic[@"x"] &&
                                 regionDic[@"y"] &&
                                 regionDic[@"z"]
                                 )
                             {
                                 self.textBeaconX.text = regionDic[@"x"];
                                 self.textBeaconY.text = regionDic[@"y"];
                                 self.textBeaconZ.text = regionDic[@"z"];
                             }
                         }
                     }
                 }
                 
             }
             
             break;
             
         case 1: // position mode
             
             // Visualization
             // Enable beacon elements
             [self.labelBeacon1 setEnabled:NO];
             [self.labelBeaconUUID setEnabled:NO];
             [self.labelBeaconMajor setEnabled:NO];
             [self.labelBeaconMinor setEnabled:NO];
             [self.textUUID setEnabled:NO];
             [self.textMajor setEnabled:NO];
             [self.textMinor setEnabled:NO];
             [self.labelBeacon2 setEnabled:NO];
             [self.labelBeaconX setEnabled:NO];
             [self.labelBeaconY setEnabled:NO];
             [self.labelBeaconZ setEnabled:NO];
             [self.textBeaconX setEnabled:NO];
             [self.textBeaconY setEnabled:NO];
             [self.textBeaconZ setEnabled:NO];
             [self.labelBeaconError setEnabled:NO];
             [self.buttonBeaconDelete setEnabled:NO];
             [self.buttonBeaconBack setEnabled:NO];
             [self.buttonBeaconAdd setEnabled:NO];
             // Disable position elements
             [self.labelPosition1 setEnabled:YES];
             [self.labelPositionX setEnabled:YES];
             [self.labelPositionY setEnabled:YES];
             [self.labelPositionZ setEnabled:YES];
             [self.textPositionX setEnabled:YES];
             [self.textPositionY setEnabled:YES];
             [self.textPositionZ setEnabled:YES];
             [self.labelPositionError setEnabled:YES];
             [self.buttonPositionDelete setEnabled:YES];
             [self.buttonPositionBack setEnabled:YES];
             [self.buttonPositionAdd setEnabled:YES];
             
             // Hints
             self.textUUID.placeholder = @"";
             self.textMajor.placeholder = @"";
             self.textMinor.placeholder = @"";
             self.textBeaconX.placeholder = @"";
             self.textBeaconY.placeholder = @"";
             self.textBeaconZ.placeholder = @"";
             self.textPositionX.placeholder = @"0.0";
             self.textPositionY.placeholder = @"0.0";
             self.textPositionZ.placeholder = @"0.0";
             
             // If user did select an object to modify, search for it and display it on texts.
             if (positionChosenByUser) {
                 
                 for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
                     if ([@"position" isEqualToString:regionDic[@"type"]]) {
                         
                         if (regionDic[@"entity"]){
                             self.textEntity.text = regionDic[@"entity"][@"name"];
                         }
                         
                         if ([regionDic[@"position"] isEqual:positionChosenByUser]) {
                             self.textPositionX.text = regionDic[@"x"];
                             self.textPositionY.text = regionDic[@"y"];
                             self.textPositionZ.text = regionDic[@"z"];
                         }
                     }
                 }
                 
             }
             
             break;
             
         default:
             break;
     }

}

#pragma mark - Instance methods

/*!
 @method setbeaconsAndPositionsRegistered:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setbeaconsAndPositionsRegistered:(NSMutableArray *)newbeaconsAndPositionsRegistered {
    beaconsAndPositionsRegistered = newbeaconsAndPositionsRegistered;
}

/*!
 @method setRegionBeaconIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionBeaconIdNumber:(NSNumber *)newRegionBeaconIdNumber {
    regionBeaconIdNumber = newRegionBeaconIdNumber;
}

/*!
 @method setRegionPositionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionPositionIdNumber:(NSNumber *)newRegionPositionIdNumber {
    regionPositionIdNumber = newRegionPositionIdNumber;
}

/*!
 @method setUuidChosenByUser:
 @discussion This method sets the NSString variable 'uuidChosenByUser'.
 */
- (void) setUuidChosenByUser:(NSString *)newUuidChosenByUser {
    uuidChosenByUser = newUuidChosenByUser;
}

/*!
 @method setPositionChosenByUser:
 @discussion This method sets the NSString variable 'uuidChosenByUser'.
 */
- (void) setPositionChosenByUser:(RDPosition *)newPositionChosenByUser {
    positionChosenByUser = newPositionChosenByUser;
}

/*!
 @method setEntitiesRegistered:
 @discussion This method sets the NSMutableArray variable 'entitiesRegistered'.
 */
- (void) setEntitiesRegistered:(NSMutableArray *)newEntitiesRegistered {
    entitiesRegistered = newEntitiesRegistered;
}

#pragma mark - Buttons event handles

/*!
 @method handleButtonDelete:
 @discussion This method handles the 'Delete' button action and ask the main menu to delete the beacon submitted by the user.
 */
- (IBAction)handleButtonDelete:(id)sender {
    
    NSMutableDictionary * regionDicToRemove;
    
    // Different behaviour if position or beacon
    if (selectedSegmentIndex == 0) { // iBeacon mode
            
        // Search for it and delete it
        for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
            if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
                if ([[self.textUUID text] isEqualToString:regionDic[@"uuid"]]) {
                    if ([[self.textMajor text] isEqualToString:regionDic[@"major"]]) {
                        if ([[self.textMinor text] isEqualToString:regionDic[@"minor"]]) {
                            
                            // Save its reference
                            regionDicToRemove = regionDic;
                            
                        }
                    }
                }
            }
        }
    }
    if (selectedSegmentIndex == 1) { // position mode
        
        // Search for it and delete it
        for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
            if ([@"position" isEqualToString:regionDic[@"type"]]) {
                
                RDPosition * positionToRemove = [[RDPosition alloc] init];
                positionToRemove.x = [NSNumber numberWithFloat:[[self.textPositionX text] floatValue]];
                positionToRemove.y = [NSNumber numberWithFloat:[[self.textPositionY text] floatValue]];
                positionToRemove.z = [NSNumber numberWithFloat:[[self.textPositionZ text] floatValue]];
                
                if ([positionToRemove isEqual:regionDic[@"position"]]) {
                    // Save its reference
                    regionDicToRemove = regionDic;
                }
            }
        }
    }
    
    [beaconsAndPositionsRegistered removeObject:regionDicToRemove];
    
    [self performSegueWithIdentifier:@"backFromAddToMain" sender:sender];
}

/*!
 @method handleButtonAdd:
 @discussion This method handles the Add button action and ask the main menu to add the new beacon submitted by the user.
 */
- (IBAction)handleButtonAdd:(id)sender {
    
    // The beacons cannot be registered twice with different ID because Location Manager will fail their initialization; because of coherence, two equals positions cannot be registered. Thus, the data of every item must be searched and not only its identifier.
    
    // Different behaviour if position or beacon
    
    // Validate data
    if (selectedSegmentIndex == 0) { // iBeacon mode
        
        NSString * uuidRegex = @"[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}";
        NSPredicate * uuidTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", uuidRegex];
        if ([uuidTest evaluateWithObject:[self.textUUID text]]){
            //Matches
        } else {
            self.labelBeaconError.text = @"Error. UUID not valid. Please, submit a valid UUID.";
            return;
        }
        
        NSString * majorAndMinorRegex = @"[0-9]{1}|[0-9]{1}[0-9]{1}|[0-9]{1}[0-9]{1}[0-9]{1}|[0-9]{1}[0-9]{1}[0-9]{1}[0-9]{1}";
        NSPredicate * majorAndMinorTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", majorAndMinorRegex];
        if ([majorAndMinorTest evaluateWithObject:[self.textMajor text]]){
            //Matches
        } else {
            self.labelBeaconError.text = @"Error. Major value not valid. Please, submit a valid major value.";
            return;
        }
        if ([majorAndMinorTest evaluateWithObject:[self.textMinor text]]){
            //Matches
        } else {
            self.labelBeaconError.text = @"Error. Minor value not valid. Please, submit a valid minor value.";
            return;
        }
        
        NSString * floatRegex = @"^$|[+-]?([0-9]*[.])?[0-9]+";
        NSPredicate * floatTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", floatRegex];
        if ([floatTest evaluateWithObject:[self.textBeaconX text]]){
            //Matches
        } else {
            self.labelBeaconError.text = @"Error. X value not valid. Please, use decimal dot: 0.01";
            return;
        }
        if ([floatTest evaluateWithObject:[self.textBeaconY text]]){
            //Matches
        } else {
            self.labelBeaconError.text = @"Error. Y value not valid. Please, use decimal dot: 0.01";
            return;
        }
        if ([floatTest evaluateWithObject:[self.textBeaconZ text]]){
            //Matches
        } else {
            self.labelBeaconError.text = @"Error. Z value not valid. Please, use decimal dot: 0.01";
            return;
        }
        
    }
    if (selectedSegmentIndex == 1) { // position mode
        
        NSString * floatRegex = @"^$|[+-]?([0-9]*[.])?[0-9]+";
        NSPredicate * floatTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", floatRegex];
        if ([floatTest evaluateWithObject:[self.textPositionX text]]){
            //Matches
        } else {
            self.labelPositionError.text = @"Error. X value not valid. Please, use decimal dot: 0.01";
            return;
        }
        if ([floatTest evaluateWithObject:[self.textPositionY text]]){
            //Matches
        } else {
            self.labelPositionError.text = @"Error. Y value not valid. Please, use decimal dot: 0.01";
            return;
        }
        if ([floatTest evaluateWithObject:[self.textPositionZ text]]){
            //Matches
        } else {
            self.labelPositionError.text = @"Error. Z value not valid. Please, use decimal dot: 0.01";
            return;
        }
        
    }
    
    // Search the submitted in the dictionary
    BOOL dicFound = NO;
    for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
        
        // Different behaviour if position or beacon
        if (selectedSegmentIndex == 0) { // iBeacon mode
            // If it is a beacon
            if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
                if ([[self.textUUID text] isEqualToString:regionDic[@"uuid"]]) {
                    if ([[self.textMajor text] isEqualToString:regionDic[@"major"]]) {
                        if ([[self.textMinor text] isEqualToString:regionDic[@"minor"]]) {
                            
                            // If this code is reached, the beacon is registered and its position can be set or uploaded but not registered again.
                            dicFound = YES;
                            
                            // Also its entity can be modified or set
                            if (entityChosenByUser) {
                                
                                // The special entity <No entity> is selected by user to remove the previous chosen entity
                                if ([entityChosenByUser isEqualToString:@"<No entity>"]) {
                                    regionDic[@"entity"] = nil;
                                } else {
                                    // search for its dictionary and set it
                                    for (NSMutableDictionary * entityDic in entitiesRegistered) {
                                        if ([entityChosenByUser isEqualToString:entityDic[@"name"]]) {
                                            regionDic[@"entity"] = entityDic;
                                        }
                                    }
                                }
                            }
                            
                            // If the three coordinate values had been submitted
                            if (
                                ![[self.textBeaconX text] isEqualToString:@""] &&
                                ![[self.textBeaconY text] isEqualToString:@""] &&
                                ![[self.textBeaconZ text] isEqualToString:@""]
                                )
                            {
                                regionDic[@"x"] = [self.textBeaconX text];
                                regionDic[@"y"] = [self.textBeaconY text];
                                regionDic[@"z"] = [self.textBeaconZ text];
                                RDPosition * positionToAdd = [[RDPosition alloc] init];
                                positionToAdd.x = [NSNumber numberWithFloat:[[self.textBeaconX text] floatValue]];
                                positionToAdd.y = [NSNumber numberWithFloat:[[self.textBeaconY text] floatValue]];
                                positionToAdd.z = [NSNumber numberWithFloat:[[self.textBeaconZ text] floatValue]];
                                regionDic[@"position"] = positionToAdd;
                            } else {
                                
                                // If all coordinate values missing the user tries to re-register a beacon, unless the user wanted to set its entity
                                if (
                                    [[self.textBeaconX text] isEqualToString:@""] &&
                                    [[self.textBeaconY text] isEqualToString:@""] &&
                                    [[self.textBeaconZ text] isEqualToString:@""]
                                    )
                                {
                                    // This code is reached also when an entity was set or uploaded, so check it
                                    if (!entityChosenByUser) {
                                        self.labelPositionError.text = @"Error. This position is already registered. Please, submit a different one or push \"Back\".";
                                        return;
                                    }
                                } else {
                                    // If ths code is reached means that there is only some coordinate values but not all of them
                                    self.labelBeaconError.text = @"Error. Some coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                                    return;
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        if (selectedSegmentIndex == 1) { // position mode
            // If it is a position
            if ([@"position" isEqualToString:regionDic[@"type"]]) {
                
                RDPosition * positionToFind = [[RDPosition alloc] init];
                positionToFind.x = [NSNumber numberWithFloat:[[self.textPositionX text] floatValue]];
                positionToFind.y = [NSNumber numberWithFloat:[[self.textPositionY text] floatValue]];
                positionToFind.z = [NSNumber numberWithFloat:[[self.textPositionZ text] floatValue]];
                
                if ([positionToFind isEqual:regionDic[@"position"]]) {
                    
                    // If this code is reached, the position is registered and its position can be uploaded.
                    dicFound = YES;
                    
                    // Also its entity can be modified or set
                    if (entityChosenByUser) {
                        
                        // The special entity <No entity> is selected by user to remove the previous chosen entity
                        if ([entityChosenByUser isEqualToString:@"<No entity>"]) {
                            regionDic[@"entity"] = nil;
                        } else {
                            // search for its dictionary and set it
                            for (NSMutableDictionary * entityDic in entitiesRegistered) {
                                if ([entityChosenByUser isEqualToString:entityDic[@"name"]]) {
                                    regionDic[@"entity"] = entityDic;
                                }
                            }
                        }
                    }
                    
                    // If the three coordinate values had been submitted
                    if (
                        ![[self.textPositionX text] isEqualToString:@""] &&
                        ![[self.textPositionY text] isEqualToString:@""] &&
                        ![[self.textPositionZ text] isEqualToString:@""]
                        )
                    {
                        regionDic[@"x"] = [self.textPositionX text];
                        regionDic[@"y"] = [self.textPositionY text];
                        regionDic[@"z"] = [self.textPositionZ text];
                        regionDic[@"position"] = positionToFind;
                    } else {
                        
                        // If all coordinate values missing the user tries to re-register the same position, unless user wants to set its entoty
                        if (
                            [[self.textPositionX text] isEqualToString:@""] &&
                            [[self.textPositionY text] isEqualToString:@""] &&
                            [[self.textPositionZ text] isEqualToString:@""]
                            )
                        {
                            // This code is reached also when an entity was set or uploaded, so check it
                            if (!entityChosenByUser) {
                                self.labelPositionError.text = @"Error. This position is already registered. Please, submit a different one or push \"Back\".";
                                return;
                            }
                        } else {
                            // If ths code is reached means that there is only some coordinate values but not all of them
                            self.labelPositionError.text = @"Error. Some coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                            return;
                        }
                    }
                    
                }
            }
        }
    }
    
    // But if not found in the dictionary, the user is subitting a new device or position
    if (!dicFound) {
        
        NSMutableDictionary * newRegionDic = [[NSMutableDictionary alloc] init];
        
        if (selectedSegmentIndex == 0) { // iBeacon mode
       
            [newRegionDic setValue:@"beacon" forKey:@"type"];
            [newRegionDic setValue:[self.textUUID text] forKey:@"uuid"];
            [newRegionDic setValue:[self.textMajor text] forKey:@"major"];
            [newRegionDic setValue:[self.textMinor text] forKey:@"minor"];
            
            regionBeaconIdNumber = [NSNumber numberWithInt:[regionBeaconIdNumber intValue] + 1];
            NSString * regionId = [@"beacon" stringByAppendingString:[regionBeaconIdNumber stringValue]];
            regionId = [regionId stringByAppendingString:@"@miso.uam.es"];
            [newRegionDic setValue:regionId forKey:@"identifier"];
            
            // Its entity can be set
            if (entityChosenByUser) {
                
                // The special entity <No entity> is selected by user to remove the previous chosen entity
                if ([entityChosenByUser isEqualToString:@"<No entity>"]) {
                    newRegionDic[@"entity"] = nil;
                } else {
                    // search for its dictionary and set it
                    for (NSMutableDictionary * entityDic in entitiesRegistered) {
                        if ([entityChosenByUser isEqualToString:entityDic[@"name"]]) {
                            newRegionDic[@"entity"] = entityDic;
                        }
                    }
                }
            }
            
            // If exists the three coordinate values
            if (
                ![[self.textBeaconX text] isEqualToString:@""] &&
                ![[self.textBeaconY text] isEqualToString:@""] &&
                ![[self.textBeaconZ text] isEqualToString:@""]
                )
            {
                newRegionDic[@"x"] = [self.textBeaconX text];
                newRegionDic[@"y"] = [self.textBeaconY text];
                newRegionDic[@"z"] = [self.textBeaconZ text];
                RDPosition * positionToAdd = [[RDPosition alloc] init];
                positionToAdd.x = [NSNumber numberWithFloat:[[self.textBeaconX text] floatValue]];
                positionToAdd.y = [NSNumber numberWithFloat:[[self.textBeaconY text] floatValue]];
                positionToAdd.z = [NSNumber numberWithFloat:[[self.textBeaconZ text] floatValue]];
                newRegionDic[@"position"] = positionToAdd;
            } else {
                
                // If all coordinate values missing, the user does not want to save the position
                if (
                    [[self.textBeaconX text] isEqualToString:@""] &&
                    [[self.textBeaconY text] isEqualToString:@""] &&
                    [[self.textBeaconZ text] isEqualToString:@""]
                    )
                {
                    // Do nothing
                } else {
                    // If ths code is reached means that there is only some coordinate values but not all of them
                    self.labelBeaconError.text = @"Error. Coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                    return;
                }
            }
            
        }
        if (selectedSegmentIndex == 1) { // position mode
            
            [newRegionDic setValue:@"position" forKey:@"type"];
            [newRegionDic setValue:[self.textUUID text] forKey:@"uuid"];
            [newRegionDic setValue:[self.textMajor text] forKey:@"major"];
            [newRegionDic setValue:[self.textMinor text] forKey:@"minor"];
            
            regionPositionIdNumber = [NSNumber numberWithInt:[regionPositionIdNumber intValue] + 1];
            NSString * regionId = [@"position" stringByAppendingString:[regionPositionIdNumber stringValue]];
            regionId = [regionId stringByAppendingString:@"@miso.uam.es"];
            [newRegionDic setValue:regionId forKey:@"identifier"];
            
            RDPosition * positionToSave = [[RDPosition alloc] init];
            positionToSave.x = [NSNumber numberWithFloat:[[self.textPositionX text] floatValue]];
            positionToSave.y = [NSNumber numberWithFloat:[[self.textPositionY text] floatValue]];
            positionToSave.z = [NSNumber numberWithFloat:[[self.textPositionZ text] floatValue]];
            
            // Its entity can be set
            if (entityChosenByUser) {
                
                // The special entity <No entity> is selected by user to remove the previous chosen entity
                if ([entityChosenByUser isEqualToString:@"<No entity>"]) {
                    newRegionDic[@"entity"] = nil;
                } else {
                    // search for its dictionary and set it
                    for (NSMutableDictionary * entityDic in entitiesRegistered) {
                        if ([entityChosenByUser isEqualToString:entityDic[@"name"]]) {
                            newRegionDic[@"entity"] = entityDic;
                        }
                    }
                }
            }
            
            if (
                ![[self.textPositionX text] isEqualToString:@""] &&
                ![[self.textPositionY text] isEqualToString:@""] &&
                ![[self.textPositionZ text] isEqualToString:@""]
                )
            {
                newRegionDic[@"x"] = [self.textPositionX text];
                newRegionDic[@"y"] = [self.textPositionY text];
                newRegionDic[@"z"] = [self.textPositionZ text];
                newRegionDic[@"position"] = positionToSave;
            } else {
                
                // If all coordinate values missing the user tries to re-register the same position
                if (
                    [[self.textPositionX text] isEqualToString:@""] &&
                    [[self.textPositionY text] isEqualToString:@""] &&
                    [[self.textPositionZ text] isEqualToString:@""]
                    )
                {
                    // Do nothing
                } else {
                    // If ths code is reached means that there is only some coordinate values but not all of them
                    self.labelPositionError.text = @"Error. Coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                    return;
                }
            }
            
        }
        
        [beaconsAndPositionsRegistered addObject:newRegionDic];
    }

    [self performSegueWithIdentifier:@"submitFromAddToMain" sender:sender];
}

/*!
 @method handleButtonBack:
 @discussion This method handles the 'Back' button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender {
    [self performSegueWithIdentifier:@"backFromAddToMain" sender:sender];
}

/*!
 @method handleButtonAddEntity:
 @discussion This method handles the 'Add entity' button action and register the user entity if it does not exit.
 */
- (IBAction)handleButtonAddEntity:(id)sender {
    
    // The user tries to register the entity called
    NSString * newEntityName = [self.textEntity text];
    
    // Search for it
    BOOL dicFound = NO;
    for (NSMutableDictionary * entityDic in entitiesRegistered) {
        
        // If it exists, return
        if ([entityDic[@"name"] isEqualToString:newEntityName]) {
            dicFound = YES;
            return;
        } else {
            // Nothing
        }
    }
    
    // If it did not exist, create it
    if (!dicFound) {
        NSMutableDictionary * entityDic = [[NSMutableDictionary alloc] init];
        [entityDic setValue:newEntityName forKey:@"name"];
        [entitiesRegistered addObject:entityDic];
    }
    
    // Reload visualization
    [self.tableEntities reloadData];
    return;
}


/*!
 @method handleButtonRemoveEntity:
 @discussion This method handles the 'Remove entity' button action and unregister the user entity if it exits.
 */
- (IBAction)handleButtonRemoveEntity:(id)sender {
    
    // The user tries to remove the entity called
    NSString * removeEntityName = [self.textEntity text];
    
    // Search for it
    NSMutableDictionary * entityDicFound;
    for (NSMutableDictionary * entityDic in entitiesRegistered) {
        // If it exists, save its reference
        if ([entityDic[@"name"] isEqualToString:removeEntityName]) {
            entityDicFound = entityDic;
        }
    }
    if (entityDicFound) {
        [entitiesRegistered removeObject:entityDicFound];
    }
    
    // Reload visualization
    [self.tableEntities reloadData];
    return;
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
        [viewControllerMainMenu setEntitiesRegistered:entitiesRegistered];
        [viewControllerMainMenu setRegionBeaconIdNumber:regionBeaconIdNumber];
        [viewControllerMainMenu setRegionPositionIdNumber:regionPositionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"backFromAddToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerMainMenu setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setEntitiesRegistered:entitiesRegistered];
        [viewControllerMainMenu setRegionBeaconIdNumber:regionBeaconIdNumber];
        [viewControllerMainMenu setRegionPositionIdNumber:regionPositionIdNumber];
        
        
    }
}

#pragma mark - UItableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableEntities) {
        return [entitiesRegistered count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure individual cells
    if (tableView == self.tableEntities) {
        NSMutableDictionary * entityDic = [entitiesRegistered objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", entityDic[@"name"]];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableEntities) {
        
        // Get the chosen entity name
        entityChosenByUser = [entitiesRegistered objectAtIndex:indexPath.row][@"name"];
        self.textEntity.text = [entitiesRegistered objectAtIndex:indexPath.row][@"name"];
        
    }
    return;
}

@end

