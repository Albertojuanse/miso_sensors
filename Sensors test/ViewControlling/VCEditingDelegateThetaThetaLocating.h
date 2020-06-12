//
//  VCEditingDelegateThetaThetaLocating.h
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "VCEditingDelegate.h"

/*!
 @class VCEditingDelegateThetaThetaLocating
 @discussion This class implements the protocol VCEditingDelegate to define the behaviour of the editing view controller in ThetaThetaLocating mode.
 */
@interface VCEditingDelegateThetaThetaLocating: NSObject<VCEditingDelegate>{
    
    NSString * errorDescription;
    
}

- (instancetype)init;
- (NSString *)getErrorDescription;

@end
