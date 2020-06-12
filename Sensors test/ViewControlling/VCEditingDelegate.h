//
//  VCEditingDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

/*!
 @protocol VCEditingDelegate
 @discussion Abstract definition of the delegate to define the behaviour of the editing view controller in each mode.
 */
@protocol VCEditingDelegate

@required
- (instancetype)init;
- (NSString *)getErrorDescription;
@end
