//
//  VCType.h
//  Sensors test
//
//  Created by Alberto J. on 1/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MDType.h"


/*!
 @class VCType
 @discussion This class extends UIView and creates an area in which a type on screen is drawn.
 */
@interface VCType: UIView {
    
    UIColor * color;
    
}

-(instancetype)init;
-(instancetype)initWithFrame:(CGRect)frame;
-(instancetype)initWithFrame:(CGRect)frame
                    andColor:(UIColor *)initColor;

@end

