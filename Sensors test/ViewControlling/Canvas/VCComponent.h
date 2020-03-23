//
//  VCComponent.h
//  Sensors test
//
//  Created by Alberto J. on 17/9/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RDPosition.h"

/*!
 @class VCComponent
 @discussion This class extends UIView and creates an area in which a position on screen is drawn.
 */
@interface VCComponent: UIView <UIGestureRecognizerDelegate, NSCoding, NSItemProviderReading, NSItemProviderWriting, UIDragInteractionDelegate, UIDropInteractionDelegate> {
    
    // Variables
    RDPosition * realPosition;
    RDPosition * canvasPosition;
    NSString * uuid;
    
    // User gestures
    UITapGestureRecognizer * tapGestureRecognizer;
    UITapGestureRecognizer * doubleTapGestureRecognizer;
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
