//
//  VCPosition.h
//  Sensors test
//
//  Created by Alberto J. on 17/9/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RDPosition.h"

/*!
 @class VCPosition
 @discussion This class extends UIView and creates an area in which a position on screen is drawn.
 */
@interface VCPosition: CALayer {
}

-(instancetype)init;
-(instancetype)initWithFrame:(CGRect)frame;

@end
