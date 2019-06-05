//
//  Canvas.h
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RDPosition.h"
#import <float.h>

/*!
 @class Canvas
 @discussion This class extends UIView and creates an area in which draws can be displayed and it configuration.
 */
@interface Canvas: UIView {
    
    // Data for display
    NSMutableArray * displayedUUID;
    NSString * displayedUUIDString;
    
    // For canvas relation of aspect
    float rWidth;
    float rHeight;
}

typedef CGPoint NSPoint;

@property NSMutableDictionary * rangedBeaconsDic;
@property NSMutableArray * currentLayers;

- (void) prepareCanvas;

@end
