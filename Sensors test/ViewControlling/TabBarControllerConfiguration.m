//
//  TabBarControllerConfiguration.m
//  Sensors test
//
//  Created by Alberto J. on 24/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "TabBarControllerConfiguration.h"

@implementation TabBarConfiguration

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Set this class as the delegated one to handle tab's events
    self.delegate = self;
    
    // Get views instances
    NSArray * viewControllers = [self viewControllers];
    for (UIViewController * view in viewControllers) {
        NSString * viewClass = NSStringFromClass([view class]);
        if ([viewClass containsString:@"Modes"]){
            viewControllerConfigurationModes = (ViewControllerConfigurationModes*)view;
            // Pass the variables as in segues
            [viewControllerConfigurationModes setUserDic:userDic];
            [viewControllerConfigurationModes setCredentialsUserDic:credentialsUserDic];
        }
        if ([viewClass containsString:@"Metamodels"]){
            viewControllerConfigurationMetamodels = (ViewControllerConfigurationMetamodels*)view;
            // Pass the variables as in segues
            [viewControllerConfigurationMetamodels setUserDic:userDic];
            [viewControllerConfigurationMetamodels setCredentialsUserDic:credentialsUserDic];
        }
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

#pragma mark - UITabBarControllerDelegate delegated methods

/*!
 @method tabBarController:didSelectViewController:
 @discussion This method handles the event of changing between tabs.
 */
- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    if (viewController == viewControllerConfigurationModes) {
    }
    if (viewController == viewControllerConfigurationMetamodels) {
    }
}

@end
