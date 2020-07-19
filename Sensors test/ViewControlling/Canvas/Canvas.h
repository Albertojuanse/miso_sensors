//
//  Canvas.h
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RDPosition.h"
#import "SharedData.h"
#import <float.h>
#import "MDReference.h"
#import "VCDrawings.h"
#import "VCComponent.h"
#import "VCPosition.h"
#import "VCCorner.h"
#import "VCComponentInfo.h"
#import "VCType.h"

/*!
 @class Canvas
 @discussion This class extends UIView and creates an area in which draws can be displayed and it configuration.
 */
@interface Canvas: UIView <UIGestureRecognizerDelegate> {
    
    // Components
    SharedData * sharedData;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // For canvas relation of aspect
    BOOL firstDisplay;
    CGPoint center;
    CGFloat scale;
    RDPosition * barycenter;
    CGAffineTransform transformToCanvas;
}

typedef CGPoint NSPoint;

- (void)prepareCanvasWithSharedData:(SharedData *)givenSharedData
                            userDic:(NSMutableDictionary *)givenUserDic
              andCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
@end
