//
//  ViewControllerRhoRhoModeling.h
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerMainMenu.h"
#import "Canvas.h"

/*!
 @class ViewControllerRhoRhoModeling
 @discussion This class extends UIViewController and controls the interface for modeling with the rho rho location system.
 */
@interface ViewControllerRhoRhoModeling : UIViewController{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    
    // For update canvas
    NSMutableDictionary * measuresDic;
    NSMutableDictionary * locatedDic;
    
    // State flags
    BOOL idle;
    BOOL measuring;
    BOOL traveling;
    
    // Variables
    NSMutableArray * beaconsAndPositionsRegistered;
    NSMutableArray * typesRegistered;
    
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

- (void) setCredentialsUserDic:(NSMutableDictionary *)newCredentialsUserDic;
- (void) setBeaconsAndPositionsRegistered:(NSMutableArray *)newBeaconsAndPositionsRegistered;
- (void) setTypesRegistered:(NSMutableArray *)newTypesRegistered;

@end

