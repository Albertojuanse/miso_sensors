//
//  ViewControllerFinalModel.m
//  Sensors test
//
//  Created by Alberto J. on 8/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerFinalModel.h"

@implementation ViewControllerFinalModel

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
    
    // Check if in routine
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Check if this is the last iteration in routine
            MDMode * foundMode;
            NSMutableArray * modes = [sharedData fromSessionDataGetModesFromUserWithUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
            for (MDMode * eachMode in modes) {
                if (![eachMode isFinished]) {
                    NSLog(@"[INFO][VCFM] Evaluating next mode in routine \"%@\".", [eachMode description]);
                    foundMode = eachMode;
                    break;
                }
            }
        
            if (foundMode) {
                [self.buttonSubmit setEnabled:NO];
                [self submitTemporalModel];
            } else {
                
            }
        }
    }
    
}

/*!
 @method viewDidAppear
 @discussion This method notifies the view controller that its view was added to a view hierarchy.
 */
- (void)viewDidAppear:(BOOL)animated {
    // Verify that credentials grant user to shared data
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        NSLog(@"[INFO][VCFM] User credentials have been validated.");
    } else {
        [self alertUserWithTitle:@"User not allowed."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCFM] Shared data could not be accessed after view loading.");
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
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
 @method loadLayout
 @discussion This method loads the layout configurations.
 */
- (void)loadLayout
{
    // Toolbar layout
    UIColor * normalThemeColor = [VCDrawings getNormalThemeColor];
    UIColor * disabledThemeColor = [VCDrawings getDisabledThemeColor];
    
    self.toolbar.backgroundColor = normalThemeColor;
    [self.buttonSubmit setTitleColor:normalThemeColor
                             forState:UIControlStateNormal];
    [self.buttonSubmit setTitleColor:disabledThemeColor
                             forState:UIControlStateDisabled];
    [self.buttonFinish setTitleColor:normalThemeColor
                           forState:UIControlStateNormal];
    [self.buttonFinish setTitleColor:disabledThemeColor
                           forState:UIControlStateDisabled];
    [self.loginText setTextColor:[UIColor whiteColor]];
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

#pragma mark - Butons event handle

/*!
 @method handleButtonSubmit:
 @discussion This method handles the Submit button action and shows the final model; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButonSubmit:(id)sender
{
    // TODO: Model must be a COPY of the items and the references must be removed. Alberto J. 2019/10/18
    
    // Check if name exists
    NSString * name = [self.nameText text];
    if ([sharedData fromModelDataIsModelWithName:name withCredentialsUserDic:credentialsUserDic]) {
        
        if (userDidTrySubmit) { // If it es the second try
            self.statusLabel.text = [NSString stringWithFormat:@"The components of new model have been merged in %@@miso.uam.es", name];
        } else { // If it es the first try
            self.statusLabel.text = [NSString stringWithFormat:@"A model with that name already exists; models will be merged. Press 'submit' again or change the name"];
            userDidTrySubmit = true;
            return;
        }
    } else {
        // the user might chage the name because a collision
        userDidTrySubmit = false;
    }
    
    // Display configurations
    [[self.modelText layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.modelText layer] setBorderWidth:.4];
    [[self.modelText layer] setCornerRadius:8.0f];
    
    // Retrieve the model components
    NSMutableArray * components = [[NSMutableArray alloc] init];
    NSMutableArray * items = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
    for (NSMutableDictionary * itemDic in items) {
        [components addObject:itemDic];
    }
    NSMutableArray * locations = [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                         andCredentialsUserDic:credentialsUserDic];
    for (NSMutableDictionary * locatedDic in locations) {
        [components addObject:locatedDic];
    }
    NSLog(@"[INFO][VCFM] Model composing with components.");
    for (NSMutableDictionary * comp in components) {
        NSLog(@"[INFO][VCFM] -> %@", comp);
    }
    
    // Retrieve the model references
    NSMutableArray * references = [sharedData fromSessionDataGetReferencesByUserDic:userDic
                                                             withCredentialsUserDic:credentialsUserDic];
    
    NSLog(@"[INFO][VCFM] and references.");
    for (MDReference * ref in references) {
        NSLog(@"[INFO][VCFM] -> %@", ref);
    }
    
    // Check for coordinates
    NSNumber * latitude = [sharedData fromMeasuresDataGetMeanMeasureOfSort:@"devicelatitude"
                                                    withCredentialsUserDic:credentialsUserDic];
    NSNumber * longitude = [sharedData fromMeasuresDataGetMeanMeasureOfSort:@"devicelongitude"
                                                     withCredentialsUserDic:credentialsUserDic];
    // Check for heading
    NSNumber * heading = [sharedData fromMeasuresDataGetMeanMeasureOfSort:@"deviceheading"
                                                   withCredentialsUserDic:credentialsUserDic];
    if (heading) { // radians to degrees
        heading = [NSNumber numberWithFloat:[heading floatValue]*180.0/M_PI];
    }
    
    // Make a new name for saving
    NSString * savingName = [NSString stringWithFormat:@"%@@miso.uam.es", name];
    
    // Save the model
    BOOL savedModel = [sharedData inModelDataAddModelWithName:savingName
                                                   components:components
                                                   references:references
                                                     latitude:latitude
                                                    longitude:longitude
                                                      heading:heading
                                    andWithCredentialsUserDic:credentialsUserDic];
    if (savedModel) {
        // PERSISTENT: SAVE MODEL
        // Save it in persistent memory
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        // TODO: Assign items by user. Alberto J. 15/11/2019.
        // Now there are models
        NSData * areModelsData = [userDefaults objectForKey:@"es.uam.miso/data/models/areModels"];
        if (areModelsData) {
            [userDefaults removeObjectForKey:@"es.uam.miso/data/models/areModels"];
        }
        areModelsData = nil; // ARC disposing
        areModelsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areModelsData forKey:@"es.uam.miso/data/models/areModels"];
        
        // Get the index in which names of models are saved for retrieve them later
        NSData * modelsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/models/index"];
        NSMutableArray * modelsIndex;
        if (modelsIndexData) {
            modelsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:modelsIndexData];
            [userDefaults removeObjectForKey:@"es.uam.miso/data/models/index"];
        } else {
            modelsIndex = [[NSMutableArray alloc] init];
        }
        
        // Get the model as it was saved in shared data
        NSMutableArray * modelDics = [sharedData fromModelDataGetModelDicWithName:savingName
                                                           withCredentialsUserDic:credentialsUserDic];
        if (modelDics.count == 0) {
            NSLog(@"[ERROR][VCFM] Saved model %@ could not be retrieved from shared data.", savingName);
        } else {
            if (modelDics.count > 1) {
                NSLog(@"[ERROR][VCFM] More than one saved model with identifier %@.", savingName);
            }
        }
        NSMutableDictionary * modelDic = [modelDics objectAtIndex:0];
        
        // Create a NSData for the model and save it using its name
        // Item's name
        NSString * modelIdentifier = savingName;
        // Save the name in the index
        [modelsIndex addObject:modelIdentifier];
        // Create the model's data and archive it
        NSData * modelData = [NSKeyedArchiver archivedDataWithRootObject:modelDic];
        NSString * modelKey = [@"es.uam.miso/data/models/models/" stringByAppendingString:savingName];
        [userDefaults setObject:modelData forKey:modelKey];
        // And save the new index
        modelsIndexData = nil; // ARC disposing
        modelsIndexData = [NSKeyedArchiver archivedDataWithRootObject:modelsIndex];
        [userDefaults setObject:modelsIndexData forKey:@"es.uam.miso/data/models/index"];
        NSLog(@"[INFO][VCFM] Model saved in device memory.");
        // END PERSISTENT: SAVE MODEL
        
        // Show the model
        NSMutableArray * model = [sharedData fromModelDataGetModelDicWithName:savingName
                                                       withCredentialsUserDic:credentialsUserDic];
        NSString * modelString = [NSString stringWithFormat:@"%@", [model objectAtIndex:0]];
        self.modelText.text = modelString;
        
        // Reset the measures and location componentes
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmd/reset"
                                                            object:nil];
        NSLog(@"[NOTI][VCFM] Notification \"lmd/reset\" posted.");
        
    } else {
        NSLog(@"[ERROR][VCFM] Model %@ could not be saved in device memory.", savingName);
        self.modelText.text = @"Model could not be saved in device memory. Please, try again";
        return;
    }
}

/*!
 @method submitTemporalModel
 @discussion This method is called when in a routine and when it is not the last routine mode; a temporal model is saved in session data.
 */
- (void) submitTemporalModel
{
    // TODO: Model must be a COPY of the items and the references must be removed. Alberto J. 2019/10/18
    
    // Check if name exists
    NSString * name = @"temp_model";
    
    // Retrieve the model components
    NSMutableArray * components = [[NSMutableArray alloc] init];
    NSMutableArray * items = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
    for (NSMutableDictionary * itemDic in items) {
        [components addObject:itemDic];
    }
    NSMutableArray * locations = [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                         andCredentialsUserDic:credentialsUserDic];
    for (NSMutableDictionary * locatedDic in locations) {
        [components addObject:locatedDic];
    }
    NSLog(@"[INFO][VCFM] Temporal model composing with components");
    for (NSMutableDictionary * comp in components) {
        NSLog(@"[INFO][VCFM] -> %@", comp);
    }
    
    // Retrieve the model references
    NSMutableArray * references = [sharedData fromSessionDataGetReferencesByUserDic:userDic
                                                             withCredentialsUserDic:credentialsUserDic];
    
    NSLog(@"[INFO][VCFM] and references");
    for (MDReference * ref in references) {
        NSLog(@"[INFO][VCFM] -> %@", ref);
    }
    
    // Check for coordinates
    NSNumber * latitude = [sharedData fromMeasuresDataGetMeanMeasureOfSort:@"devicelatitude"
                                                    withCredentialsUserDic:credentialsUserDic];
    NSNumber * longitude = [sharedData fromMeasuresDataGetMeanMeasureOfSort:@"devicelongitude"
                                                     withCredentialsUserDic:credentialsUserDic];
    // Check for heading
    NSNumber * heading = [sharedData fromMeasuresDataGetMeanMeasureOfSort:@"deviceheading"
                                                   withCredentialsUserDic:credentialsUserDic];
    if (heading) { // radians to degrees
        heading = [NSNumber numberWithFloat:[heading floatValue]*180.0/M_PI];
    }
    
    // Make a new name for saving
    NSString * savingName = [NSString stringWithFormat:@"%@@miso.uam.es", name];
    
    // Save the model
    NSMutableDictionary * modelDic = [[NSMutableDictionary alloc] init];
    modelDic[@"name"] = savingName;
    modelDic[@"sort"] = @"temporal_model";
    modelDic[@"components"] = components;
    modelDic[@"references"] = references;
    modelDic[@"latitude"] = latitude;
    modelDic[@"longitude"] = longitude;
    modelDic[@"heading"] = heading;
    [sharedData inSessionDataSetRoutineModel:modelDic
                           toUserWithUserDic:userDic
                       andCredentialsUserDic:credentialsUserDic];
    
    // Show the model
    // Display configurations
    [[self.modelText layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.modelText layer] setBorderWidth:.4];
    [[self.modelText layer] setCornerRadius:8.0f];
    NSString * modelString = [NSString stringWithFormat:@"%@", modelDic];
    self.modelText.text = modelString;
    
    // Reset the measures and location componentes
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmd/reset"
                                                        object:nil];
    NSLog(@"[NOTI][VCFM] Notification \"lmd/reset\" posted.");
}

/*!
 @method handleButtonFinish:
 @discussion This method handles the Finish button action and saves the model before segue to main manu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButonFinish:(id)sender
{
    [self performSegueWithIdentifier:@"fromFinalModelToMain" sender:sender];
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
    NSLog(@"[INFO][VCFM] Asked segue %@", [segue identifier]);
    
    if ([[segue identifier] isEqualToString:@"fromFinalModelToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variables and components
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setUserDic:userDic];
        [viewControllerMainMenu setSharedData:sharedData];
        
    }
}

@end

