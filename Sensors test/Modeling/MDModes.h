//
//  MDModes.h
//  Sensors test
//
//  Created by Alberto J. on 17/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

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
typedef struct {
    int kModeMonitoring = 0;
    int kModeRhoRhoModelling = 1;
    int kModeRhoThetaModelling = 2;
    int kModeThetaThetaModelling = 3;
    int kModeRhoRhoLocating = 4;
    int kModeRhoThetaLocating = 5;
    int kModeThetaThetaLocating = 6;
    int kModeGPSSelfLocating = 7;
    int kModeCompassSelfLocating = 8;
} MDModes;
