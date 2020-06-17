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
        
        // USE CASE PAPER
        NSMutableArray * itemData = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
        for (NSMutableDictionary * itemDic in itemData) {
            NSString * itemIdentifier = itemDic[@"identifier"];
            if ([itemIdentifier isEqualToString:@"position95_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position95_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position85_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position85_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position35_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position35_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position2_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position2_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position05_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position05_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position0_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position0_3@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position0_2@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position0_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column75_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column75_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column59_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column59_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column35_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column35_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column19_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column19_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"entrance95_25@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"entrance9_08@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"entrance9_42@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"entrance0_25@miso.uam.es"]
                )
            {
                [sharedData  inSessionDataSetAsChosenItem:itemDic
                                        toUserWithUserDic:userDic
                                   withCredentialsUserDic:credentialsUserDic];
            }
            
        }
        // END USE CASE PAPER
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
    [self.backButton setTitleColor:normalThemeColor
                          forState:UIControlStateNormal];
    [self.backButton setTitleColor:disabledThemeColor
                          forState:UIControlStateDisabled];
    [self.goButton setTitleColor:normalThemeColor
                          forState:UIControlStateNormal];
    [self.goButton setTitleColor:disabledThemeColor
                          forState:UIControlStateDisabled];
    [self.signOutButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [self.logOutButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
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

#pragma mark - Other methods
/*!
@method imageForPositionInNormalThemeColor
@discussion This method draws the position icon for table cells.
*/
- (UIImage *)imageForPositionInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    
    // Points for Bezier path
    CGFloat circlesCenterX = rectOrigin.x + rectWidth/2;
    CGFloat circlesCenterY = rectOrigin.y + rectHeight/3;
    CGPoint circlesCenter = CGPointMake(circlesCenterX, circlesCenterY);
    CGPoint arrowPoint = CGPointMake(rectWidth/2, rectHeight);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                   alpha:1.0
    ];
    [normalThemeColor setStroke];
    [normalThemeColor setFill];
    
    UIBezierPath * outterRightBezierPath = [UIBezierPath bezierPath];
    [outterRightBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:3.0*M_PI/2.0 endAngle:5.0*M_PI/6.0 clockwise:NO];
    [outterRightBezierPath addLineToPoint:arrowPoint];
    [outterRightBezierPath fill];
    CGContextAddPath(context, outterRightBezierPath.CGPath);
    
    UIBezierPath * outterLeftBezierPath = [UIBezierPath bezierPath];
    [outterLeftBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:3.0*M_PI/2.0 endAngle:M_PI/6.0 clockwise:YES];
    [outterLeftBezierPath addLineToPoint:arrowPoint];
    [outterLeftBezierPath fill];
    CGContextAddPath(context, outterLeftBezierPath.CGPath);
    
    [[UIColor whiteColor] setFill]; // Clear
    
    UIBezierPath * innerCircleBezierPath = [UIBezierPath bezierPath];
    [innerCircleBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:0 endAngle:2.0*M_PI clockwise:YES];
    [innerCircleBezierPath stroke];
    [innerCircleBezierPath fill];
    CGContextAddPath(context, innerCircleBezierPath.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
@method imageForBeaconInNormalThemeColor
@discussion This method draws the beacon icon for table cells.
*/
- (UIImage *)imageForBeaconInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    
    // Points for Bezier path
    CGFloat circlesCenterX = rectOrigin.x + rectWidth/2;
    CGFloat circlesCenterY = rectOrigin.y + rectHeight/3;
    CGPoint circlesCenter = CGPointMake(circlesCenterX, circlesCenterY);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:1.0
                                  ];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterRightArcBezierPath = [UIBezierPath bezierPath];
    [outterRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [outterRightArcBezierPath stroke];
    CGContextAddPath(context, outterRightArcBezierPath.CGPath);
    
    UIBezierPath * outterLeftArcBezierPath = [UIBezierPath bezierPath];
    [outterLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [outterLeftArcBezierPath stroke];
    CGContextAddPath(context, outterLeftArcBezierPath.CGPath);
    
    UIBezierPath * middleRightArcBezierPath = [UIBezierPath bezierPath];
    [middleRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/4 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [middleRightArcBezierPath stroke];
    CGContextAddPath(context, middleRightArcBezierPath.CGPath);
    
    UIBezierPath * middleLeftArcBezierPath = [UIBezierPath bezierPath];
    [middleLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/4 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [middleLeftArcBezierPath stroke];
    CGContextAddPath(context, middleLeftArcBezierPath.CGPath);
    
    UIBezierPath * innerRightArcBezierPath = [UIBezierPath bezierPath];
    [innerRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [innerRightArcBezierPath stroke];
    CGContextAddPath(context, innerRightArcBezierPath.CGPath);
    
    UIBezierPath * innerLeftArcBezierPath = [UIBezierPath bezierPath];
    [innerLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [innerLeftArcBezierPath stroke];
    CGContextAddPath(context, innerLeftArcBezierPath.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
@method imageForModelInNormalThemeColor
@discussion This method draws the beacon icon for table cells.
*/
- (UIImage *)imageForModelInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    CGFloat margin = rectWidth * 0.1;
    CGFloat splitLineHeith = rectHeight * 0.2;
    CGFloat minusHeith = rectHeight * 0.3;
    CGFloat minusX = rectHeight * 0.15;
    CGFloat minusLength = rectHeight * 0.15;
    
    // Points for Bezier path
    CGPoint upperLeftCorner = CGPointMake(rectOrigin.x + margin,
                                          rectOrigin.y + margin);
    CGPoint upperRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                           rectOrigin.y + margin);
    CGPoint bottomRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                            rectOrigin.y + rectHeight - margin);
    CGPoint bottomLeftCorner = CGPointMake(rectOrigin.x + margin,
                                           rectOrigin.y + rectHeight - margin);
    CGPoint leftSplitLine = CGPointMake(rectOrigin.x + margin,
                                        rectOrigin.y + margin + splitLineHeith);
    CGPoint rightSplitLine = CGPointMake(rectOrigin.x + rectWidth - margin,
                                         rectOrigin.y + margin + splitLineHeith);
    CGPoint leftMinusLine = CGPointMake(rectOrigin.x + minusX,
                                        rectOrigin.y + margin + minusHeith);
    CGPoint rightMinusLine = CGPointMake(rectOrigin.x + minusX + minusLength,
                                         rectOrigin.y + margin + minusHeith);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:1.0
                                  ];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterSquare = [UIBezierPath bezierPath];
    [outterSquare moveToPoint:upperLeftCorner];
    [outterSquare addLineToPoint:upperRightCorner];
    [outterSquare addLineToPoint:bottomRightCorner];
    [outterSquare addLineToPoint:bottomLeftCorner];
    [outterSquare addLineToPoint:upperLeftCorner];
    [outterSquare moveToPoint:leftSplitLine];
    [outterSquare addLineToPoint:rightSplitLine];
    [outterSquare moveToPoint:leftMinusLine];
    [outterSquare addLineToPoint:rightMinusLine];
    [outterSquare stroke];
    CGContextAddPath(context, outterSquare.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

