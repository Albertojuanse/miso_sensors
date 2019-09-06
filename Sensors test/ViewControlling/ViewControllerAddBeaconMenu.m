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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Visualization
    // Sets if the user wants to modify a beacon device or a position, or nothing
    NSDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:credentialsUserDic
                                                                                  andCredentialsUserDic:credentialsUserDic];
    if (
        ![@"beacon" isEqualToString:itemChosenByUser[@"sort"]] &&
        ![@"position" isEqualToString:itemChosenByUser[@"sort"]]
        )
    { // Add new one
        selectedSegmentIndex = 0;
    } else {
        if ([@"beacon" isEqualToString:itemChosenByUser[@"sort"]]) {
            selectedSegmentIndex = 0;
        }
        if ([@"position" isEqualToString:itemChosenByUser[@"sort"]]) {
            selectedSegmentIndex = 1;
        }
         if (
             [@"beacon" isEqualToString:itemChosenByUser[@"sort"]] &&
             [@"position" isEqualToString:itemChosenByUser[@"sort"]]
             )
         {
             NSLog(@"[ERROR][VCAB] User did choose both Beacon and Position to change; UUID by default.");
             selectedSegmentIndex = 0;
         }
    }
    
    [self.segmentedControl setSelectedSegmentIndex:selectedSegmentIndex];
    [self changeView];
    
    // This object must listen to this events
    [self.segmentedControl addTarget:self
                              action:@selector(uploadSegmentIndex:)
                    forControlEvents:UIControlEventValueChanged];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableTypes.delegate = self;
    self.tableTypes.dataSource = self;
    
    [self.tableTypes reloadData];
}

/*!
 @method uploadSegmentIndex:
 @discussion This method is called when the segmented control is tapped and changes the enable and view values of the forms to alternate between them.
 */
- (void) uploadSegmentIndex:(id)sender
{
    // Upload global variable value
    selectedSegmentIndex = [self.segmentedControl selectedSegmentIndex];
    [self changeView];
    return;
}
     

/*!
 @method changeView
 @discussion This method is called when the segmented control is tapped and changes the enable and view values of the forms to alternate between them.
 */
 - (void) changeView
{
     
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
         case 0: {// iBeacon mode
             
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
             NSMutableDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:credentialsUserDic
                                                                                                  andCredentialsUserDic:credentialsUserDic];
             NSMutableArray * itemsData = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
             if ([@"beacon" isEqualToString:itemChosenByUser[@"sort"]]) {
                 for (NSMutableDictionary * itemDic in itemsData) {
                     if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                         if ([itemDic[@"uuid"] isEqualToString:itemChosenByUser[@"uuid"]]) {
                             self.textUUID.text = itemDic[@"uuid"];
                             self.textMajor.text = itemDic[@"major"];
                             self.textMinor.text = itemDic[@"minor"];
                             
                             if (itemDic[@"type"]){
                                 self.textType.text = [NSString stringWithFormat:@"%@", itemDic[@"type"]];
                             }
                             
                             if (itemDic[@"position"]) {
                                 RDPosition * position = itemDic[@"position"];
                                 self.textBeaconX.text = [position.x stringValue];
                                 self.textBeaconY.text = [position.y stringValue];
                                 self.textBeaconZ.text = [position.z stringValue];
                             }
                         }
                     }
                 }
                 
             }
             
             break;
         }
             
         case 1: { // position mode
             
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
             NSMutableDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:credentialsUserDic
                                                                                                  andCredentialsUserDic:credentialsUserDic];
             NSMutableArray * itemsData = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
             if ([@"position" isEqualToString:itemChosenByUser[@"sort"]]) {
                 
                 for (NSMutableDictionary * itemDic in itemsData) {
                     if ([@"position" isEqualToString:itemDic[@"sort"]]) {
                         
                         if (itemDic[@"type"]){
                             self.textType.text = [NSString stringWithFormat:@"%@", itemDic[@"type"]];
                         }
                         
                         if (itemDic[@"position"]) {
                             RDPosition * position = itemDic[@"position"];
                             self.textBeaconX.text = [position.x stringValue];
                             self.textBeaconY.text = [position.y stringValue];
                             self.textBeaconZ.text = [position.z stringValue];
                         }
                     }
                 }
                 
             }
             
             break;
         }
         default:
             break;
     }

}

#pragma mark - Instance methods

/*!
 @method setCredentialsUserDic
 @discussion This method sets the credentials of the user for accessing data shared.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)newCredentialsUserDic
{
    credentialsUserDic = newCredentialsUserDic;
}

/*!
 @method setSharedData:
 @discussion This method sets the shared data collection.
 */
- (void) setSharedData:(SharedData *)newSharedData
{
    sharedData = newSharedData;
}

/*!
 @method setMotionManager:
 @discussion This method sets the motion manager.
 */
- (void) setMotionManager:(MotionManager *)newMotion
{
    motion = newMotion;
}

/*!
 @method setLocationManager:
 @discussion This method sets the location manager.
 */
- (void) setLocationManager:(LocationManagerDelegate *)newLocation
{
    location = newLocation;
}

/*!
 @method setRegionBeaconIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionBeaconIdNumber:(NSNumber *)newRegionBeaconIdNumber
{
    regionBeaconIdNumber = newRegionBeaconIdNumber;
}

/*!
 @method setRegionPositionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionPositionIdNumber:(NSNumber *)newRegionPositionIdNumber
{
    regionPositionIdNumber = newRegionPositionIdNumber;
}

#pragma mark - Buttons event handles

/*!
 @method handleButtonDelete:
 @discussion This method handles the 'Delete' button action and ask the main menu to delete the beacon submitted by the user.
 */
- (IBAction)handleButtonDelete:(id)sender
{
    
    NSMutableDictionary * regionDicToRemove;
    
    // Different behaviour if position or beacon
    if (selectedSegmentIndex == 0) { // iBeacon mode
            
        // Search for it and delete it
        for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
            if ([@"beacon" isEqualToString:regionDic[@"sort"]]) {
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
            if ([@"position" isEqualToString:regionDic[@"sort"]]) {
                
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
- (IBAction)handleButtonAdd:(id)sender
{
    
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
            if ([@"beacon" isEqualToString:regionDic[@"sort"]]) {
                if ([[self.textUUID text] isEqualToString:regionDic[@"uuid"]]) {
                    if ([[self.textMajor text] isEqualToString:regionDic[@"major"]]) {
                        if ([[self.textMinor text] isEqualToString:regionDic[@"minor"]]) {
                            
                            // If this code is reached, the beacon is registered and its position can be set or uploaded but not registered again.
                            dicFound = YES;
                            
                            // Also its type can be modified or set
                            if (typeChosenByUser) {
                                
                                // The special type <No type> is selected by user to remove the previous chosen type
                                if ([typeChosenByUser isEqualToString:@"<No type>"]) {
                                    regionDic[@"sort"] = nil;
                                } else {
                                    // search for its dictionary and set it
                                    for (NSMutableDictionary * typeDic in typesRegistered) {
                                        if ([typeChosenByUser isEqualToString:typeDic[@"name"]]) {
                                            regionDic[@"sort"] = typeDic;
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
                                
                                // If all coordinate values missing the user tries to re-register a beacon, unless the user wanted to set its type
                                if (
                                    [[self.textBeaconX text] isEqualToString:@""] &&
                                    [[self.textBeaconY text] isEqualToString:@""] &&
                                    [[self.textBeaconZ text] isEqualToString:@""]
                                    )
                                {
                                    // This code is reached also when an type was set or uploaded, so check it
                                    if (!typeChosenByUser) {
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
            if ([@"position" isEqualToString:regionDic[@"sort"]]) {
                
                RDPosition * positionToFind = [[RDPosition alloc] init];
                positionToFind.x = [NSNumber numberWithFloat:[[self.textPositionX text] floatValue]];
                positionToFind.y = [NSNumber numberWithFloat:[[self.textPositionY text] floatValue]];
                positionToFind.z = [NSNumber numberWithFloat:[[self.textPositionZ text] floatValue]];
                
                if ([positionToFind isEqual:regionDic[@"position"]]) {
                    
                    // If this code is reached, the position is registered and its position can be uploaded.
                    dicFound = YES;
                    
                    // Also its type can be modified or set
                    if (typeChosenByUser) {
                        
                        // The special type <No type> is selected by user to remove the previous chosen type
                        if ([typeChosenByUser isEqualToString:@"<No type>"]) {
                            regionDic[@"sort"] = nil;
                        } else {
                            // search for its dictionary and set it
                            for (NSMutableDictionary * typeDic in typesRegistered) {
                                if ([typeChosenByUser isEqualToString:typeDic[@"name"]]) {
                                    regionDic[@"sort"] = typeDic;
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
                            // This code is reached also when an type was set or uploaded, so check it
                            if (!typeChosenByUser) {
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
       
            [newRegionDic setValue:@"beacon" forKey:@"sort"];
            [newRegionDic setValue:[self.textUUID text] forKey:@"uuid"];
            [newRegionDic setValue:[self.textMajor text] forKey:@"major"];
            [newRegionDic setValue:[self.textMinor text] forKey:@"minor"];
            
            regionBeaconIdNumber = [NSNumber numberWithInt:[regionBeaconIdNumber intValue] + 1];
            NSString * regionId = [@"beacon" stringByAppendingString:[regionBeaconIdNumber stringValue]];
            regionId = [regionId stringByAppendingString:@"@miso.uam.es"];
            [newRegionDic setValue:regionId forKey:@"identifier"];
            
            // Its type can be set
            if (typeChosenByUser) {
                
                // The special type <No type> is selected by user to remove the previous chosen type
                if ([typeChosenByUser isEqualToString:@"<No type>"]) {
                    newRegionDic[@"sort"] = nil;
                } else {
                    // search for its dictionary and set it
                    for (NSMutableDictionary * typeDic in typesRegistered) {
                        if ([typeChosenByUser isEqualToString:typeDic[@"name"]]) {
                            newRegionDic[@"sort"] = typeDic;
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
            
            [newRegionDic setValue:@"position" forKey:@"sort"];
            [newRegionDic setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
            
            regionPositionIdNumber = [NSNumber numberWithInt:[regionPositionIdNumber intValue] + 1];
            NSString * regionId = [@"position" stringByAppendingString:[regionPositionIdNumber stringValue]];
            regionId = [regionId stringByAppendingString:@"@miso.uam.es"];
            [newRegionDic setValue:regionId forKey:@"identifier"];
            
            RDPosition * positionToSave = [[RDPosition alloc] init];
            positionToSave.x = [NSNumber numberWithFloat:[[self.textPositionX text] floatValue]];
            positionToSave.y = [NSNumber numberWithFloat:[[self.textPositionY text] floatValue]];
            positionToSave.z = [NSNumber numberWithFloat:[[self.textPositionZ text] floatValue]];
            
            // Its type can be set
            if (typeChosenByUser) {
                
                // The special type <No type> is selected by user to remove the previous chosen type
                if ([typeChosenByUser isEqualToString:@"<No type>"]) {
                    newRegionDic[@"sort"] = nil;
                } else {
                    // search for its dictionary and set it
                    for (NSMutableDictionary * typeDic in typesRegistered) {
                        if ([typeChosenByUser isEqualToString:typeDic[@"name"]]) {
                            newRegionDic[@"sort"] = typeDic;
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
- (IBAction)handleButtonBack:(id)sender
{
    [self performSegueWithIdentifier:@"backFromAddToMain" sender:sender];
}

/*!
 @method handleButtonAddType:
 @discussion This method handles the 'Add type' button action and register the user type if it does not exit.
 */
- (IBAction)handleButtonAddType:(id)sender
{
    
    // The user tries to register the type called
    NSString * newTypeName = [self.textType text];
    
    // Search for it
    BOOL dicFound = NO;
    for (NSMutableDictionary * typeDic in typesRegistered) {
        
        // If it exists, return
        if ([typeDic[@"name"] isEqualToString:newTypeName]) {
            dicFound = YES;
            return;
        } else {
            // Nothing
        }
    }
    
    // If it did not exist, create it
    if (!dicFound) {
        NSMutableDictionary * typeDic = [[NSMutableDictionary alloc] init];
        [typeDic setValue:newTypeName forKey:@"name"];
        [typesRegistered addObject:typeDic];
    }
    
    // Reload visualization
    [self.tableTypes reloadData];
    return;
}


/*!
 @method handleButtonRemoveType:
 @discussion This method handles the 'Remove type' button action and unregister the user type if it exits.
 */
- (IBAction)handleButtonRemoveType:(id)sender
{
    
    // The user tries to remove the type called
    NSString * removeTypeName = [self.textType text];
    
    // Search for it
    NSMutableDictionary * typeDicFound;
    for (NSMutableDictionary * typeDic in typesRegistered) {
        // If it exists, save its reference
        if ([typeDic[@"name"] isEqualToString:removeTypeName]) {
            typeDicFound = typeDic;
        }
    }
    if (typeDicFound) {
        [typesRegistered removeObject:typeDicFound];
    }
    
    // Reload visualization
    [self.tableTypes reloadData];
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
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        [viewControllerMainMenu setLocationManager:location];
        
        [viewControllerMainMenu setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setTypesRegistered:typesRegistered];
        [viewControllerMainMenu setRegionBeaconIdNumber:regionBeaconIdNumber];
        [viewControllerMainMenu setRegionPositionIdNumber:regionPositionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"backFromAddToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        [viewControllerMainMenu setLocationManager:location];
        
        [viewControllerMainMenu setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setTypesRegistered:typesRegistered];
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
    if (tableView == self.tableTypes) {
        return [typesRegistered count];
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
    if (tableView == self.tableTypes) {
        NSMutableDictionary * typeDic = [typesRegistered objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", typeDic[@"name"]];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableTypes) {
        
        // Get the chosen type name
        typeChosenByUser = [typesRegistered objectAtIndex:indexPath.row][@"name"];
        self.textType.text = [typesRegistered objectAtIndex:indexPath.row][@"name"];
        
    }
    return;
}

@end

