//
//  ViewController.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "Canvas.h"

@interface ViewController : UIViewController{
    // For update canvas
    NSMutableArray * rangedBeacons;
}

@property (weak, nonatomic) IBOutlet UILabel *labelAX;
@property (weak, nonatomic) IBOutlet UILabel *labelAY;
@property (weak, nonatomic) IBOutlet UILabel *labelAZ;
@property (weak, nonatomic) IBOutlet UILabel *labelPosX;
@property (weak, nonatomic) IBOutlet UILabel *labelPosY;
@property (weak, nonatomic) IBOutlet UILabel *labelPosZ;
@property (weak, nonatomic) IBOutlet UILabel *labelCalibrated;
@property (weak, nonatomic) IBOutlet UILabel *labelGX;
@property (weak, nonatomic) IBOutlet UILabel *labelGY;
@property (weak, nonatomic) IBOutlet UILabel *labelGZ;
@property (weak, nonatomic) IBOutlet UILabel *labelDegP;
@property (weak, nonatomic) IBOutlet UILabel *labelDegR;
@property (weak, nonatomic) IBOutlet UILabel *labelDegY;

@property (weak, nonatomic) IBOutlet UILabel *text;

@property (weak, nonatomic) IBOutlet Canvas *canvas;


@end

