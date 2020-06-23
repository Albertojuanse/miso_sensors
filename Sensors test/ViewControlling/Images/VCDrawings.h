//
//  VCDrawings.h
//  Sensors test
//
//  Created by Alberto J. on 18/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class VCDrawings
 @discussion This class is a factory of drawings and icon as UIImages.
 */
@interface VCDrawings: NSObject

+ (UIImage *)imageForPositionInNormalThemeColor;
+ (UIImage *)imageForBeaconInNormalThemeColor;
+ (UIImage *)imageForModelInNormalThemeColor;
+ (UIImage *)imageForMeasureInNormalThemeColor;
+ (UIImage *)imageForMeasureInDisabledThemeColor;

@end
