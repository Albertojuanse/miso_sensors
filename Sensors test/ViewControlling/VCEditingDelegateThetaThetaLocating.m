//
//  VCEditingDelegateThetaThetaLocating.m
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCEditingDelegateThetaThetaLocating.h"

@implementation VCEditingDelegateThetaThetaLocating : NSObject

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // Description for errors that View Controller Editing must use when in ThetaThetaLocating mode.
        errorDescription = @"[VCETTL]";
    }
    
    return self;
}

#pragma mark - Instance methods
/*!
@method getErrorDescription
@discussion This method returns the description for errors that ViewControllerEditing must use when in ThetaThetaLocating mode.
*/
- (NSString *)getErrorDescription
{
    return errorDescription;
}

@end
