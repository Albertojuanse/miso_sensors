//
//  ViewControllerThetaThetaLocating.h
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerMainMenu.h"
#import "Canvas.h"

/*!
 @class ViewControllerThetaThetaLocating
 @discussion This class extends UIViewController and controls the interface for locating the device with the theta theta location system.
 */
@interface ViewControllerThetaThetaLocating : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    // For update canvas
    NSMutableDictionary * measuresDic;
    NSMutableDictionary * locatedDic;
    
    // State flags
    BOOL idle;
    BOOL measuring;
    
    // Variables
    NSMutableArray * beaconsAndPositionsRegistered;
    NSMutableArray * typesRegistered;
    NSMutableArray * beaconsAndPositionsChosen;
    NSMutableArray * beaconsAndPositionsChosenIndexes;
    NSString * locatedPositionUUID;
    NSString * typeChosenByUser;
    NSString * uuidChosenByUser;
    RDPosition * positionChosenByUser;
    
}

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableBeaconsAndPositionsChosen;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;
@property (weak, nonatomic) IBOutlet Canvas *canvas;
@property (weak, nonatomic) IBOutlet UIButton *buttonMeasure;

- (void) setBeaconsAndPositionsRegistered:(NSMutableArray *)newBeaconsAndPositionsRegistered;
- (void) setBeaconsAndPositionsChosen:(NSMutableArray *)newBeaconsAndPositionsChosen;
- (void) setBeaconsAndPositionsChosenIndexes:(NSMutableArray *)newBeaconsAndPositionsChosenIndexes;
- (void) setTypesRegistered:(NSMutableArray *)newTypesRegistered;

@end
