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
    RDPosition * canvasPosition;
    NSString * uuid;
    
}

-(instancetype)init;
-(instancetype)initWithFrame:(CGRect)frame;
-(instancetype)initWithFrame:(CGRect)frame
                realPosition:(RDPosition *)initRealPosition
              canvasPosition:(RDPosition *)initCanvasPosition
                     andUUID:(NSString *)initUUID;
- (RDPosition *)getRealPosition;
- (void)setRealPosition:(RDPosition *)givenRealPosition;
- (RDPosition *)getCanvasPosition;
- (void)setCanvasPosition:(RDPosition *)givenCanvasPosition;
- (NSString *)getUUID;
- (void)setUUID:(NSString *)givenUUID;


@end
