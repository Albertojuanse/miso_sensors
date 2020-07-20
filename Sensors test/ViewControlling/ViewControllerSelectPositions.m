//
//  ViewControllerSelectPositions.m
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerSelectPositions.h"

@implementation ViewControllerSelectPositions

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Visualization
    [self showUser];
    [self loadLayout];
    
    // Components
    [self loadComponents];
    
    // All items must be set as not chosen by user everytime
    [self uncheckAllItemsAsChosenByUser];
    
    // Check if in routine
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Get temporal model
            NSMutableDictionary * routineModelDic = [sharedData fromSessionDataGetRoutineModelFromUserWithUserDic:userDic
                                                                                       andCredentialsUserDic:credentialsUserDic];
            
            // Set each component as chosen one
            if (routineModelDic) {
                NSMutableArray * components = routineModelDic[@"components"];
                for (NSMutableDictionary * eachComponent in components) {
                    [sharedData  inSessionDataSetAsChosenItem:eachComponent
                                            toUserWithUserDic:userDic
                                       withCredentialsUserDic:credentialsUserDic];
                }
            }
            
        }
    }
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableItems.delegate = self;
    self.tableItems.dataSource = self;
    // Allow multiple selection
    self.tableItems.allowsMultipleSelection = true;
    
    [self.tableItems reloadData];
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

/*!
 @method loadLayout
 @discussion This method loads the layout configurations.
 */
- (void)loadLayout
{
    // Toolbar layout
    UIColor * normalThemeColor = [VCDrawings getNormalThemeColor];
    UIColor * disabledThemeColor = [VCDrawings getDisabledThemeColor];
    
    self.toolbar.backgroundColor = normalThemeColor;
    [self.backButton setTitleColor:normalThemeColor
                          forState:UIControlStateNormal];
    [self.backButton setTitleColor:disabledThemeColor
                          forState:UIControlStateDisabled];
    [self.goButton setTitleColor:normalThemeColor
                          forState:UIControlStateNormal];
    [self.goButton setTitleColor:disabledThemeColor
                          forState:UIControlStateDisabled];
    [self.loginText setTextColor:[UIColor whiteColor]];
}

/*!
 @method showUser
 @discussion This method defines how user name is shown once logged.
 */
- (void)showUser
{
    self.loginText.text = [self.loginText.text stringByAppendingString:@" "];
    self.loginText.text = [self.loginText.text stringByAppendingString:userDic[@"name"]];
}

/*!
@method loadComponents
@discussion This method loads the components depending on the current mode.
*/
- (void)loadComponents
{
    // Strategy pattern; different location delegate for each mode
    delegate = [sharedData fromSessionDataGetDelegateFromUserWithUserDic:userDic
                                                   andCredentialsUserDic:credentialsUserDic];
    if (delegate) {
        NSLog(@"[INFO][VCSP] Delegate loaded.");
    } else {
        NSLog(@"[ERROR][VCSP] No delegate found.");
    }
}

/*!
@method uncheckAllItemsAsChosenByUser
@discussion This method sets as not chosen by user every item.
*/
- (void)uncheckAllItemsAsChosenByUser
{
    // Everytime that this view is loaded every item must be set as 'not chosen'
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
        NSMutableDictionary * sessionDic = [sharedData fromSessionDataGetSessionWithUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
        if (sessionDic[@"itemsChosenByUser"]) {
            sessionDic[@"itemsChosenByUser"] = nil;
        }
        
    } else {
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCSP] Shared data could not be accessed while loading select position view.");
    }
    
    // Uncheck as Chosen all the items
    NSMutableArray * items = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
    for (NSMutableDictionary * eachItemChosenByUser in items) {
        [sharedData inSessionDataSetAsNotChosenItem:eachItemChosenByUser
                                  toUserWithUserDic:userDic
                             withCredentialsUserDic:credentialsUserDic];
    }
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

/*!
 @method setSharedData:
 @discussion This method sets the shared data collection.
 */
- (void) setSharedData:(SharedData *)givenSharedData
{
    sharedData = givenSharedData;
}

#pragma mark - Buttons event handlers
/*!
 @method handleButtonBack:
 @discussion This method handles the 'back' button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender
{
    [self performSegueWithIdentifier:@"fromSelectPositionsToMain" sender:sender];
}

/*!
 @method handleButtonGo:
 @discussion This method handles the 'go' button action and segues to mode's locating view; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonGo:(id)sender
{
    NSLog(@"[INFO][VCSP] Button 'go' tapped.");
    
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // Get the current mode
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        
        // This button can segue with different views depending on the mode chosen by the user in the main menu
        if ([mode isModeKey:kModeMonitoring]) {
            NSLog(@"[INFO][VCSP] Chosen mode is kModeMonitoring.");
            [self performSegueWithIdentifier:@"fromSelectPositionsToMONITORING" sender:sender];
            return;
        } else {
            [delegate whileSelectingHandleButtonGo:sender
                                fromViewController:self];
        }
        
    } else {
        [self alertUserWithTitle:@"Mode won't load."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCSP] Shared data could not be accessed when tapped 'go' button item.");
    }
}

/*!
 @method alertUserWithTitle:message:andHandler:
 @discussion This method alerts the user with a pop up window with a single "Ok" button given its message and title and lambda funcion handler.
 */
- (void) alertUserWithTitle:(NSString *)title
                    message:(NSString *)message
                 andHandler:(void (^)(UIAlertAction *action))handler;
{
    UIAlertController * alertUsersNotFound = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:handler
                                ];
    
    [alertUsersNotFound addAction:okButton];
    [self presentViewController:alertUsersNotFound animated:YES completion:nil];
    return;
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCSP] Asked segue %@", [segue identifier]);
    
    // This view can segue with different views depending on the mode chosen by the user in the main menu
    
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setUserDic:userDic];
        [viewControllerMainMenu setSharedData:sharedData];
        
    }
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToMONITORING"]) {
        
        // Get destination view
        ViewControllerMonitoring * viewControllerMonitoring = [segue destinationViewController];
        // Set the variables
        [viewControllerMonitoring setCredentialsUserDic:credentialsUserDic];
        [viewControllerMonitoring setUserDic:userDic];
        [viewControllerMonitoring setSharedData:sharedData];
        
    }
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToEDITING"]) {
        
        // Get destination view
        ViewControllerEditing * viewControllerEditing = [segue destinationViewController];
        // Set the variables
        [viewControllerEditing setCredentialsUserDic:credentialsUserDic];
        [viewControllerEditing setUserDic:userDic];
        [viewControllerEditing setSharedData:sharedData];
        
    }
    return;
}

#pragma mark - UItableView delegate methods
/*!
 @method numberOfSectionsInTableView:
 @discussion Handles the upload of tables; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/*!
 @method tableView:numberOfRowsInSection:
 @discussion Handles the upload of tables; returns the number of items in them.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableItems) {
        NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
        return itemsCount + modelCount;
    }
    return 0;
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = [@"Cell" stringByAppendingString:[indexPath description]];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure individual cells
    if (tableView == self.tableItems) {
        // Ask mode's delegate in each mode to manage this
        cell = [delegate whileSelectingTableItems:tableView
                                 inViewController:self
                                             cell:cell
                                forRowAtIndexPath:indexPath];
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
    NSLog(@"[INFO][VCSP] User did select the row %tu", indexPath.row);
    if (tableView == self.tableItems) {
        
        [delegate whileSelectingTableItems:tableView
                          inViewController:self
                   didSelectRowAtIndexPath:indexPath];
        
    }
    return;
}

@end
