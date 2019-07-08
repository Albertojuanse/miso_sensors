//
//  ViewControllerAddBeaconMenu.h
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class ViewControllerAddBeaconMenu
 @discussion This class extends UIViewController and controls the main menu for adding new beacons to the app.
 */
@interface ViewControllerAddBeaconMenu : UIViewController{
    
}

@property (weak, nonatomic) IBOutlet UITextField *textUUID;
@property (weak, nonatomic) IBOutlet UITextField *textMajor;
@property (weak, nonatomic) IBOutlet UITextField *textMinor;
@property (weak, nonatomic) IBOutlet UILabel *textError;

@end



