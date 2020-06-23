//
//  ViewControllerMeasure.m
//  Sensors test
//
//  Created by Alberto J. on 23/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerMeasure.h"

@implementation ViewControllerMeasure

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Visualization
    UIImage * measureImage = [VCDrawings imageForMeasureInNormalThemeColor];
    [self.measureImageView setImage:measureImage];
    UIImage * tutorialImage = [UIImage imageNamed:@"Measure rhoTheta.png"];
    [self.tutorialImageView setImage:tutorialImage];
    
    // Gestures
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(measureImageViewTapped)];
    singleTap.numberOfTapsRequired = 1;
    self.measureImageView.userInteractionEnabled = YES;
    [self.measureImageView addGestureRecognizer:singleTap];
}

/*!
@method viewDidLoad
@discussion This method is called when the view is going to be shown.
*/
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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


#pragma mark - Buttons event handlers
/*!
 @method measureImageViewTapped
 @discussion This method handles the 'measure' imageView action and starts the measure.
 */
- (void) measureImageViewTapped
{
    // Visualization
    [self.measureImageView setImage:[VCDrawings imageForMeasureInNormalThemeColor]];
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

@end
