//
//  VCPosition.m
//  Sensors test
//
//  Created by Alberto J. on 17/9/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "VCPosition.h"

@implementation VCPosition: UIView

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/*!
 @method initWithFrame:
 @discussion Constructor with a given specific frame in which be embedded.
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - Drawing methods
/*!
 @method drawRect:
 @discussion This method controls the display of a new drawn area; is called when a new draw must be created and displayed.
 */
- (void)drawRect:(CGRect)rect {
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    
    // Draw the point
    UIBezierPath * positionBezierPath = [UIBezierPath bezierPath];
    [positionBezierPath moveToPoint:rectOrigin];
    [positionBezierPath addLineToPoint:CGPointMake(rectOrigin.x + rectWidth, rectOrigin.y + rectHeight)];
    [positionBezierPath moveToPoint:CGPointMake(rectOrigin.x + rectWidth, rectOrigin.y)];
    [positionBezierPath addLineToPoint:CGPointMake(rectOrigin.x, rectOrigin.y + rectHeight)];
}


@end
