//
//  ViewControllerRhoRhoModelling.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Canvas.h"

/*!
 @class ViewControllerRhoRhoModelling
 @discussion This class extends UIViewController and controls the interface for modelling whot the rho rho location system.
 */
@interface ViewControllerRhoRhoModelling : UIViewController{
    // For update canvas
    NSMutableDictionary * measuresDic;
    NSMutableDictionary * locatedDic;
}

@property (weak, nonatomic) IBOutlet UILabel *labelAX;
@property (weak, nonatomic) IBOutlet UILabel *labelAY;
@property (weak, nonatomic) IBOutlet UILabel *labelAZ;
@property (weak, nonatomic) IBOutlet UILabel *labelPosX;
@property (weak, nonatomic) IBOutlet UILabel *labelPosY;
@property (weak, nonatomic) IBOutlet UILabel *labelPosZ;
@property (weak, nonatomic) IBOutlet UILabel *labelCalibrated;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelGX;
@property (weak, nonatomic) IBOutlet UILabel *labelGY;
@property (weak, nonatomic) IBOutlet UILabel *labelGZ;
@property (weak, nonatomic) IBOutlet UILabel *labelDegP;
@property (weak, nonatomic) IBOutlet UILabel *labelDegR;
@property (weak, nonatomic) IBOutlet UILabel *labelDegY;

@property (weak, nonatomic) IBOutlet Canvas *canvas;

@property (weak, nonatomic) IBOutlet UIButton *buttonMeasure;
@property (weak, nonatomic) IBOutlet UIButton *buttonTravel;

@end

