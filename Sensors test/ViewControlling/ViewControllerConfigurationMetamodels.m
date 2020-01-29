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
        MDType * doorType = [[MDType alloc] initWithName:@"Door"];
        
        // Save them in persistent memory
        areTypesData = nil; // ARC disposing
        areTypesData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areTypesData forKey:@"es.uam.miso/data/metamodels/areTypes"];
        
        types = [[NSMutableArray alloc] init];
        [types addObject:noType];
        [types addObject:cornerType];
        [types addObject:deviceType];
        [types addObject:wallType];
        [types addObject:doorType];
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
    if (areMetamodelsData && areMetamodels && [areMetamodels isEqualToString:@"YES"]) {
        // Existing saved metamodsels
        
        // Retrieve the metamodels array
        NSData * metamodelsData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/metamodels"];
        metamodels = [NSKeyedUnarchiver unarchiveObjectWithData:metamodelsData];
        
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
        NSMutableArray * metamodel2Types = [metamodelTypes mutableCopy];
        [metamodel2Types removeLastObject];
        MDMetamodel * building2Metamodel = [[MDMetamodel alloc] initWithName:@"Building2"
                                                                description:@"Building2"
                                                                   andTypes:metamodel2Types];
        
        // Save them in persistent memory
        areMetamodelsData = nil; // ARC disposing
        areMetamodelsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areMetamodelsData forKey:@"es.uam.miso/data/metamodels/areMetamodels"];
        metamodels = [[NSMutableArray alloc] init];
        [metamodels addObject:buildingMetamodel];
        [metamodels addObject:building2Metamodel];
        NSData * metamodelsData = [NSKeyedArchiver archivedDataWithRootObject:metamodels];
        [userDefaults setObject:metamodelsData forKey:@"es.uam.miso/data/metamodels/metamodels"];
        
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
    self.tableMetamodels.dragDelegate = self;
    self.tableTypes.dragDelegate = self;
    self.tableMetamodels.dropDelegate = self;
    self.tableTypes.dropDelegate = self;
    
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
	// Get the types in each metamodel and count its types
        
        // Check if this section is the extra one for "new item"
        if (section > metamodels.count - 1) {
            return 1;
        } else {
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
            NSMutableArray * eachTypes = [eachMetamodel getTypes];
            NSLog(@"[HOLA] Metamodel %@ have %tu items",eachMetamodel, eachTypes.count);
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
        if (section > metamodels.count - 1) {
            return @"New metamodel";
        } else {
            // Get the name of each metamodel
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
            return [eachMetamodel getName];
        }
    }
    if (tableView == self.tableTypes) {
	// No sections for types
        return @"All types";
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
        if (indexPath.section > metamodels.count - 1) {
            NSLog(@"[HOLA] Section %td, Row %td labeled with +",indexPath.section ,indexPath.row);
            cell.textLabel.text = [NSString stringWithFormat:@"+"];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        } else {
            // Get the metamodel that shows this section...
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:indexPath.section];
        
            // ...and get each of its types.
            MDType * eachType = [[eachMetamodel getTypes] objectAtIndex:indexPath.row];
            NSString * eachTypeName = [eachType getName];
            NSLog(@"[HOLA] Section %td, Row %td labeled with <%@>",indexPath.section ,indexPath.row, [eachType getName]);
            cell.textLabel.text = [NSString stringWithFormat:@"<%@>", eachTypeName];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        }
        
    }
    if (tableView == self.tableTypes) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.row > types.count - 1) {
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
        if (indexPath.section > metamodels.count - 1) {
            [self newMetamodel];
            [self updatePersistentMetamodels];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            //@"es.uam.miso/data/metamodels/areTypes"
            //@"es.uam.miso/data/metamodels/areMetamodels"
            //@"es.uam.miso/data/metamodels/types"
            //@"es.uam.miso/data/metamodels/metamodels"
        }

    }
    if (tableView == self.tableTypes) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.row > types.count - 1) {
            [self newType];
            [self updatePersistentTypes];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        } else { // If not, ask to remove item from metamodel
            [self removeType];
            [self updatePersistentTypes];
        }

    }
}

#pragma mark - UItableView drag and drop delegate methods
/*!
 @method tableView:itemsForBeginningDragSession:atIndexPath:
 @discussion Handles drag and drop gestures between tables; returns the initial set of items for a drag and drop session.
 */
- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView
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
        if (indexPath.row > types.count - 1) {
            // Return an empty array since this one cannot be dragged
            NSLog(@"[INFO][VCCM] User did try to start drag and drop, but 'new item' row is not allowed to do so.");
            return [[NSArray alloc] init];

        } else {
            // Return the array with the initial set of items to drag
            MDType * cellsType = [types objectAtIndex:indexPath.row];
            NSItemProvider * typeItemProvider = [[NSItemProvider alloc] initWithObject:cellsType];
            UIDragItem * typeDragItem = [[UIDragItem alloc] initWithItemProvider:typeItemProvider];
            NSLog(@"[INFO][VCCM] User did start drag and drop; item %@ provided", cellsType);
            return [[NSArray alloc] initWithObjects:typeDragItem,nil];
        }

    }
    return [[NSArray alloc] init];
}

/*!
 @method tableView:canHandleDropSession:
 @discussion Handles drag and drop gestures between tables; cheks if the destination table can handle a drag and drop session.
 */
- (BOOL)tableView:(UITableView *)tableView
canHandleDropSession:(id<UIDragSession>)session
{
    if (tableView == self.tableMetamodels) {
                
        // This table can only handle drops of MDType classes.
        if (session.items.count == 1) {
            if([session canLoadObjectsOfClass:MDType.class]) {
                NSLog(@"[INFO][VCCM] Allowed to drop provided item in this table.");
                return YES;
            } else {
                NSLog(@"[INFO][VCCM] Only MDType class intances can be dropped in this cell.");
                return NO;
            }
        } else {
            NSLog(@"[INFO][VCCM] Only one provided item can be dropped in this cell.");
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
 @discussion Handles drag and drop gestures between tables; propose how the destination table handles a drag and drop session.
 */
- (UITableViewDropProposal *)tableView:(UITableView *)tableView
                  dropSessionDidUpdate:(id<UIDropSession>)session
              withDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    //NSLog(@"[INFO][VCCM] User wants to drop in section %td", destinationIndexPath.section);
    //NSLog(@"[INFO][VCCM] User wants to drop in row %td", destinationIndexPath.row);
    
    UITableViewDropProposal * proposal;
    if (tableView == self.tableMetamodels) {
                
        // This table can only handle drops of MDType classes.
        if (session.items.count == 1) {

            // Check if this section is the extra one for "new item"
            if (destinationIndexPath.section > metamodels.count - 1) {
                // Return a forbidden proposal
                //NSLog(@"[INFO][VCCM] Proposed not to allow user to drop provided item in this cell.");
                proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden
                                                                           intent:UITableViewDropIntentUnspecified];
            } else {
                
                // Manage empty cells
                UITableViewCell * destinationCell = [self.tableMetamodels cellForRowAtIndexPath:destinationIndexPath];
                if ( !destinationCell.textLabel.text || [@"" isEqualToString:destinationCell.textLabel.text]) {
                    // Return a forbidden proposal
                    //NSLog(@"[INFO][VCCM] Proposed not to allow user to drop provided item in this cell.");
                    proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden
                                                                               intent:UITableViewDropIntentUnspecified];
                } else {
                    // Return a copy and insert proposal
                    //NSLog(@"[INFO][VCCM] Proposed allow user to drop (copy and insert) provided item in this cell.");
                    proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy
                                                                           intent:UITableViewDropIntentAutomatic];
                }
            }
            
	} else { 
            return nil;   
	}

    }
    if (tableView == self.tableTypes) {
        
        // This table cannot be target of any drag and drop
        // Return a forbidden proposal
        //NSLog(@"[INFO][VCCM] Proposed not to allow user to drop provided item in this table.");
        proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden
                                                                   intent:UITableViewDropIntentUnspecified];
    }
    return proposal;
}

/*!
 @method tableView:performDropWithCoordinator:
 @discussion Handles drag and drop gestures between tables; handles the drop of the dragged items' collection.
 */
- (void)tableView:(UITableView *)tableView
performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator
{
    if (tableView == self.tableMetamodels) {
        // Decide an indexPath for the new cell depending on user's droping selection
        NSIndexPath * destinationIndexPath = coordinator.destinationIndexPath;
        NSInteger section = destinationIndexPath.section;
        if (section > metamodels.count - 1) {
            NSLog(@"[INFO][VCCM] User did droppped in the 'new item' cell.");
            return;
        } else {
            NSLog(@"[INFO][VCCM] User did droppped the provided item in section %td.", section);
        }

        // Different behaviour depending on dropping proposal
        switch (coordinator.proposal.operation) {
            case UIDropOperationCancel:
                break;
            case UIDropOperationForbidden:
                break;
            case UIDropOperationMove:
                break;
            case UIDropOperationCopy:
                
                NSLog(@"[INFO][VCCM] Droppped provided item being copied.");
                [self.tableMetamodels performBatchUpdates:^{
                    [coordinator.session loadObjectsOfClass:MDType.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
                        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
                            MDType * cellType = object;
                            NSLog(@"[INFO][VCCM] Droppped and copied a NSType %@ item.", cellType);
                            
                            // Update metamodel
                            MDMetamodel * userDropMetamodel = [metamodels objectAtIndex:section];
                            BOOL newType =[userDropMetamodel addType:cellType];
                            
                            // Update table
                            if (newType) {
                                NSMutableArray * userDropMetamodelTypes = [userDropMetamodel getTypes];
                                NSInteger addRow = userDropMetamodelTypes.count - 1;
                                NSIndexPath * addIndexPath = [NSIndexPath indexPathForRow:addRow inSection:section];
                                [self.tableMetamodels insertRowsAtIndexPaths:@[addIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            }
                        }];
                    }];
                }
                                    completion:^(BOOL finished) {
                                        if (finished) {
                                            // Update device metamodel
                                            [self updatePersistentMetamodels];
                                        }
                                    }
                 ];
                
                /* Another way retrieving each UIDragItem
                NSArray * itemsProvided = coordinator.session.items;
                UIDragItem * typeDragItem = [itemsProvided objectAtIndex:0];  // Only one item was dragged
                NSItemProvider * typeItemProvider = typeDragItem.itemProvider;
                [typeItemProvider loadObjectOfClass:[MDType class]
                                  completionHandler:^(id<NSItemProviderReading> _Nullable __strong object,
                                                      NSError * _Nullable __strong error) {
                                      if (object) {
                                          MDType * cellType = object;
                                          NSLog(@"[INFO][VCCM] Droppped and copied a NSType %@ item.", cellType);
                 
                                          // Update metamodel
                                          MDMetamodel * userDropMetamodel = [metamodels objectAtIndex:section];
                                          BOOL newType =[userDropMetamodel addType:cellType];
                                          
                                          // Update table
                                          if (newType) {
                                              NSMutableArray * userDropMetamodelTypes = [userDropMetamodel getTypes];
                                              NSInteger addRow = userDropMetamodelTypes.count - 1;
                                              NSIndexPath * addIndexPath = [NSIndexPath indexPathForRow:addRow inSection:section];
                                              [self.tableMetamodels insertRowsAtIndexPaths:@[addIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                          }
                 
                                      } else {
                                          NSLog(@"[INFO][VCCM] No payload in dropped provided item.");
                                      }
                                  }
                 ];
                 */
                
                break;
        }
        // Reload data
        [self.tableMetamodels reloadData];
    }
}

#pragma mark - New types and metamodels
/*!
 @method newMetamodelWithName:andDescription:
 @discussion This method is called when user wants to create a new metamodel.
 */
- (BOOL)newMetamodelWithName:(NSString *)name
              andDescription:(NSString *)description
{
    MDMetamodel * newMetamodel = [[MDMetamodel alloc] initWithName:name
                                                    andDescription:description];
    [metamodels addObject:newMetamodel];
    return YES;
}

/*!
 @method removeMetamodelWithName:
 @discussion This method is called when user wants to remove a metamodel.
 */
- (BOOL)removeMetamodelWithName:(NSString *)name
{
    MDMetamodel * foundMetamodel;
    for (MDMetamodel * eachMetadmodel in metamodels) {
        if ([name isEqualToString:[eachMetadmodel getName]]) {
            foundMetamodel = eachMetadmodel;
        }
    }
    if (foundMetamodel) {
        [metamodels removeObject:foundMetamodel];
        return YES;
    }
    return NO;
}

/*!
 @method updatePersistentMetamodels
 @discussion This method is called when user changes metamodels collection in orther to upload it.
 */
- (BOOL)updatePersistentMetamodels
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/metamodels"];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    
    // Check if there is any type
    NSData * areMetamodelsData;
    if (metamodels.count > 0) {
        areMetamodelsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    } else {
        areMetamodelsData = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    }
    
    // Save information
    [userDefaults setObject:areMetamodelsData forKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    NSData * metamodelsData = [NSKeyedArchiver archivedDataWithRootObject:metamodels];
    [userDefaults setObject:metamodelsData forKey:@"es.uam.miso/data/metamodels/metamodels"];
    
    return YES;
}

/*!
 @method newTypeWithName:
 @discussion This method is called when user wants to create a new type.
 */
- (BOOL)newTypeWithName:(NSString *)name
{
    MDType * newType = [[MDType alloc] initWithName:name];
    [types addObject:newType];
    return YES;
}

/*!
 @method removeTypeWithName:
 @discussion This method is called when user wants to remove a type.
 */
- (BOOL)removeTypeWithName:(NSString *)name
{
    MDType * foundType;
    for (MDType * eachType in types) {
        if ([name isEqualToString:[eachType getName]]) {
            foundType = eachType;
        }
    }
    if (foundType) {
        [types removeObject:foundType];
        return YES;
    }
    return NO;
}

/*!
 @method updatePersistentTypes
 @discussion This method is called when user changes types collection in orther to upload it.
 */
- (BOOL)updatePersistentTypes
{
    // Remove previous collection
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/types"];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/areTypes"];
    
    // Check if there is any type
    NSData * areTypesData;
    if (types.count > 0) {
        areTypesData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    } else {
        areTypesData = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    }
    
    // Save information
    [userDefaults setObject:areTypesData forKey:@"es.uam.miso/data/metamodels/areTypes"];
    NSData * typesData = [NSKeyedArchiver archivedDataWithRootObject:types];
    [userDefaults setObject:typesData forKey:@"es.uam.miso/data/metamodels/types"];
    
    return YES;
}

@end
