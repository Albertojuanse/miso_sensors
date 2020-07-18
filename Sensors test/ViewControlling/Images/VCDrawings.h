//
//  VCDrawings.h
//  Sensors test
//
//  Created by Alberto J. on 18/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VCDrawings.h"

/*!
 @class VCDrawings
 @discussion This class is a factory of drawings and icon as UIImages.
 */
@interface VCDrawings: NSObject

+ (UIColor *)getNormalThemeColor;
+ (UIColor *)getDisabledThemeColor;
+ (UIColor *)getCanvasColor;
+ (UIImage *)imageForPositionInNormalThemeColor;
+ (UIImage *)imageForBeaconInNormalThemeColor;
+ (UIImage *)imageForModelInNormalThemeColor;
+ (UIImage *)imageForAddManualInNormalThemeColor;
+ (UIImage *)imageForAddMeasureInNormalThemeColor;
+ (UIImage *)imageForMeasureInNormalThemeColor;
+ (UIImage *)imageForMeasureInDisabledThemeColor;

@end
