//
//  VCPositionInfo.h
//  Sensors test
//
//  Created by Alberto J. on 12/03/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RDPosition.h"

/*!
 @class VCPositionInfo
 @discussion This class extends UIView and creates an area in which a position's info is shown.
 */
@interface VCPositionInfo: UIView {
    
    RDPosition * realPosition;
    NSString * uuid;
    
}

-(instancetype)init;
-(instancetype)initWithFrame:(CGRect)frame
                realPosition:(RDPosition *)initRealPosition
                     andUUID:(NSString *)initUUID;

@end
