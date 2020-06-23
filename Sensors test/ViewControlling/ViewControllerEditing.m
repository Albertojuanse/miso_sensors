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
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:1.0];
    UIColor * disabledThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.3];
    
    self.toolbar.backgroundColor = normalThemeColor;
    [self.buttonMeasure setTitleColor:normalThemeColor
                             forState:UIControlStateNormal];
    [self.buttonMeasure setTitleColor:disabledThemeColor
                             forState:UIControlStateDisabled];
    [self.buttonFinish setTitleColor:normalThemeColor
                            forState:UIControlStateNormal];
    [self.buttonFinish setTitleColor:disabledThemeColor
                            forState:UIControlStateDisabled];
    [self.buttonNext setTitleColor:normalThemeColor
                          forState:UIControlStateNormal];
    [self.buttonNext setTitleColor:disabledThemeColor
                          forState:UIControlStateDisabled];
    [self.buttonBack setTitleColor:normalThemeColor
                          forState:UIControlStateNormal];
    [self.buttonBack setTitleColor:disabledThemeColor
                          forState:UIControlStateDisabled];
    [self.buttonAdd setTitleColor:normalThemeColor
                         forState:UIControlStateNormal];
    [self.buttonAdd setTitleColor:disabledThemeColor
                         forState:UIControlStateDisabled];
    // Other components
    [self.signOutButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [self.logOutButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [self.loginText setTextColor:[UIColor whiteColor]];
    [self.buttonMeasure setEnabled:YES];
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
    // TODO: Use UUID from component 'device'. Alberto J. 2020/01/20.
    if (!deviceUUID) {
        deviceUUID = [[NSUUID UUID] UUIDString];
    }
    
    // Strategy pattern; different location delegate for each mode
    delegate = [sharedData fromSessionDataGetDelegateFromUserWithUserDic:userDic
                                                   andCredentialsUserDic:credentialsUserDic];
    
    if (delegate) {
        // Load the components from delegate
        errorDescription = [delegate getErrorDescription];
        NSLog(@"[INFO]%@ Delegate loaded for ViewControllerEditing.", errorDescription);
        
        // Load the location manager and its delegate to define how location events are handled
        location = [delegate loadLMDelegate];
        
        // Load the motion manager to define how motion events are handled
        motion = [delegate loadMotion];

        // Load the messages that are shown to user in each state
        idleStateMessage = [delegate getIdleStateMessage];
        measuringStateMessage = [delegate getMeasuringStateMessage];
        [self.labelStatus setText:idleStateMessage];
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
- (void) presentEditComponentView:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"presentEditComponentView"]){
        NSLog(@"[NOTI]%@ Notification \"presentEditComponentView\" recived.", errorDescription);
        
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

/*!
 @method setDeviceUUID:
 @discussion This method sets the NSString variable 'deviceUUID'.
 */
- (void) setDeviceUUID:(NSString *)givenDeviceUUID
{
    deviceUUID = givenDeviceUUID;
}

#pragma mark - Buttons event handlers
/*!
 @method handleButtonMeasure:
 @discussion This method handles the action in which the Measure button is pressed; it must disable 'Travel' control buttons and ask location manager delegate to start measuring.
 */
- (IBAction)handleButtonMeasure:(id)sender
{
    // First, validate the access to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        [self alertUserWithTitle:@"Measure won't be started."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR]%@ Shared data could not be accessed while starting travel.", errorDescription);
        return;
    }
    
    // In every state the button performs different behaviours
    NSString * state = [sharedData fromSessionDataGetStateFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
    [delegate whileEditingUserDidTapButtonMeasure:self.buttonMeasure
                                      whenInState:state
                               andWithLabelStatus:self.labelStatus];
    return;
}

/*!
 @method handleButtonBack:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender
{
    [self performSegueWithIdentifier:@"fromEDITINGToSelectPosition" sender:sender];
}

/*!
 @method handleButtonNext:
 @discussion This method is called one the user wnats to locate a new position and thus a new UUID is generated for it.
 */
- (IBAction)handleButtonNext:(id)sender
{
    // New UUID
    // TODO: To notification. Aberto J. 2020/06/13.
    if ([mode isModeKey:kModeThetaThetaLocating]) {
        LMDelegateThetaThetaLocating * lmdelegate = (LMDelegateThetaThetaLocating *)location;
        locatedPositionUUID = [[NSUUID UUID] UUIDString];
        [lmdelegate setDeviceUUID:locatedPositionUUID];
        [motion setDeviceUUID:locatedPositionUUID];
    }
    if ([mode isModeKey:kModeRhoThetaModelling]) {
        LMDelegateRhoThetaModelling * lmdelegate = (LMDelegateRhoThetaModelling *)location;
        locatedPositionUUID = [[NSUUID UUID] UUIDString];
        [lmdelegate setDeviceUUID:locatedPositionUUID];
        [motion setDeviceUUID:locatedPositionUUID];
    }
}

/*!
 @method handleButtonFinish:
 @discussion This method is called when user is prepared for modeling.
 */
- (IBAction)handleButtonFinish:(id)sender {
    [self performSegueWithIdentifier:@"fromEDITINGToFinalModel" sender:sender];
}

/*!
 @method handleButtonAdd:
 @discussion This method is called when user wants to add a component to the model.
 */
- (IBAction)handleButtonAdd:(id)sender {
    
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
    [popoverEditComponent setSourceView:self.buttonAdd];
    [popoverEditComponent setSourceRect:CGRectMake(0, 0, 1, 1)];
    [popoverEditComponent setPermittedArrowDirections:UIPopoverArrowDirectionAny];
    // Show the view
    [self presentViewController:viewControllerAddComponent animated:YES completion:nil];
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
        NSLog(@"[NOTI][VCRRL] Notification \"lmdRhoRhoLocating/stop\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmd/reset"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRL] Notification \"lmd/reset\" posted.");
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
