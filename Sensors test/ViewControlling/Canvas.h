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

/*!
 @class Canvas
 @discussion This class extends UIView and creates an area in which draws can be displayed and it configuration.
 */
@interface Canvas: UIView {
    
    // Components
    SharedData * sharedData;
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    
    // For canvas relation of aspect
    CGPoint center;
    float rWidth;
    float rHeight;
    RDPosition * barycenter;
}

typedef CGPoint NSPoint;

- (void)prepareCanvasWithSharedData:(SharedData*)givenSharedData
                            andUser:(NSMutableDictionary*)givenCredentialsUserDic;

@end
