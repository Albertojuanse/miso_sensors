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
#import <float.h>

/*!
 @class Canvas
 @discussion This class extends UIView and creates an area in which draws can be displayed and it configuration.
 */
@interface Canvas: UIView {
    
    // Variables
    NSString * mode;
    
    // For canvas relation of aspect
    CGPoint center;
    float rWidth;
    float rHeight;
    RDPosition * barycenter;
}

typedef CGPoint NSPoint;

@property NSMutableDictionary * measuresDic;
@property NSMutableDictionary * locatedDic;

-(void)prepareCanvasWithMode:(NSString *) mode;

@end
