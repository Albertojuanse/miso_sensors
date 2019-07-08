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
    
    // Variables
    modes = [[NSMutableArray alloc] init];
    [modes addObject:@"RHO_RHO_MODELLING"];
    [modes addObject:@"RHO_THETA_MODELLING"];
    [modes addObject:@"THETA_THETA_MODELLING"];
    [modes addObject:@"RHO_RHO_LOCATING"];
    [modes addObject:@"RHO_THETA_LOCATING"];
    [modes addObject:@"THETA_THETA_LOCATING"];
    
    beaconsRegistered = [[NSMutableArray alloc] init];
    regionIdNumber = [NSNumber numberWithInteger:3];
    // Pre-registered regions
    NSMutableDictionary * regionRaspiDic = [[NSMutableDictionary alloc] init];
    [regionRaspiDic setValue:@"25DC8A73-F3C9-4111-A7DD-C39CD4B828C7" forKey:@"uuid"];
    [regionRaspiDic setValue:@"1" forKey:@"major"];
    [regionRaspiDic setValue:@"0" forKey:@"minor"];
    [regionRaspiDic setValue:@"raspi@miso.uam.es" forKey:@"identifier"];
    [beaconsRegistered addObject:regionRaspiDic];
    NSMutableDictionary * regionBeacon1Dic = [[NSMutableDictionary alloc] init];
    [regionBeacon1Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825" forKey:@"uuid"];
    [regionBeacon1Dic setValue:@"1" forKey:@"major"];
    [regionBeacon1Dic setValue:@"1" forKey:@"minor"];
    [regionBeacon1Dic setValue:@"beacon1@miso.uam.es" forKey:@"identifier"];
    [beaconsRegistered addObject:regionBeacon1Dic];
    NSMutableDictionary * regionBeacon2Dic = [[NSMutableDictionary alloc] init];
    [regionBeacon2Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647824" forKey:@"uuid"];
    [regionBeacon2Dic setValue:@"1" forKey:@"major"];
    [regionBeacon2Dic setValue:@"1" forKey:@"minor"];
    [regionBeacon2Dic setValue:@"beacon2@miso.uam.es" forKey:@"identifier"];
    [beaconsRegistered addObject:regionBeacon2Dic];
    NSMutableDictionary * regionBeacon3Dic = [[NSMutableDictionary alloc] init];
    [regionBeacon3Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647823" forKey:@"uuid"];
    [regionBeacon3Dic setValue:@"1" forKey:@"major"];
    [regionBeacon3Dic setValue:@"1" forKey:@"minor"];
    [regionBeacon3Dic setValue:@"beacon3@miso.uam.es" forKey:@"identifier"];
    [beaconsRegistered addObject:regionBeacon3Dic];
    
    // Visualization
    
    // Table delegates; the delegate methods for attending these tables are part of this class
    self.tableModes.delegate = self;
    self.tableBeacons.delegate = self;
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addBeacon:)
                                                 name:@"handleButtonAdd"
                                               object:nil];
    
}
    
#pragma mark - UItableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableBeacons) {
        return [beaconsRegistered count];
    }
    if (tableView == self.tableModes) {
        return [modes count];
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
    if (tableView == self.tableBeacons) {
        NSMutableDictionary * regionDic = [beaconsRegistered objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ ; major: %@ ; minor: %@",
                               regionDic[@"identifier"],
                               regionDic[@"uuid"],
                               regionDic[@"major"],
                               regionDic[@"minor"]
                               ];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    if (tableView == self.tableModes) {
        cell.textLabel.text = [modes objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    return cell;
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
    if ([[notification name] isEqualToString:@"handleButtonAdd"]){
        NSLog(@"[NOTI][VC] Notification \"handleButtonAdd\" recived");
        
        // Get data from form
        NSMutableDictionary *data = notification.userInfo;
        NSString * uuid = [data objectForKey:@"uuid"];
        NSString * major = [data objectForKey:@"major"];
        NSString * minor = [data objectForKey:@"minor"];
        
        BOOL regionFound = NO;
        for (NSMutableDictionary * regionDic in beaconsRegistered) {
            if ([uuid isEqualToString:regionDic[@"uuid"]]) {
                if ([major isEqualToString:regionDic[@"major"]]) {
                    if ([minor isEqualToString:regionDic[@"minor"]]) {
                        regionFound = YES;
                    }
                }
            }
        }
        if (!regionFound)
        {
            NSMutableDictionary * regionBeaconDic = [[NSMutableDictionary alloc] init];
            [regionBeaconDic setValue:uuid forKey:@"uuid"];
            [regionBeaconDic setValue:major forKey:@"major"];
            [regionBeaconDic setValue:minor forKey:@"minor"];
            regionIdNumber = [NSNumber numberWithInt:[regionIdNumber intValue] + 1];
            NSString * regionId = [@"beacon" stringByAppendingString:[regionIdNumber stringValue]];
            regionId = [@"beacon" stringByAppendingString:@"@miso.uam.es"];
            [regionBeaconDic setValue:regionId forKey:@"identifier"];
            [beaconsRegistered addObject:regionBeaconDic];
        }
        [self.tableBeacons reloadData];
    }
}

@end
