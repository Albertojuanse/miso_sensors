//
//  ViewControllerConfiguration.m
//  Sensors test
//
//  Created by Alberto J. on 23/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerConfigurationModes.h"

@implementation ViewControllerConfigurationModes

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Preventing previous view variables' values due to tab controller lifecycle
    metamodels = nil;
    
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.5
                                    ];
    
    // Submit demo metamodel if it does not exist
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    // Search for 'areMetamodels' boolean and if so, load the MDMetamodel array
    NSData * areMetamodelsData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    NSString * areMetamodels;
    if (areMetamodelsData) {
        areMetamodels = [NSKeyedUnarchiver unarchiveObjectWithData:areMetamodelsData];
    }
    if (areMetamodelsData && areMetamodels && [areMetamodels isEqualToString:@"YES"]) {
        // Existing saved metamodsels
        
        // Retrieve the metamodels array
        NSData * metamodelsData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/metamodels"];
        metamodels = [NSKeyedUnarchiver unarchiveObjectWithData:metamodelsData];
        
        NSLog(@"[INFO][VCCM] %tu metamodels found in device.", metamodels.count);
    } else {
        NSLog(@"[ERROR][VCCM] No metamodels found in device; demo metamodel saved.");
    }
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableMetamodels.delegate = self;
    self.tableMetamodels.dataSource = self;
    self.tableModes.delegate = self;
    self.tableModes.dataSource = self;
    
    [self.tableMetamodels reloadData];
    [self.tableModes reloadData];
}

/*!
 @method viewDidAppear:
 @discussion This method notifies the view controller that its view was added to a view hierarchy.
 */
- (void)viewDidAppear:(BOOL)animated
{
    
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

#pragma mark - UItableView data delegate methods
/*!
 @method numberOfSectionsInTableView:
 @discussion Handles the upload of tables; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableMetamodels) {
        // A section for each metamodel
        return metamodels.count;
    }
    if (tableView == self.tableModes) {
        // A section for all modes
        return 1;
    }
    return 0;
}

/*!
 @method tableView:numberOfRowsInSection:
 @discussion Handles the upload of tables; returns the number of items in them.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableMetamodels) {
        
        // Get each metamodel and return the number of modes used
        MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
        NSMutableArray * eachModes = [eachMetamodel getModes];
        if (eachModes.count == 0) {
            
            // If the metamodel is empty, create a dummy cell...
            // ...unless the dummy cell itself is being deleted; iOS needs consistency to delete cells)
            if (!removingFirstCell) {
                return 1;
            } else {
                return 0;
            }
            
        } else {
           return eachModes.count;
        }
        
    }
    if (tableView == self.tableModes) {
        // A cell for each mode
        return kModesCount;
    }
    return 0;
}

/*!
 @method tableView:titleForHeaderInSection:
 @discussion Handles the upload of tables; returns each section title.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableMetamodels) {
        // Get the name of each metamodel
        MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
        return [eachMetamodel getName];
    }
    if (tableView == self.tableModes) {
        // No sections for modes
        return @"All modes";
    }
    return nil;
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure individual cells
    if (tableView == self.tableMetamodels) {
        
        
        // Get the metamodel that shows this section...
        MDMetamodel * eachMetamodel = [metamodels objectAtIndex:indexPath.section];
        
        // ...and get each of its modes.
        NSMutableArray * eachModes = [eachMetamodel getModes];
        if (eachModes.count == 0) {
            // If the metamodel is empty, create a dummy cell.
            cell.textLabel.text = [NSString stringWithFormat:@"⇥"];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        } else {
            NSNumber * eachMode = [[eachMetamodel getModes] objectAtIndex:indexPath.row];
            MDMode * mode = [[MDMode alloc] initWithModeKey:[eachMode integerValue]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", mode];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
        
    }
    if (tableView == self.tableModes) {
        MDMode * mode = [[MDMode alloc] initWithModeKey:(int)indexPath.row];
        cell.textLabel.text = [mode description];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return cell;
}

@end
