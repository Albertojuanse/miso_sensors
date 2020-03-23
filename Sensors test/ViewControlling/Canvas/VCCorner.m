//
//  VCCorner.m
//  Sensors test
//
//  Created by Alberto J. on 23/03/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCCorner.h"

@implementation VCCorner: VCComponent

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
    
    // Draw the path
    UIBezierPath * cornerBezierPath = [UIBezierPath bezierPath];
    [cornerBezierPath moveToPoint:rectOrigin];
    [cornerBezierPath addLineToPoint:CGPointMake(rectOrigin.x, rectOrigin.y + rectWidth)];
    [cornerBezierPath addLineToPoint:CGPointMake(rectOrigin.x + rectHeight, rectOrigin.y + rectWidth)];
    [cornerBezierPath addLineToPoint:CGPointMake(rectOrigin.x + rectHeight, rectOrigin.y)];
    [cornerBezierPath addLineToPoint:rectOrigin];
    CAShapeLayer * cornerLayer = [[CAShapeLayer alloc] init];
    [cornerLayer setPath:cornerBezierPath.CGPath];
    [cornerLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [cornerLayer setFillColor:[UIColor clearColor].CGColor];
    [[self layer] addSublayer:cornerLayer];

}

@end
