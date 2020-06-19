//
//  ViewControllerEditComponent.m
//  Sensors test
//
//  Created by Alberto J. on 17/03/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerEditComponent.h"

@implementation ViewControllerEditComponent

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Visualization
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                      blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:1.0
                                      ]
                            forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    
    // Picker delegates
    self.typePicker.dataSource = self;
    self.typePicker.delegate = self;
}

/*!
@method viewWillAppear:
@discussion This method is called when the view is going to be shown.
*/
- (void)viewWillAppear:(BOOL)animated
{
    itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                   andCredentialsUserDic:credentialsUserDic];
    MDType * typeItemChosenByUser = itemChosenByUser[@"type"];
    if (typeItemChosenByUser) {
        typeChosenByUser = typeItemChosenByUser;
    } else {
        typeChosenByUser = [modeTypes objectAtIndex:0];
    }
    [self showAttributesOfTypeChosenByUser];
    
    NSLog(@"[INFO][VCEC] The user is editing %@", itemChosenByUser[@"uuid"]);
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

/*!
 @method setSharedData:
 @discussion This method sets the shared data collection.
 */
- (void) setSharedData:(SharedData *)givenSharedData
{
    sharedData = givenSharedData;
}

/*!
 @method setModeTypes:
 @discussion This method sets the NSMutableArray variable 'modeTypes'.
 */
- (void) setModeTypes:(NSMutableArray *)givenModeTypes
{
    modeTypes = givenModeTypes;
}

#pragma mark - Buttons event handlers

/*!
 @method handleButtonCancel:
 @discussion This method handles the 'cancel' button action and segues back.
 */
- (IBAction)handleButtonCancel:(id)sender
{
    // Dismiss the popover view
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*!
@method handleButtonEdit:
@discussion This method handles the 'edit' button action, save the changes, and segues back.
*/
- (IBAction)handleButtonEdit:(id)sender
{
    // Dismiss the popover view
    itemChosenByUser[@"type"] = nil; // ARC dispose
    itemChosenByUser[@"type"] = typeChosenByUser; // ARC dispose
    NSLog(@"[NOTI][VCEC] Notification \"canvas/refresh\" posted.");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"canvas/refresh"
     object:nil];
    [self dismissViewControllerAnimated:YES completion:Nil];
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

#pragma mark - UIPopoverPresentationControllerDelegate methods
/*!
@method adaptivePresentationStyleForPresentationController:
@discussion This method is called by the UIPopoverPresentationControllerDelegate protocol.
*/
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - UIPickerViewDelegate methods
/*!
@method numberOfComponentsInPickerView
@discussion Called by the picker view when it needs the number of components.
*/
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/*!
@method pickerView:numberOfRowsInComponent:
@discussion Called by the picker view when it needs the number of rows for a specified component.
*/
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRows = modeTypes.count;
    return numberOfRows;
}

/*!
@method pickerView:rowHeightForComponent:
@discussion Called by the picker view when it needs the row height to use for drawing row content.
*/
- (CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
       NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * rowHeight = layoutDic[@"pickers/rowHeight"];
    return [rowHeight floatValue];
}

/*!
@method pickerView:widthForComponent:
@discussion Called by the picker view when it needs the row width to use for drawing row content.
*/
- (CGFloat)pickerView:(UIPickerView *)pickerView
    widthForComponent:(NSInteger)component
{
    CGRect selfViewFrame = [self.view frame];
    return selfViewFrame.size.width;
}

/*!
@method pickerView:widthForComponent:
@discussion Called by the picker view when it needs the title to use for a given row in a given component.
*/
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [[modeTypes objectAtIndex:row] getName];
}

/*!
@method pickerView:didSelectRow:inComponent:
@discussion Called by the picker view when the user selects a row in a component.
*/
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    NSLog(@"[INFO][VCEC] User did pick the type %@", [modeTypes objectAtIndex:row]);
    
    // Set type as chosen one
    typeChosenByUser = [modeTypes objectAtIndex:row];
    [self showAttributesOfTypeChosenByUser];
    return;
}

/*!
@method showAttributesOfTypeChosenByUser
@discussion This method is called when the user picks a type and compose the layout for showing the different attibutes of the type.
*/
- (void)showAttributesOfTypeChosenByUser
{
    // Show attributes information
    NSMutableArray * typeChosenByUserAttributes = [typeChosenByUser getAttributes];
    NSLog(@"[INFO][VCEC] Showing %tu attributes of type %@.", typeChosenByUserAttributes.count, typeChosenByUser);
    
    UIView * lastAddedElement;
    // Remove previous subviews
    for (UIView * eachView in self.scrolledView.subviews) {
        [eachView removeFromSuperview];
    }
    
    // Show attribute title label
    if (typeChosenByUserAttributes.count > 0) {
        UILabel * attributesTitleLabel = [[UILabel alloc] init];
        [attributesTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [attributesTitleLabel setFont:[UIFont systemFontOfSize:17.0]];
        [attributesTitleLabel setText:@"🏷"];
        // Add the label
        [self.scrolledView addSubview:attributesTitleLabel];
        // Leading constraint
        NSLayoutConstraint * attributesTitleLabelLeading = [NSLayoutConstraint
                                                            constraintWithItem:attributesTitleLabel
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                            toItem:self.scrolledView
                                                            attribute:NSLayoutAttributeLeading
                                                            multiplier:1.0
                                                            constant:16.0];
        // Trailing constraint
        NSLayoutConstraint * attributesTitleLabelTrailing =[NSLayoutConstraint
                                                            constraintWithItem:attributesTitleLabel
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                            toItem:self.scrolledView
                                                            attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.0
                                                            constant:0.0];
        // Top constraint
        NSLayoutConstraint * attributesTitleLabelTop = [NSLayoutConstraint
                                                        constraintWithItem:attributesTitleLabel
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                        toItem:self.scrolledView
                                                        attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                        constant:0.0];
        // Height constraint
        NSLayoutConstraint * attributesTitleLabelHeight = [NSLayoutConstraint
                                                           constraintWithItem:attributesTitleLabel
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                           constant:21.0];
        //Add constraints to the Parent
        [self.scrolledView addConstraint:attributesTitleLabelTrailing];
        [self.scrolledView addConstraint:attributesTitleLabelLeading];
        [self.scrolledView addConstraint:attributesTitleLabelTop];
        //Add height constraint to the subview, as subview owns it.
        [attributesTitleLabel addConstraint:attributesTitleLabelHeight];
        
        NSLog(@"[INFO][VCEC] Showing attributes title label.");

        // Set this label as the last element added
        lastAddedElement = (UIView *)attributesTitleLabel;
    }
    
    // For each attribute compose a layout with label and textField
    if (typeChosenByUserAttributes.count > 0) {
        for (MDAttribute * eachAttribute in typeChosenByUserAttributes) {
            
            // Set attribute's name label
            UILabel * attributesNameLabel = [[UILabel alloc] init];
            [attributesNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [attributesNameLabel setFont:[UIFont systemFontOfSize:17.0]];
            [attributesNameLabel setText:[NSString stringWithFormat:@"%@:", [eachAttribute getName]]];
            
            // Add the label
            [self.scrolledView addSubview:attributesNameLabel];
            // Leading constraint
            NSLayoutConstraint * attributesNameLabelLeading = [NSLayoutConstraint
                                                               constraintWithItem:attributesNameLabel
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                               toItem:self.scrolledView
                                                               attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                               constant:24.0];
            // Trailing constraint
            NSLayoutConstraint * attributesNameLabelTrailing =[NSLayoutConstraint
                                                               constraintWithItem:self.scrolledView
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                               toItem:attributesNameLabel
                                                               attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                               constant:24.0];
            // Top constraint
            NSLayoutConstraint * attributesNameLabelTop = [NSLayoutConstraint
                                                           constraintWithItem:attributesNameLabel
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                           toItem:lastAddedElement
                                                           attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                           constant:16.0];
            // Height constraint
            NSLayoutConstraint * attributesNameLabelHeight = [NSLayoutConstraint
                                                              constraintWithItem:attributesNameLabel
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                              constant:21.0];
            //Add constraints to the Parent
            [self.scrolledView addConstraint:attributesNameLabelTrailing];
            [self.scrolledView addConstraint:attributesNameLabelLeading];
            [self.scrolledView addConstraint:attributesNameLabelTop];
            //Add height constraint to the subview, as subview owns it.
            [attributesNameLabel addConstraint:attributesNameLabelHeight];
            
            // Set this label as the last element added
            lastAddedElement = (UIView *)attributesNameLabel;
            
            // Set attribute's textField
            UITextField * attributesTextField = [[UITextField alloc] init];
            [attributesTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
            [attributesTextField setBorderStyle:UITextBorderStyleRoundedRect];
            [attributesTextField setText:[NSString stringWithFormat:@"%@", [eachAttribute getAttribute]]];
            
            // Add the label
            [self.scrolledView addSubview:attributesTextField];
            // Leading constraint
            NSLayoutConstraint * attributesTextFieldLeading = [NSLayoutConstraint
                                                               constraintWithItem:attributesTextField
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                               toItem:self.scrolledView
                                                               attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                               constant:24.0];
            // Trailing constraint
            NSLayoutConstraint * attributesTextFieldTrailing =[NSLayoutConstraint
                                                               constraintWithItem:self.scrolledView
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                               toItem:attributesTextField
                                                               attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                               constant:24.0];
            // Top constraint
            NSLayoutConstraint * attributesTextFieldTop = [NSLayoutConstraint
                                                           constraintWithItem:attributesTextField
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                           toItem:lastAddedElement
                                                           attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                           constant:8.0];
            //Add constraints to the Parent
            [self.scrolledView addConstraint:attributesTextFieldTrailing];
            [self.scrolledView addConstraint:attributesTextFieldLeading];
            [self.scrolledView addConstraint:attributesTextFieldTop];
            
            // Set this label as the last element added
            lastAddedElement = (UIView *)attributesTextField;
        }
    }
}
@end
