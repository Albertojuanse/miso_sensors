//
//  TabBarControllerConfiguration.m
//  Sensors test
//
//  Created by Alberto J. on 24/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "TabBarControllerConfiguration.h"

@implementation TabBarConfiguration

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Set this class as the delegated one to handle tab's events
    self.delegate = self;
    
    // Submit demo metamodel if it does not exist
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * types;
    NSMutableArray * metamodels;
    NSMutableArray * items;
    
    // Search for variables from device memory
    NSData * areIdNumbersData = [userDefaults objectForKey:@"es.uam.miso/variables/areIdNumbers"];
    NSString * areIdNumbers;
    if (areIdNumbersData) {
        areIdNumbers = [NSKeyedUnarchiver unarchiveObjectWithData:areIdNumbersData];
    } else {
        areIdNumbers = @"NO";
    }
    if (areIdNumbersData && areIdNumbers && [areIdNumbers isEqualToString:@"YES"]) {
        
    } else {
        // No saved variables
        // Create the variables
        NSNumber * itemBeaconIdNumber = [NSNumber numberWithInteger:5];
        NSNumber * itemPositionIdNumber = [NSNumber numberWithInteger:5];
        
        // Save them in persistent memory
        areIdNumbersData = nil; // ARC disposing
        areIdNumbersData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areIdNumbersData forKey:@"es.uam.miso/variables/areIdNumbers"];
        NSData * itemBeaconIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemBeaconIdNumber];
        NSData * itemPositionIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemPositionIdNumber];
        [userDefaults setObject:itemBeaconIdNumberData forKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
        [userDefaults setObject:itemPositionIdNumberData forKey:@"es.uam.miso/variables/itemPositionIdNumber"];
        
    }
    
    // Search for 'areTypes' boolean and if so, load the MDType array
    NSData * areTypesData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areTypes"];
    NSString * areTypes;
    if (areTypesData) {
        areTypes = [NSKeyedUnarchiver unarchiveObjectWithData:areTypesData];
    }
    if (areTypesData && areTypes && [areTypes isEqualToString:@"YES"]) {
        
    } else {
        // No saved data
        // TO DO: Ask user if demo types have to be loaded. Alberto J. 2020/01/27.
        
        // Create the types and its attributes
        MDType * cornerType = [[MDType alloc] initWithName:@"Corner"];
        
        MDType * wallType = [[MDType alloc] initWithName:@"Wall"];
        NSMutableArray * wallAttributes = [[NSMutableArray alloc] init];
        MDAttribute * wallHeightAttribute = [[MDAttribute alloc] initWithName:@"Height"];
        MDAttribute * wallWidthAttribute = [[MDAttribute alloc] initWithName:@"Width"];
        [wallAttributes addObject:wallHeightAttribute];
        [wallAttributes addObject:wallWidthAttribute];
        [wallType setAttributes:wallAttributes];
        
        MDType * doorType = [[MDType alloc] initWithName:@"Door"];
        NSMutableArray * doorAttributes = [[NSMutableArray alloc] init];
        MDAttribute * doorHeightAttribute = [[MDAttribute alloc] initWithName:@"Height"];
        MDAttribute * doorWidthAttribute = [[MDAttribute alloc] initWithName:@"Width"];
        [doorAttributes addObject:doorHeightAttribute];
        [doorAttributes addObject:doorWidthAttribute];
        [doorType setAttributes:doorAttributes];
        
        MDType * gatewayType = [[MDType alloc] initWithName:@"Gateway"];
        NSMutableArray * gatewayAttributes = [[NSMutableArray alloc] init];
        MDAttribute * gatewayHeightAttribute = [[MDAttribute alloc] initWithName:@"Height"];
        MDAttribute * gatewayWidthAttribute = [[MDAttribute alloc] initWithName:@"Width"];
        [gatewayAttributes addObject:gatewayHeightAttribute];
        [gatewayAttributes addObject:gatewayWidthAttribute];
        [gatewayType setAttributes:gatewayAttributes];
        
        MDType * deviceType = [[MDType alloc] initWithName:@"Device"];
        NSMutableArray * deviceAttributes = [[NSMutableArray alloc] init];
        MDAttribute * deviceOwnerAttribute = [[MDAttribute alloc] initWithName:@"Owner"];
        MDAttribute * deviceBrandAttribute = [[MDAttribute alloc] initWithName:@"Brand"];
        [deviceAttributes addObject:deviceOwnerAttribute];
        [deviceAttributes addObject:deviceBrandAttribute];
        [deviceType setAttributes:deviceAttributes];
        
        MDType * attendantType = [[MDType alloc] initWithName:@"Attendant"];
        NSMutableArray * attendantAttributes = [[NSMutableArray alloc] init];
        MDAttribute * attendantNameAttribute = [[MDAttribute alloc] initWithName:@"Name"];
        MDAttribute * attendantCredentialsAttribute = [[MDAttribute alloc] initWithName:@"Credentials"];
        [attendantAttributes addObject:attendantNameAttribute];
        [attendantAttributes addObject:attendantCredentialsAttribute];
        [attendantType setAttributes:attendantAttributes];
        
        MDType * entranceType = [[MDType alloc] initWithName:@"Entrance Gateway"];
        NSMutableArray * entranceAttributes = [[NSMutableArray alloc] init];
        MDAttribute * entranceHeightAttribute = [[MDAttribute alloc] initWithName:@"Width"];
        MDAttribute * entranceWidthAttribute = [[MDAttribute alloc] initWithName:@"Height"];
        MDAttribute * entranceScheduleAttribute = [[MDAttribute alloc] initWithName:@"Schedule"];
        [entranceAttributes addObject:entranceHeightAttribute];
        [entranceAttributes addObject:entranceWidthAttribute];
        [entranceAttributes addObject:entranceScheduleAttribute];
        [entranceType setAttributes:entranceAttributes];
        
        MDType * emergencyType = [[MDType alloc] initWithName:@"Emergency Gateway"];
        NSMutableArray * emergencyAttributes = [[NSMutableArray alloc] init];
        MDAttribute * emergencyHeightAttribute = [[MDAttribute alloc] initWithName:@"Width"];
        MDAttribute * emergencyWidthAttribute = [[MDAttribute alloc] initWithName:@"Height"];
        MDAttribute * emergencySecuredAttribute = [[MDAttribute alloc] initWithName:@"Secured"];
        [emergencyAttributes addObject:emergencyHeightAttribute];
        [emergencyAttributes addObject:emergencyWidthAttribute];
        [emergencyAttributes addObject:emergencySecuredAttribute];
        [emergencyType setAttributes:emergencyAttributes];
        
        MDType * securedAreaType = [[MDType alloc] initWithName:@"Secured Area"];
        NSMutableArray * securedAreaAttributes = [[NSMutableArray alloc] init];
        MDAttribute * securedAreaSecuredAttribute = [[MDAttribute alloc] initWithName:@"Secured"];
        [securedAreaAttributes addObject:securedAreaSecuredAttribute];
        [securedAreaType setAttributes:securedAreaAttributes];
        
        MDType * accessControlledAreaType = [[MDType alloc] initWithName:@"Access Controlled Area"];
        NSMutableArray * accessControlledAreaAttributes = [[NSMutableArray alloc] init];
        MDAttribute * capacityAttribute = [[MDAttribute alloc] initWithName:@"Capacity"];
        MDAttribute * accessControlledAreaAttribute = [[MDAttribute alloc] initWithName:@"Secured"];
        [accessControlledAreaAttributes addObject:capacityAttribute];
        [accessControlledAreaAttributes addObject:accessControlledAreaAttribute];
        [accessControlledAreaType setAttributes:accessControlledAreaAttributes];
        
        MDType * leisureAreaType = [[MDType alloc] initWithName:@"Leisure Area"];
        NSMutableArray * leisureAreaAttributes = [[NSMutableArray alloc] init];
        MDAttribute * activityAttribute = [[MDAttribute alloc] initWithName:@"Activity"];
        [leisureAreaAttributes addObject:activityAttribute];
        [leisureAreaType setAttributes:leisureAreaAttributes];
        
        MDType * equipmentType = [[MDType alloc] initWithName:@"Equipment"];
        NSMutableArray * equipmentAttributes = [[NSMutableArray alloc] init];
        MDAttribute * equipmentHeightAttribute = [[MDAttribute alloc] initWithName:@"Width"];
        MDAttribute * equipmentWidthAttribute = [[MDAttribute alloc] initWithName:@"Height"];
        MDAttribute * providerAttribute = [[MDAttribute alloc] initWithName:@"Provider"];
        [equipmentAttributes addObject:equipmentHeightAttribute];
        [equipmentAttributes addObject:equipmentWidthAttribute];
        [equipmentAttributes addObject:providerAttribute];
        [equipmentType setAttributes:equipmentAttributes];
        
        MDType * graphicalElementType = [[MDType alloc] initWithName:@"Graphical Element"];
        NSMutableArray * graphicalElementAttributes = [[NSMutableArray alloc] init];
        MDAttribute * graphicalElementHeightAttribute = [[MDAttribute alloc] initWithName:@"Width"];
        MDAttribute * graphicalElementWidthAttribute = [[MDAttribute alloc] initWithName:@"Height"];
        MDAttribute * textAttribute = [[MDAttribute alloc] initWithName:@"Text"];
        [graphicalElementAttributes addObject:graphicalElementHeightAttribute];
        [graphicalElementAttributes addObject:graphicalElementWidthAttribute];
        [graphicalElementAttributes addObject:textAttribute];
        [graphicalElementType setAttributes:graphicalElementAttributes];
        
        // Save them in persistent memory
        areTypesData = nil; // ARC disposing
        areTypesData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areTypesData forKey:@"es.uam.miso/data/metamodels/areTypes"];
        
        types = [[NSMutableArray alloc] init];
        [types addObject:cornerType];
        [types addObject:wallType];
        [types addObject:doorType];
        [types addObject:gatewayType];
        [types addObject:deviceType];
        [types addObject:attendantType];
        [types addObject:entranceType];
        [types addObject:emergencyType];
        [types addObject:securedAreaType];
        [types addObject:accessControlledAreaType];
        [types addObject:leisureAreaType];
        [types addObject:equipmentType];
        [types addObject:graphicalElementType];
        NSData * typesData = [NSKeyedArchiver archivedDataWithRootObject:types];
        [userDefaults setObject:typesData forKey:@"es.uam.miso/data/metamodels/types"];
        
        NSLog(@"[INFO][TBCC] No ontologycal types found in device; demo types saved.");
    }
    
    // Search for 'areMetamodels' boolean and if so, load the MDMetamodel array
    NSData * areMetamodelsData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    NSString * areMetamodels;
    if (areMetamodelsData) {
        areMetamodels = [NSKeyedUnarchiver unarchiveObjectWithData:areMetamodelsData];
    }
    if (areMetamodelsData && areMetamodels && [areMetamodels isEqualToString:@"YES"]) {
        
    } else {
        // No saved data
        // TO DO: Ask user if demo metamodels have to be loaded. Alberto J. 2020/01/27.
        
        // Create some modes to use the metamodels
        NSNumber * modeMonitorig = [NSNumber numberWithInt:0];
        NSNumber * modeRhoRho = [NSNumber numberWithInt:1];
        NSNumber * modeRhoTheta = [NSNumber numberWithInt:2];
        NSNumber * modeThetaTheta = [NSNumber numberWithInt:3];
        NSNumber * modeSelfRhoRho = [NSNumber numberWithInt:4];
        NSNumber * modeSelfRhoTheta = [NSNumber numberWithInt:5];
        NSNumber * modeSelfThetaTheta = [NSNumber numberWithInt:6];
        NSNumber * modeGPS = [NSNumber numberWithInt:7];
        NSNumber * modeHeading = [NSNumber numberWithInt:8];
        
        // Get types;
        MDType * cornerType = [types objectAtIndex:0];
        MDType * wallType = [types objectAtIndex:1];
        MDType * doorType = [types objectAtIndex:2];
        MDType * gatewayType = [types objectAtIndex:3];
        MDType * deviceType = [types objectAtIndex:4];
        MDType * attendantType = [types objectAtIndex:5];
        MDType * entranceType = [types objectAtIndex:6];
        MDType * emergencyType = [types objectAtIndex:7];
        MDType * securedAreaType = [types objectAtIndex:8];
        MDType * accessControlledAreaType = [types objectAtIndex:9];
        MDType * leisureAreaType = [types objectAtIndex:10];
        MDType * equipmentType = [types objectAtIndex:11];
        MDType * graphicalElementType = [types objectAtIndex:12];
        
        // Create the metamodel with a copy of types
        NSMutableArray * buildingTypes = [[NSMutableArray alloc] init];
        [buildingTypes addObject:cornerType];
        [buildingTypes addObject:wallType];
        [buildingTypes addObject:doorType];
        [buildingTypes addObject:gatewayType];
        NSMutableArray * buildingModes = [[NSMutableArray alloc] init];
        [buildingModes addObject:modeSelfRhoRho];
        [buildingModes addObject:modeGPS];
        [buildingModes addObject:modeHeading];
        MDMetamodel * buildingMetamodel = [[MDMetamodel alloc] initWithName:@"Building"
                                                                description:@"Building"
                                                                   andTypes:buildingTypes];
        [buildingMetamodel setModes:buildingModes];
        
        NSMutableArray * securityTypes = [[NSMutableArray alloc] init];
        [securityTypes addObject:entranceType];
        [securityTypes addObject:emergencyType];
        [securityTypes addObject:securedAreaType];
        [securityTypes addObject:accessControlledAreaType];
        NSMutableArray * securityModes = [[NSMutableArray alloc] init];
        [securityModes addObject:modeSelfRhoRho];
        MDMetamodel * securityMetamodel = [[MDMetamodel alloc] initWithName:@"Security"
                                                                description:@"Security"
                                                                   andTypes:securityTypes];
        [securityMetamodel setModes:securityModes];
        
        NSMutableArray * organizationTypes = [[NSMutableArray alloc] init];
        [organizationTypes addObject:leisureAreaType];
        [organizationTypes addObject:equipmentType];
        [organizationTypes addObject:graphicalElementType];
        NSMutableArray * organizationModes = [[NSMutableArray alloc] init];
        [organizationModes addObject:modeSelfRhoRho];
        MDMetamodel * organizationMetamodel = [[MDMetamodel alloc] initWithName:@"Organization"
                                                                    description:@"Organization"
                                                                       andTypes:organizationTypes];
        [organizationMetamodel setModes:organizationModes];
        
        NSMutableArray * attendantsTypes = [[NSMutableArray alloc] init];
        [attendantsTypes addObject:deviceType];
        [attendantsTypes addObject:attendantType];
        NSMutableArray * attendantsModes = [[NSMutableArray alloc] init];
        [attendantsModes addObject:modeSelfThetaTheta];
        MDMetamodel * attendantsMetamodel = [[MDMetamodel alloc] initWithName:@"Attendants"
                                                                    description:@"Attendants"
                                                                       andTypes:attendantsTypes];
        [attendantsMetamodel setModes:attendantsModes];
        
        // Save them in persistent memory
        areMetamodelsData = nil; // ARC disposing
        areMetamodelsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areMetamodelsData forKey:@"es.uam.miso/data/metamodels/areMetamodels"];
        metamodels = [[NSMutableArray alloc] init];
        [metamodels addObject:buildingMetamodel];
        [metamodels addObject:securityMetamodel];
        [metamodels addObject:organizationMetamodel];
        [metamodels addObject:attendantsMetamodel];
        NSData * metamodelsData = [NSKeyedArchiver archivedDataWithRootObject:metamodels];
        [userDefaults setObject:metamodelsData forKey:@"es.uam.miso/data/metamodels/metamodels"];
        
        NSLog(@"[INFO][TBCC] No metamodels found in device; demo metamodel saved.");
    }
    
    // Search for 'areItems' boolean and if so, load the items' NSMutableDictionary array
    NSData * areItemsData = [userDefaults objectForKey:@"es.uam.miso/data/items/areItems"];
    NSString * areItems;
    if (areItemsData) {
        areItems = [NSKeyedUnarchiver unarchiveObjectWithData:areItemsData];
    }
    // Retrieve or create each category of information
    if (areItemsData && areItems && [areItems isEqualToString:@"YES"]) {
        
    } else {
        // No saved data; register some items
        
        items = [[NSMutableArray alloc] init];
        MDType * cornerType = [[MDType alloc] initWithName:@"Corner"];
        MDType * deviceType = [[MDType alloc] initWithName:@"Device"];
        
        NSMutableDictionary * infoDic0 = [[NSMutableDictionary alloc] init];
        RDPosition * position0 = [[RDPosition alloc] init];
        position0.x = [NSNumber numberWithFloat:1.0];
        position0.y = [NSNumber numberWithFloat:1.0];
        position0.z = [NSNumber numberWithFloat:0.0];
        [infoDic0 setValue:@"position" forKey:@"sort"];
        [infoDic0 setValue:@"device@miso.uam.es" forKey:@"identifier"];
        [infoDic0 setValue:position0 forKey:@"position"];
        [infoDic0 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic0 setValue:deviceType forKey:@"type"];
        [items addObject:infoDic0];
        
        NSMutableDictionary * infoDic1 = [[NSMutableDictionary alloc] init];
        RDPosition * position1 = [[RDPosition alloc] init];
        position1.x = [NSNumber numberWithFloat:0.0];
        position1.y = [NSNumber numberWithFloat:0.0];
        position1.z = [NSNumber numberWithFloat:0.0];
        [infoDic1 setValue:@"position" forKey:@"sort"];
        [infoDic1 setValue:@"position1@miso.uam.es" forKey:@"identifier"];
        [infoDic1 setValue:position1 forKey:@"position"];
        [infoDic1 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic1 setValue:cornerType forKey:@"type"];
        [items addObject:infoDic1];
        
        NSMutableDictionary * infoDic2 = [[NSMutableDictionary alloc] init];
        RDPosition * position2 = [[RDPosition alloc] init];
        position2.x = [NSNumber numberWithFloat:3.5];
        position2.y = [NSNumber numberWithFloat:0.0];
        position2.z = [NSNumber numberWithFloat:0.0];
        [infoDic2 setValue:@"position" forKey:@"sort"];
        [infoDic2 setValue:@"position2@miso.uam.es" forKey:@"identifier"];
        [infoDic2 setValue:position2 forKey:@"position"];
        [infoDic2 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic2 setValue:cornerType forKey:@"type"];
        [items addObject:infoDic2];
        
        NSMutableDictionary * infoDic3 = [[NSMutableDictionary alloc] init];
        RDPosition * position3 = [[RDPosition alloc] init];
        position3.x = [NSNumber numberWithFloat:3.5];
        position3.y = [NSNumber numberWithFloat:-13.0];
        position3.z = [NSNumber numberWithFloat:0.0];
        [infoDic3 setValue:@"position" forKey:@"sort"];
        [infoDic3 setValue:@"position3@miso.uam.es" forKey:@"identifier"];
        [infoDic3 setValue:position3 forKey:@"position"];
        [infoDic3 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic3 setValue:cornerType forKey:@"type"];
        [items addObject:infoDic3];
        
        NSMutableDictionary * infoDic4 = [[NSMutableDictionary alloc] init];
        RDPosition * position4 = [[RDPosition alloc] init];
        position4.x = [NSNumber numberWithFloat:0.0];
        position4.y = [NSNumber numberWithFloat:-13.0];
        position4.z = [NSNumber numberWithFloat:0.0];
        [infoDic4 setValue:@"position" forKey:@"sort"];
        [infoDic4 setValue:@"position4@miso.uam.es" forKey:@"identifier"];
        [infoDic4 setValue:position4 forKey:@"position"];
        [infoDic4 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic4 setValue:cornerType forKey:@"type"];
        [items addObject:infoDic4];
        
        NSMutableDictionary * infoRegionRaspiDic = [[NSMutableDictionary alloc] init];
        [infoRegionRaspiDic setValue:@"beacon" forKey:@"sort"];
        [infoRegionRaspiDic setValue:@"raspi@miso.uam.es" forKey:@"identifier"];
        [infoRegionRaspiDic setValue:@"25DC8A73-F3C9-4111-A7DD-C39CD4B828C7" forKey:@"uuid"];
        [infoRegionRaspiDic setValue:@"1" forKey:@"major"];
        [infoRegionRaspiDic setValue:@"0" forKey:@"minor"];
        [items addObject:infoRegionRaspiDic];
        
        NSMutableDictionary * infoItemBeacon1Dic = [[NSMutableDictionary alloc] init];
        [infoItemBeacon1Dic setValue:@"beacon" forKey:@"sort"];
        [infoItemBeacon1Dic setValue:@"beacon1@miso.uam.es" forKey:@"identifier"];
        [infoItemBeacon1Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825" forKey:@"uuid"];
        [infoItemBeacon1Dic setValue:@"1" forKey:@"major"];
        [infoItemBeacon1Dic setValue:@"1" forKey:@"minor"];
        [items addObject:infoItemBeacon1Dic];
        
        NSMutableDictionary * infoItemBeacon2Dic = [[NSMutableDictionary alloc] init];
        [infoItemBeacon2Dic setValue:@"beacon" forKey:@"sort"];
        [infoItemBeacon2Dic setValue:@"beacon2@miso.uam.es" forKey:@"identifier"];
        [infoItemBeacon2Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647824" forKey:@"uuid"];
        [infoItemBeacon2Dic setValue:@"1" forKey:@"major"];
        [infoItemBeacon2Dic setValue:@"1" forKey:@"minor"];
        [items addObject:infoItemBeacon2Dic];
        
        NSMutableDictionary * infoItemBeacon3Dic = [[NSMutableDictionary alloc] init];
        [infoItemBeacon3Dic setValue:@"beacon" forKey:@"sort"];
        [infoItemBeacon3Dic setValue:@"beacon3@miso.uam.es" forKey:@"identifier"];
        [infoItemBeacon3Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647823" forKey:@"uuid"];
        [infoItemBeacon3Dic setValue:@"1" forKey:@"major"];
        [infoItemBeacon3Dic setValue:@"1" forKey:@"minor"];
        [items addObject:infoItemBeacon3Dic];
        
        
        // Save them in persistent memory
        areItemsData = nil; // ARC disposing
        areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areItemsData forKey:@"es.uam.miso/data/items/areItems"];
        
        // Create de index in which names if items will be saved for retrieve them later
        NSMutableArray * itemsIndex = [[NSMutableArray alloc] init];
        for (NSMutableDictionary * item in items) {
            // Item's name
            NSString * itemIdentifier = item[@"identifier"];
            // Save the name in the index
            [itemsIndex addObject:itemIdentifier];
            // Create the item's data and archive it
            NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:item];
            NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
            [userDefaults setObject:itemData forKey:itemKey];
        }
        // ...and save the key
        NSData * itemsIndexData = [NSKeyedArchiver archivedDataWithRootObject:itemsIndex];
        [userDefaults setObject:itemsIndexData forKey:@"es.uam.miso/data/items/index"];
        
        NSLog(@"[INFO][TBCC] No items found in device; demo items saved.");
        
    }
    
    // Get views instances
    NSArray * viewControllers = [self viewControllers];
    for (UIViewController * view in viewControllers) {
        
        // Depending on the view, pass different variables or set a different tab icon
        NSString * viewClass = NSStringFromClass([view class]);
        if ([viewClass containsString:@"Types"]){
            viewControllerConfigurationTypes = (ViewControllerConfigurationTypes*)view;
            
            // Pass the variables as in segues
            [viewControllerConfigurationTypes setUserDic:userDic];
            [viewControllerConfigurationTypes setCredentialsUserDic:credentialsUserDic];
            [viewControllerConfigurationTypes setTabBar:self];
            
            // Configure the tab icon
            UITabBarItem * modesTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                           image:[UIImage imageNamed:@"type.png"]
                                                                             tag:2];
            [viewControllerConfigurationTypes setTabBarItem:modesTabBarItem];
            
        }
        if ([viewClass containsString:@"Metamodels"]){
            viewControllerConfigurationMetamodels = (ViewControllerConfigurationMetamodels*)view;
            
            // Pass the variables as in segues
            [viewControllerConfigurationMetamodels setUserDic:userDic];
            [viewControllerConfigurationMetamodels setCredentialsUserDic:credentialsUserDic];
            [viewControllerConfigurationMetamodels setTabBar:self];
            
            // Configure the tab icon
            UITabBarItem * metamodelTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                               image:[UIImage imageNamed:@"metamodel.png"]
                                                                                 tag:1];
            [viewControllerConfigurationMetamodels setTabBarItem:metamodelTabBarItem];
        }
        if ([viewClass containsString:@"Modes"]){
            viewControllerConfigurationModes = (ViewControllerConfigurationModes*)view;
            
            // Pass the variables as in segues
            [viewControllerConfigurationModes setUserDic:userDic];
            [viewControllerConfigurationModes setCredentialsUserDic:credentialsUserDic];
            [viewControllerConfigurationModes setTabBar:self];
            
            // Configure the tab icon
            UITabBarItem * modesTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                           image:[UIImage imageNamed:@"routine.png"]
                                                                             tag:2];
            [viewControllerConfigurationModes setTabBarItem:modesTabBarItem];
            
        }
        if ([viewClass containsString:@"Beacons"]){
            viewControllerConfigurationBeacons = (ViewControllerConfigurationBeacons*)view;
            
            // Pass the variables as in segues
            [viewControllerConfigurationBeacons setUserDic:userDic];
            [viewControllerConfigurationBeacons setCredentialsUserDic:credentialsUserDic];
            [viewControllerConfigurationBeacons setTabBar:self];
            
            // Configure the tab icon
            UITabBarItem * modesTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                           image:[UIImage imageNamed:@"beacon.png"]
                                                                             tag:2];
            [viewControllerConfigurationBeacons setTabBarItem:modesTabBarItem];
            
        }
        
    }
}

/*!
 @method didReceiveMemoryWarning
 @discussion This method dispose of any resources that can be recreated id a memory warning is recived.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance methods
/*!
 @method setCredentialsUserDic:
 @discussion This method sets the NSMutableDictionary with the security purposes user credentials.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    credentialsUserDic = givenCredentialsUserDic;
}

/*!
 @method setUserDic:
 @discussion This method sets the NSMutableDictionary with the identifying purposes user credentials.
 */
- (void) setUserDic:(NSMutableDictionary *)givenUserDic
{
    userDic = givenUserDic;
}

#pragma mark - Event methods handlers
/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCCT] Asked segue %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"fromConfigurationToLogin"]) {
        
        // Get destination view
        ViewControllerLogin * viewControllerLogin = [segue destinationViewController];
        // Set the variable
        [viewControllerLogin setCredentialsUserDic:credentialsUserDic];
        [viewControllerLogin setUserDic:userDic];
    }
}

#pragma mark - UITabBarControllerDelegate delegated methods
/*!
 @method tabBarController:didSelectViewController:
 @discussion This method handles the event of changing between tabs.
 */
- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    if (viewController == viewControllerConfigurationTypes) {
        [viewControllerConfigurationTypes viewDidLoad];
    }
    if (viewController == viewControllerConfigurationMetamodels) {
        [viewControllerConfigurationMetamodels viewDidLoad];
    }
    if (viewController == viewControllerConfigurationModes) {
        [viewControllerConfigurationModes viewDidLoad];
    }
    if (viewController == viewControllerConfigurationBeacons) {
        [viewControllerConfigurationBeacons viewDidLoad];
    }
}

@end
