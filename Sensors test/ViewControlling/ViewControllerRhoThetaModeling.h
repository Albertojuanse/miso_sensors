//
//  ViewControllerRhoThetaModeling.h
//  Sensors test
//
//  Created by Alberto J. on 10/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerMainMenu.h"
#import "Canvas.h"

/*!
 @class ViewControllerRhoThetaModeling
 @discussion This class extends UIViewController and controls the interface for modeling with the rho theta location system.
 */
@interface ViewControllerRhoThetaModeling : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    // For update canvas
    NSMutableDictionary * measuresDic;
    NSMutableDictionary * locatedDic;
    
    // State flags
    BOOL idle;
    BOOL measuring;
    
    // Variables
    NSMutableArray * beaconsAndPositionsRegistered;
    NSMutableArray * entitiesRegistered;
    NSString * uuidChosenByUser;
    
}

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableBeaconsAndPositions;
@property (weak, nonatomic) IBOutlet Canvas *canvas;
@property (weak, nonatomic) IBOutlet UIButton *buttonMeasure;

- (void) setBeaconsAndPositionsRegistered:(NSMutableArray *)newBeaconsAndPositionsRegistered;
- (void) setEntitiesRegistered:(NSMutableArray *)newEntitiesRegistered;

@end