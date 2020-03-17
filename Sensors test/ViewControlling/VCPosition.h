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
@interface VCPosition: UIView <UIGestureRecognizerDelegate> {
    
    // Variables
    RDPosition * realPosition;
    NSString * uuid;
    
    // User gestures
    UITapGestureRecognizer * tapGestureRecognizer;
}

-(instancetype)init;
-(instancetype)initWithFrame:(CGRect)frame;
-(instancetype)initWithFrame:(CGRect)frame
                realPosition:(RDPosition *)initRealPosition
                     andUUID:(NSString *)initUUID;

@end
