//
//  MDModes.h
//  Sensors test
//
//  Created by Alberto J. on 17/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>

/*!
 @typedef MDModes
 @brief  Working modes for modelling.
 @discussion Each value of this structure represents a different working mode that user can choose, depending on technology, mathematical calculus, etc. desired.
 @field kModeMonitoring iBeacon registry mode.
 @field kModeRhoRhoModelling Adding componnets to the model using the device position by rho rho mathematical means.
 @field kModeRhoThetaModelling Adding componnets to the model using the device position by rho theta mathematical means.
 @field kModeThetaThetaModelling Adding componnets to the model using the device position by theta theta mathematical means.
 @field kModeRhoRhoLocating Adding componnets to the model locating other space positions by rho rho mathematical means.
 @field kModeRhoThetaLocating Adding componnets to the model locating other space positions by rho theta mathematical means.
 @field kModeThetaThetaLocating Adding componnets to the model locating other space positions by theta theta mathematical means.
 @field kModeGPSSelfLocating measures GPS location as a reference for the final model.
 @field kModeCompassSelfLocating measures heading using the compass as a reference for the final model.
 */
typedef NS_ENUM(int, MDModes){
    kModeMonitoring,
    kModeRhoRhoModelling,
    kModeRhoThetaModelling,
    kModeThetaThetaModelling,
    kModeRhoRhoLocating,
    kModeRhoThetaLocating,
    kModeThetaThetaLocating,
    kModeGPSSelfLocating,
    kModeCompassSelfLocating
};

/*!
 @class MDMode
 @discussion A working mode that user can choose, depending on technology, mathematical calculus, etc. desired
 */
@interface MDMode: NSObject <NSCoding> {
    int mode;
}

@end
