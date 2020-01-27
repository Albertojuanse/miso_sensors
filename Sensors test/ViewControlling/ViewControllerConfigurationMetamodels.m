//
//  ViewControllerConfigurationMetamodels.m
//  Sensors test
//
//  Created by Alberto J. on 24/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerConfigurationMetamodels.h"
#import "MDMetamodel.h"
#import "MDType.h"

@implementation ViewControllerConfigurationMetamodels

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.5
                                    ];
    
    // Load existing types and metamodels in the device
    @"es.uam.miso/data/metamodels/areTypes"
    @"es.uam.miso/data/metamodels/areMetamodels"
    @"es.uam.miso/data/metamodels/types"
    @"es.uam.miso/data/metamodels/metamodels"
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Search for 'areTypes' boolean and if so, load the MDType array
    NSData * areTypesData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areTypes"];
    NSString * areTypes;
    if (areTypesData) {
        areTypes = [NSKeyedUnarchiver unarchiveObjectWithData:areTypesData];
    }
    if (areTypesData && areTypes && [areTypes isEqualToString:@"YES"]) {
        // Existing saved types
        
        // Retrieve the types MDType array
        NSData * typesData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/types"];
        types = [NSKeyedUnarchiver unarchiveObjectWithData:typesData];
        
        NSLog(@"[INFO][VCCM] %tu ontologycal types found in device.", types.count);
    } else {
        // No saved data
        // TO DO: Ask user if demo types have to be loaded. Alberto J. 2020/01/27.
        
        // Create the types
        MDType * noType = [[MDType alloc] initWithName:@"<No type>"];
        MDType * cornerType = [[MDType alloc] initWithName:@"Corner"];
        MDType * deviceType = [[MDType alloc] initWithName:@"Device"];
        MDType * wallType = [[MDType alloc] initWithName:@"Wall"];
        
        // Save them in persistent memory
        areTypesData = nil; // ARC disposing
        areTypesData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areTypesData forKey:@"es.uam.miso/data/metamodels/areTypes"];
        
        types = [[NSMutableArray alloc] init];
        [types addObject:noType];
        [types addObject:cornerType];
        [types addObject:deviceType];
        [types addObject:wallType];
        NSData * typesData = [NSKeyedArchiver archivedDataWithRootObject:types];
        [userDefaults setObject:typesData forKey:@"es.uam.miso/data/metamodels/types"];
        
        NSLog(@"[INFO][VCCM] No ontologycal types found in device; demo types saved.");
    }
    
    // Search for 'areMetamodels' boolean and if so, load the MDMetamodel array
    NSData * areMetamodelsData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    NSString * areMetamodels;
    if (areMetamodelsData) {
        areMetamodels = [NSKeyedUnarchiver unarchiveObjectWithData:areMetamodelsData];
    }
    if (areMetamodelData && areMetamodel && [areMetamodel isEqualToString:@"YES"]) {
        // Existing saved metamodsels
        
        // Retrieve the metamodels array
        NSData * metamodelData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/metamodels"];
        metamodels = [NSKeyedUnarchiver unarchiveObjectWithData:metamodelData];
        
        NSLog(@"[INFO][VCCM] %tu metamodels found in device.", metamodels.count);
    } else {
        // No saved data
        // TO DO: Ask user if demo metamodels have to be loaded. Alberto J. 2020/01/27.
        
        // Create the metamodel with a copy of types
        NSMutableArray * metamodelTypes = [[NSMutableArray alloc] init];
        for (MDType * type in types) {
            [metamodelTypes addObject:type];
        }
        MDMetamodel * buildingMetamodel = [[MDMetamodel alloc] initWithName:@"Building"
                                                                description:@"Building"
                                                                   andTypes:metamodelTypes];
        
        // Save them in persistent memory
        areMetamodelData = nil; // ARC disposing
        areMetamodelData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areMetamodelData forKey:@"es.uam.miso/data/metamodels/areMetamodels"];
        metamodels = [[NSMutableArray alloc] init];
        [metamodels addObject:buildingMetamodel];
        NSData * metamodelData = [NSKeyedArchiver archivedDataWithRootObject:metamodels];
        [userDefaults setObject:metamodelData forKey:@"es.uam.miso/data/metamodels/metamodels"];
        
        NSLog(@"[INFO][VCCM] No metamodels found in device; demo metamodel saved.");
    }

    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableMetamodels.delegate = self;
    self.tableMetamodels.dataSource = self;
    self.tableTypes.delegate = self;
    self.tableTypes.dataSource = self;
    
    [self.tableMetamodels reloadData];
    [self.tableTypes reloadData];

    // Table gestures for drag and drop
    self.tableMetamodels.dragInteractionEnabled = true;
    self.tableTypes.dragInteractionEnabled = true;
    self.tableMetamodels.dragDelegated = self;
    self.tableTypes.dragDelegated = self;
    self.tableMetamodels.dropDelegated = self;
    self.tableTypes.dropDelegated = self;
    
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
        // One extra for "new item" row
        return metamodels.count + 1;
    }
    if (tableView == self.tableTypes) {
	// No sections for types
        return 0;
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
	// Get the types in each metamodel and count its types
        
        // Check if this section is the extra one for "new item"
        if (section > metamodels.count) {
            return 1;
        } else {
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
	    NSMutableArray * eachTypes = [eachMetamodel getTypes];
            return eachTypes.count;
        }
    }
    if (tableView == self.tableTypes) {
        // Show a cell for each type
        // One extra for "new item" row
        return types.count + 1;
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

        // Check if this section is the extra one for "new item"
        if (section > metamodels.count) {
            return @"New metamodel";
        } else {
            // Get the name of each metamodel
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
            return [eachMetamodel getName];
        }
    }
    if (tableView == self.tableTypes) {
	// No sections for types
        return nil;
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
        
        // Check if this section is the extra one for "new item"
        if (indexPath.section > metamodels.count) {
            cell.textLabel.text = [NSString stringWithFormat:@"+"];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        } else {
            // Get the metamodel that shows this section...
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:indexPath.section];
        
            // ...and get each of its types.
            MDType * eachType = [[eachType getTypes] objectAtIndex:indexPath.row];
            NSString * eachTypeName = [eachType getName];
            cell.textLabel.text = [NSString stringWithFormat:@"<%@>", eachTypeName];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        }

        
        
    }
    if (tableView == self.tableTypes) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.row > types.count) {
            cell.textLabel.text = [NSString stringWithFormat:@"+"];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        } else {
            MDType * eachType = [types objectAtIndex:indexPath.row];
            NSString * eachTypeName = [eachType getName];
            cell.textLabel.text = [NSString stringWithFormat:@"<%@>", eachTypeName];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        }
    }
    return cell;
}

/*!
 @method tableView:didSelectRowAtIndexPath:
 @discussion Handles the upload of tables; handles the 'select a cell' action.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableMetamodels) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.section > metamodels.count) {
            [self newMetamodel];
        }

    }
    if (tableView == self.tableTypes) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.row > types.count) {
            [self newItem];
        }

    }
}

#pragma mark - UItableView dragging delegate methods
/*!
 @method tableView:itemsForBeginningDragSession:atIndexPath:
 @discussion Handles the upload of tables; returns the initial set of items for a drag and drop session.
 */
- (NSArray<UIDrag Item *> *)tableView:(UITableView *)tableView
         itemsForBeginningDragSession:(id<UIDragSession>)session
                          atIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableMetamodels) {
        // Return an empety array since these ones cannot be dragged
        NSLog(@"[INFO][VCCM] User did try to start drag and drop, but this table is not allowed to do so.");
	return [[NSArray alloc] init];

    }
    if (tableView == self.tableTypes) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.row > types.count) {
            // Return an empty array since this one cannot be dragged
            NSLog(@"[INFO][VCCM] User did try to start drag and drop, but 'new item' row is not allowed to do so.");
	    return [[NSArray alloc] init];

        } else {
            // Return the array with the initial set of items to drag
	    MDType * cellsType = [types objectAtIndex:indexPath.row];
	    NSItemProvider * typeItemProvider = [[NSItemProvider alloc] initWithObject:itemProvider];
	    UIDragItem * typeDragItem = [[UIDragItem alloc] initWithItemProvider:typeItemProvider];
            NSLog(@"[INFO][VCCM] User did start drag and drop; item %@ provided", cellsType);
	    return [[NSArray alloc] initWithObjects:typeDragItem,nil];
        }

    }
    return [[NSArray alloc] init];
}

/*!
 @method tableView:canHandleDropSession:
 @discussion Handles the upload of tables; cheks if the destination table can handle a drag and drop session.
 */
- (BOOL)tableView:(UITableView *)tableView
canHandleDropSession:(id<UIDragSession>)session
{
    if (tableView == self.tableMetamodels) {
                
        // This table can only handle drops of MDType classes.
        if (session.items.count == 1) {
            NSLog(@"[INFO][VCCM] Allowed to drop provided item in this cell.");
            return YES;           
	} else {
            NSLog(@"[INFO][VCCM] Not allowed to drop provided item in this cell.");
            return NO;   
	}

    }
    if (tableView == self.tableTypes) {     
        // This table cannot be target of any drag and drop
        NSLog(@"[INFO][VCCM] Not allowed to drop provided item in this table.");
        return NO;
    }
    return NO;
}

/*!
 @method tableView:dropSessionDidUpdate:withDestinationIndexPath:
 @discussion Handles the upload of tables; propose how the destination table handles a drag and drop session.
 */
- (UITableViewDropProposal *)tableView:(UITableView *)tableView
                  dropSessionDidUpdate:(id<UIDropSession>)session
              withDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (tableView == self.tableMetamodels) {
                
        // This table can only handle drops of MDType classes.
        if (session.items.count == 1) {

            UITableViewDropProposal * proposal;

            // Check if this section is the extra one for "new item"
            if (indexPath.section > metamodels.count) {
                // Return a forbidden proposal
                NSLog(@"[INFO][VCCM] Proposed not to allow user to drop provided item in this cell.");
                proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperation.forbidden
                                                                           intent:UITableViewDropProposal.Intent.unspecified];
            } else {
                // Return a copy and insert proposal
                NSLog(@"[INFO][VCCM] Proposed allow user to drop (copy and insert) provided item in this cell.");
                proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperation.copy
                                                                           intent:UITableViewDropProposal.Intent.insertIntoDestinationIndezPath];
            }
	    return proposal;
            
	} else { 
            return nil;   
	}

    }
    if (tableView == self.tableTypes) {
        
        // This table cannot be target of any drag and drop
        // Return a forbidden proposal
        NSLog(@"[INFO][VCCM] Proposed not to allow user to drop provided item in this table.");
        proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperation.forbidden
                                                                   intent:UITableViewDropProposal.Intent.unspecified];
    }
    NSLog(@"[INFO][VCCM] By default proposed not to allow user to drop provided item in this table.");
    proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperation.forbidden
                                                               intent:UITableViewDropProposal.Intent.unspecified];
}

/*!
 @method tableView:performDropWithCoordinator:
 @discussion Handles the upload of tables; propose how the destination table handles a drag and drop session.
 */
- (void)tableView:(UITableView *)tableView
performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator
{
    // Decide an indexPath for the new cell depending on user's droping selection
    NSIndexPath * userDropingIndexPath = coordinator.destinationIndexPath;
    NSInteger section = userDropingIndexPath.section;
    if (section > metamodel.count) {
        NSLog(@"[INFO][VCCM] User did droppped in the 'new item' cell.");
        return;
    } else {
        NSLog(@"[INFO][VCCM] User did droppped the provided item.");
    }
    MDMetamodel * userDropingMetamodel = [metamodels objectAtIndex:section];
    NSInteger row = [[userDropingMetamodel getTypes] count];

    // Get provided items from drag and drop session
    UIDropSession * session = coordinator.session;
    NSProgress * loadingProgress = [session loadObjectsOfClass:[MDType class]
                                                    completion:^(NSArray * objects) {
                          MDType * cellType = [objects objectAtIndex:0];
                          if (objects.count != 1) {
                              NSLog(@"[ERROR][VCCM] More than one provided items from drop session; using first one.");
                          }
                          NSLog(@"[INFO][VCCM] Loaded provided item %@.", cellType);

                          // Update metamodel
                          [userDropingMetamodel addType:cellType];
                      }
                     ];
    // Reload data
    [self.tableMetamodels reloadData];

}

#pragma mark - New types and metamodels


@end
