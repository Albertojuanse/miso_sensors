//
//  ViewControllerEditing.m
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerEditing.h"

@implementation ViewControllerEditing

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get the current mode
    mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                           andCredentialsUserDic:credentialsUserDic];
    
    // Visualization
    [self showUser];
    [self loadLayout];
    
    // Components
    [self loadComponents];
    
    // Initial state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Variables; used for new positions located by this view and renewed every time.
    locatedPositionUUID = [[NSUUID UUID] UUIDString];
    // Load metamodels for this mode
    modeMetamodels = [[NSMutableArray alloc] init];
    modeTypes = [[NSMutableArray alloc] init];
    [self loadModeMetamodels];
    [self loadModeTypes];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic
                       andCredentialsUserDic:credentialsUserDic];
    
    // Load event listeners
    [self loadEventListeners];
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
    [self.buttonFinish setTitleColor:normalThemeColor
                            forState:UIControlStateNormal];
    [self.buttonFinish setTitleColor:disabledThemeColor
                            forState:UIControlStateDisabled];
    [self.buttonBack setTitleColor:normalThemeColor
                          forState:UIControlStateNormal];
    [self.buttonBack setTitleColor:disabledThemeColor
                          forState:UIControlStateDisabled];
    UIImage * addMeasureImage = [VCDrawings imageForAddMeasureInNormalThemeColor];
    [self.buttonAddMeasure setImage:addMeasureImage forState:UIControlStateNormal];
    [self.buttonAddMeasure setTintColor:normalThemeColor];
    UIImage * addManualImage = [VCDrawings imageForAddManualInNormalThemeColor];
    [self.buttonAddManual setImage:addManualImage forState:UIControlStateNormal];
    [self.buttonAddManual setTintColor:normalThemeColor];
    
    // Other components
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
@discussion This method loads the location and motion components depending on the current mode.
*/
- (void)loadComponents
{
    // Strategy pattern; different location delegate for each mode
    delegate = [sharedData fromSessionDataGetDelegateFromUserWithUserDic:userDic
                                                   andCredentialsUserDic:credentialsUserDic];
    
    if (delegate) {
        // Load the components from delegate
        errorDescription = [delegate getErrorDescription];
        NSLog(@"[INFO]%@ Delegate loaded for ViewControllerEditing.", errorDescription);
        
        // Load the location manager and its delegate to define how location events are handled
        location = [delegate loadLMDelegate];
        ranger = [delegate loadLMRanging];
        
        // Load the motion manager to define how motion events are handled
        motion = [delegate loadMotion];

        // Load the messages that are shown to user in each state
        // TODO: Remove this or use to some "tutorial" mode. Alberto J. 2020/07/18.
        idleStateMessage = [delegate getIdleStateMessage];
        measuringStateMessage = [delegate getMeasuringStateMessage];
        // [self.labelStatus setText:idleStateMessage];
    } else {
        NSLog(@"[ERROR][VCE---] No delegate for ViewControllerEditing was loaded.");
    }
}

/*!
@method loadModeMetamodels
@discussion This method loads the metamodels for this mode.
*/
- (void)loadModeMetamodels
{
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Get all metamodels
            NSMutableArray * metamodels = [sharedData fromMetamodelsDataGetMetamodelsWithCredentialsUserDic:credentialsUserDic];
            
            // Find the metamodels used in this mode
            for (MDMetamodel * eachMetamodel in metamodels) {
                
                NSMutableArray * eachMetamodelModes = [eachMetamodel getModes];
                
                // Modes are saved as NSNumbers with each key
                for (NSNumber * eachModeKey in eachMetamodelModes){
                    
                    MDMode * eachMode = [[MDMode alloc] initWithModeKey:[eachModeKey intValue]];
                    
                    if ([eachMode isEqualToMDMode:mode]) {
                        [modeMetamodels addObject:eachMetamodel];
                    }
                    
                }
                
            }
            
        }
    } else {
        return;
    }
    NSLog(@"[INFO]%@ Loaded %tu metamodels for this mode.", errorDescription, modeMetamodels.count);
}

/*!
@method loadModeTypes
@discussion This method loads the types for this mode from the metamodels.
*/
- (void)loadModeTypes
{
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Find in the metamodels the types used
            for (MDMetamodel * eachMetamodel in modeMetamodels) {
                
                NSMutableArray * eachMetamodelTypes = [eachMetamodel getTypes];
                
                // Get the types of the metamodel and check if they are already got.
                for (MDType * eachMetamodelType in eachMetamodelTypes){
                    
                    BOOL typeFound = NO;
                    for (MDType * eachType in modeTypes){
                        if ([eachType isEqualToMDType:eachMetamodelType]) {
                            typeFound = YES;
                        }
                    }
                    if (!typeFound) {
                        [modeTypes addObject:eachMetamodelType];
                    }
                    
                }
                
            }
            
        }
    } else {
        return;
    }
    NSLog(@"[INFO]%@ Loaded %tu ontologycal types for this mode.", errorDescription, modeTypes.count);
}

/*!
@method loadEventListeners
@discussion This method loads the event listeners for this class.
*/
- (void)loadEventListeners
{
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chooseItem:)
                                                 name:@"vcEditing/chooseItem"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentEditComponentView:)
                                                 name:@"vcEditing/presentEditComponentView"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentMeasureView:)
                                                 name:@"vcEditing/presentMeasureView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createReference:)
                                                 name:@"vcEditing/createReference"
                                               object:nil];
}

#pragma mark - Notifications events handlers
/*!
 @method chooseItem:
 @discussion This method is called when user taps over and sets a component as chosen item.
 */
- (void) chooseItem:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"vcEditing/chooseItem"]){
        NSLog(@"[NOTI]%@ Notification \"vcEditing/chooseItem\" recived.", errorDescription);
        
        // User did choose an item; get it...
        VCComponent * sourceViewChosenByUser = [notification object];
        if (!sourceViewChosenByUser) {
            NSLog(@"[ERROR]%@ Object VCComponent not found in notification.", errorDescription);
            return;
        }
        NSString * chosenItemUUID = [sourceViewChosenByUser getUUID];
        NSMutableArray * itemsChosenByUser = [sharedData fromItemDataGetItemsWithUUID:chosenItemUUID
                                                                andCredentialsUserDic:credentialsUserDic];
        if (itemsChosenByUser.count == 0) {
            NSLog(@"[ERROR]%@ User did choose an unknown item: %@", errorDescription, chosenItemUUID);
            return;
        }
        else if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR]%@ User did choose an item whose UUID is repeated: %@", errorDescription, chosenItemUUID);
        }
        NSMutableDictionary * itemChosenByUser = [itemsChosenByUser objectAtIndex:0];

        NSLog(@"[INFO]%@ The user did choose the item %@", errorDescription, itemChosenByUser[@"uuid"]);
        
        // ...and set it as item chosen by user in shared data.
        [sharedData inSessionDataSetItemChosenByUser:itemChosenByUser
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
    }
    return;
}

/*!
 @method presentEditComponentView:
 @discussion This method is called when user double taps over and component on canvas and presents modally the pop up view to edit that component.
 */
- (void) presentEditComponentView:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"vcEditing/presentEditComponentView"]){
        NSLog(@"[NOTI]%@ Notification \"vcEditing/presentEditComponentView\" recived.", errorDescription);
        
        // User did choose an item; get it...
        VCComponent * sourceViewChosenByUser = [notification object];
        if (!sourceViewChosenByUser) {
            NSLog(@"[ERROR]%@ Object VCComponent not found in notification.", errorDescription);
            return;
        }
        NSString * chosenItemUUID = [sourceViewChosenByUser getUUID];
        NSMutableArray * itemsChosenByUser = [sharedData fromItemDataGetItemsWithUUID:chosenItemUUID
                                                                andCredentialsUserDic:credentialsUserDic];
        if (itemsChosenByUser.count == 0) {
            NSLog(@"[ERROR]%@ User did choose an unknown item: %@", errorDescription, chosenItemUUID);
            return;
        }
        else if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR]%@ User did choose an item whose UUID is repeated: %@", errorDescription, chosenItemUUID);
        }
        NSMutableDictionary * itemChosenByUser = [itemsChosenByUser objectAtIndex:0];

        NSLog(@"[INFO]%@ The user asked pop up view to edit %@", errorDescription, itemChosenByUser[@"uuid"]);
        
        // ...and set it as item chosen by user in shared data.
        [sharedData inSessionDataSetItemChosenByUser:itemChosenByUser
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
        
        // Present the view as a pop up
        ViewControllerEditComponent * viewControllerEditComponent = [[[NSBundle mainBundle]
                                                                      loadNibNamed:@"ViewEditComponent"
                                                                      owner:self
                                                                      options:nil]
                                                                     objectAtIndex:0];
        [viewControllerEditComponent setModalPresentationStyle:UIModalPresentationPopover];
        // Set the variables
        [viewControllerEditComponent setCredentialsUserDic:credentialsUserDic];
        [viewControllerEditComponent setUserDic:userDic];
        [viewControllerEditComponent setSharedData:sharedData];
        [viewControllerEditComponent setModeTypes:modeTypes];
        // Configure popover layout
        NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
        NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
        NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
        NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
        UIPopoverPresentationController * popoverEditComponent =  viewControllerEditComponent.popoverPresentationController;
        [popoverEditComponent setDelegate:viewControllerEditComponent];
        [popoverEditComponent setSourceView:sourceViewChosenByUser];
        [popoverEditComponent setSourceRect:CGRectMake([positionWidth floatValue]/2.0,
                                                       [positionHeight floatValue],
                                                       1,
                                                       1)];
        [popoverEditComponent setPermittedArrowDirections:UIPopoverArrowDirectionAny];
        // Show the view
        [self presentViewController:viewControllerEditComponent animated:YES completion:nil];
    }
    return;
}

/*!
 @method presentMeasureView:
 @discussion This method is called when user choses the item that wants to add to the model and presents modally the pop up view to  measure it.
 */
- (void) presentMeasureView:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"vcEditing/presentMeasureView"]){
        NSLog(@"[NOTI]%@ Notification \"vcEditing/presentMeasureView\" recived.", errorDescription);
        
        // Retrieve notification data
        NSDictionary * dataDic = [notification userInfo];
        NSMutableDictionary * itemDic = dataDic[@"itemDic"];
        
        // Present the view as a pop up
        ViewControllerMeasure * viewControllerMeasure = [[[NSBundle mainBundle]
                                                          loadNibNamed:@"ViewMeasure"
                                                          owner:self
                                                          options:nil]
                                                         objectAtIndex:0];
        [viewControllerMeasure setModalPresentationStyle:UIModalPresentationPopover];
        // Set the variables
        [viewControllerMeasure setDelegate:delegate];
        [viewControllerMeasure setItemDicToMeasure:itemDic];
        [viewControllerMeasure loadMeasureImage];
        
        // Configure popover layout
        UIPopoverPresentationController * popoverMeasure =  viewControllerMeasure.popoverPresentationController;
        [popoverMeasure setDelegate:viewControllerMeasure];
        [popoverMeasure setSourceView:self.buttonAddMeasure];
        [popoverMeasure setSourceRect:CGRectMake(0,0,1,1)];
        [popoverMeasure setPermittedArrowDirections:UIPopoverArrowDirectionAny];
        // Show the view
        [self presentViewController:viewControllerMeasure animated:NO completion:nil];
    }
    return;
}

/*!
 @method createReference:
 @discussion This method creates a reference between two components in the model.
 */
- (void)createReference:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"vcEditing/createReference"]){
        NSLog(@"[NOTI]%@ Notification \"vcEditing/createReference\" recived.", errorDescription);
    
        // Retrieve notification data
        NSDictionary * dataDic = [notification userInfo];
        VCComponent * sourceView = dataDic[@"sourceView"];
        VCComponent * targetView = dataDic[@"targetView"];
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // Get both items from shared data
            if (!sourceView) {
                NSLog(@"[ERROR]%@ Source VCComponent not found in notification.", errorDescription);
                return;
            }
            if (!targetView) {
                NSLog(@"[ERROR]%@ Target VCComponent not found in notification.", errorDescription);
                return;
            }
            NSString * sourceItemUUID = [sourceView getUUID];
            NSString * targetItemUUID = [targetView getUUID];
            NSMutableArray * sourceItems = [sharedData fromItemDataGetItemsWithUUID:sourceItemUUID
                                                              andCredentialsUserDic:credentialsUserDic];
            
            NSMutableArray * targetItems = [sharedData fromItemDataGetItemsWithUUID:targetItemUUID
                                                              andCredentialsUserDic:credentialsUserDic];
            if (sourceItems.count == 0) {
                NSLog(@"[ERROR]%@ User did choose an unknown source item: %@", errorDescription, sourceItemUUID);
                return;
            }
            if (targetItems.count == 0) {
                NSLog(@"[ERROR]%@ User did choose an unknown target item: %@", errorDescription, targetItemUUID);
                return;
            }
            else if (sourceItems.count > 1) {
                NSLog(@"[ERROR]%@ User did choose a source item whose UUID is repeated: %@", errorDescription, sourceItemUUID);
            }
            else if (targetItems.count > 1) {
                NSLog(@"[ERROR]%@ User did choose a target item whose UUID is repeated: %@", errorDescription, targetItemUUID);
            }
            NSMutableDictionary * sourceItem = [sourceItems objectAtIndex:0];
            NSMutableDictionary * targetItem = [targetItems objectAtIndex:0];

            NSLog(@"[INFO]%@ The user asked to crate a reference between %@ and %@", errorDescription, sourceItem[@"uuid"], targetItem[@"uuid"]);

            // And create and add the reference
            MDReference * reference = [[MDReference alloc] initWithsourceItemId:sourceItem[@"identifier"]
                                                                andTargetItemId:targetItem[@"identifier"]];
            NSLog(@"[INFO]%@ Created reference %@", errorDescription, reference);
            [sharedData inSessionDataAddReference:reference toUserWithUserDic:userDic withCredentialsUserDic:credentialsUserDic];
            
            [self.canvas setNeedsDisplay];
            
        } else {
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR]%@ Shared data could not be accessed before handle the 'reference' button.", errorDescription);
        }
    }
    return;
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

/*!
 @method setMotionManager:
 @discussion This method sets the motion manager.
 */
- (void) setMotionManager:(MotionManager *)givenMotion
{
    motion = givenMotion;
}

/*!
 @method setLocationManager:
 @discussion This method sets the location manager.
 */
- (void) setLocationManager:(id<CLLocationManagerDelegate>)givenLocation
{
    location = givenLocation;
}

#pragma mark - Buttons event handlers
/*!
 @method handleButtonBack:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender
{
    [self performSegueWithIdentifier:@"fromEDITINGToSelectPosition" sender:sender];
}

/*!
 @method handleButtonFinish:
 @discussion This method is called when user is prepared for modeling.
 */
- (IBAction)handleButtonFinish:(id)sender
{
    // Items of sort "empty_position" may have been created to locate them; remove them
    [sharedData inItemDataRemoveItemsWithSort:@"empty_position"
                       withCredentialsUserDic:credentialsUserDic];
    
    // If in a routine, set as finished the current mode
    // Check if in routine
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Find the mode that is not finished
            NSMutableArray * modes = [sharedData fromSessionDataGetModesFromUserWithUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
            
            // Mode finished
            for (MDMode * eachMode in modes) {
                if ([eachMode isEqualToMDMode:mode]) {
                    [eachMode setFinished:YES];
                    break;
                }
            }
        }
    }
    
    [self performSegueWithIdentifier:@"fromEDITINGToFinalModel" sender:sender];
}

/*!
 @method handleButtonAddMeasure:
 @discussion This method is called when user wants to add a component to the model using measures.
 */
- (IBAction)handleButtonAddMeasure:(id)sender
{
    
    // Instance the add component view
    ViewControllerAddComponent * viewControllerAddComponent = [[[NSBundle mainBundle]
                                                                loadNibNamed:@"ViewAddComponent"
                                                                owner:self
                                                                options:nil]
                                                               objectAtIndex:0];
    [viewControllerAddComponent setModalPresentationStyle:UIModalPresentationPopover];
    
    // Set the context variables
    [viewControllerAddComponent setCredentialsUserDic:credentialsUserDic];
    [viewControllerAddComponent setUserDic:userDic];
    [viewControllerAddComponent setSharedData:sharedData];
    [viewControllerAddComponent setVCEditingDelegate:delegate];
    
    // Configure popover layout
    UIPopoverPresentationController * popoverEditComponent =  viewControllerAddComponent.popoverPresentationController;
    [popoverEditComponent setDelegate:viewControllerAddComponent];
    [popoverEditComponent setSourceView:self.buttonAddMeasure];
    [popoverEditComponent setSourceRect:CGRectMake(0, 0, 1, 1)];
    [popoverEditComponent setPermittedArrowDirections:UIPopoverArrowDirectionAny];
    // Show the view
    [self presentViewController:viewControllerAddComponent animated:YES completion:nil];
}

/*!
 @method handleButtonAddManual:
 @discussion This method is called when user wants to add a component to the model given its coordinates using an alert view.
 */
- (IBAction)handleButtonAddManual:(id)sender
{
    UIAlertController * alertNewPosition = [UIAlertController
                                            alertControllerWithTitle:@"Add position"
                                            message:@"Please, set the coordinates of the new position."
                                            preferredStyle:UIAlertControllerStyleAlert
                                            ];
    // Text fields for coordinates
    [alertNewPosition addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"X value as 0.0"];
        xValueTextField = textField;
    }];
    [alertNewPosition addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"Y value as 0.0"];
        yValueTextField = textField;
    }];
    [alertNewPosition addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"Z value as 0.0"];
        zValueTextField = textField;
    }];
    
    // Buttons
    UIAlertAction * okButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * _Nonnull action) {
                                    
                                    // Get coordinates
                                    NSString * xValueText = [xValueTextField text];
                                    NSString * yValueText = [yValueTextField text];
                                    NSString * zValueText = [zValueTextField text];

                                    RDPosition * itemPosition = [[RDPosition alloc] init];
                                    itemPosition.x = [NSNumber numberWithFloat:[xValueText floatValue]];
                                    itemPosition.y = [NSNumber numberWithFloat:[yValueText floatValue]];
                                    itemPosition.z = [NSNumber numberWithFloat:[zValueText floatValue]];

                                    // Create a new item with them
                                    [self createNewItemWithPosition:itemPosition];
                                         
                                 }
                                 ];
    
    UIAlertAction * cancelButton = [UIAlertAction
                                    actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        
                                        // Do nothing
                                        
                                    }
                                    ];
    
    [alertNewPosition addAction:okButton];
    [alertNewPosition addAction:cancelButton];
    [self presentViewController:alertNewPosition animated:YES completion:nil];
}

/*!
@method createNewItemWithPosition:
@discussion This method is called when the user did set the coordinates of the new position using a warning view to create the new item.
*/
- (void) createNewItemWithPosition:(RDPosition *)itemPosition
{
    // Create the new position and save it
    NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
    infoDic[@"sort"] = @"position";
    NSString * newUUID = [[NSUUID UUID] UUIDString];
    infoDic[@"position"] = itemPosition;
    infoDic[@"located"] = @"NO";
    NSString * itemIdentifier = [@"position" stringByAppendingString:[newUUID substringFromIndex:31]];
    itemIdentifier = [itemIdentifier stringByAppendingString:@"@miso.uam.es"];
    infoDic[@"identifier"] = itemIdentifier;
    
    BOOL savedItem = [sharedData inItemDataAddItemOfSort:@"position"
                                                withUUID:newUUID
                                             withInfoDic:infoDic
                               andWithCredentialsUserDic:credentialsUserDic];
    // Get it as it was saved
    if (savedItem) {
        NSMutableArray * savedItemDics = [sharedData fromItemDataGetItemsWithIdentifier:itemIdentifier
                                                                  andCredentialsUserDic:credentialsUserDic];
        NSMutableDictionary * savedItemDic;
        if ([savedItemDics count] > 0) {
            savedItemDic = [savedItemDics objectAtIndex:0];
        }
        if (savedItemDic) {
            [sharedData inSessionDataSetAsChosenItem:savedItemDic
                                   toUserWithUserDic:userDic
                              withCredentialsUserDic:credentialsUserDic];
            
            // Persist it in memory
            [self updatePersistentItemsWithItem:savedItemDic];
            
        } else {
            NSLog(@"[ERROR]%@ New position %@ could not be stored as an item.", infoDic[@"position"], ERROR_DESCRIPTION_VCERTM);
        }
    } else {
        NSLog(@"[ERROR]%@ New position %@ could not be stored as an item.", infoDic[@"position"], ERROR_DESCRIPTION_VCERTM);
    }
    
    // Aks canvas to refresh.
    NSLog(@"[NOTI]%@ Notification \"canvas/refresh\" posted.", errorDescription);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"canvas/refresh"
     object:nil];
}

/*!
 @method updatePersistentItemsWithItem:
 @discussion This method is called when creates a new item to upload it.
 */
- (BOOL)updatePersistentItemsWithItem:(NSMutableDictionary *)itemDic
{
    // Set the variable areItems as YES
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/items/areItems"];
    NSData * areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:areItemsData forKey:@"es.uam.miso/data/items/areItems"];
    
    // Get the index and upload it
    NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
    NSMutableArray * itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
    if (!itemsIndex) {
        itemsIndex = [[NSMutableArray alloc] init];
    }
    NSString * itemIdentifier = itemDic[@"identifier"];
    [itemsIndex addObject:itemIdentifier];
    itemsIndexData = nil; // ARC disposal
    itemsIndexData = [NSKeyedArchiver archivedDataWithRootObject:itemsIndex];
    [userDefaults setObject:itemsIndexData forKey:@"es.uam.miso/data/items/index"];
    
    // Save the item itself
    NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:itemDic];
    NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
    [userDefaults setObject:itemData forKey:itemKey];
    
    return YES;
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO]%@ Asked segue %@", errorDescription, [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromEDITINGToSelectPosition"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        
        // Ask Location manager to clean the measures taken and reset its position.
        // TODO: This to each delegate. Alberto J. 2019/06/19
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoRhoLocating/stop"
                                                            object:nil];
        NSLog(@"[NOTI]%@ Notification \"lmdRhoRhoLocating/stop\" posted.", errorDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmd/reset"
                                                            object:nil];
        NSLog(@"[NOTI]%@ Notification \"lmd/reset\" posted.", errorDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopeHeadingMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI]%@ Notification \"stopGyroscopeHeadingMeasuring\" posted.", errorDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmd/reset"
                                                            object:nil];
        NSLog(@"[NOTI]%@ Notification \"lmd/reset\" posted.", errorDescription);
        return;
    }
    
    if ([[segue identifier] isEqualToString:@"fromEDITINGToFinalModel"]) {
        
        // Get destination view
        ViewControllerFinalModel * viewControllerFinalModel = [segue destinationViewController];
        // Set the variables
        [viewControllerFinalModel setCredentialsUserDic:credentialsUserDic];
        [viewControllerFinalModel setUserDic:userDic];
        [viewControllerFinalModel setSharedData:sharedData];
        return;
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

@end
