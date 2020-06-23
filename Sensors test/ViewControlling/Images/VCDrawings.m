//
//  VCDrawings.m
//  Sensors test
//
//  Created by Alberto J. on 18/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCDrawings.h"

@implementation VCDrawings

/*!
@method imageForPositionInNormalThemeColor
@discussion This method draws the position icon for table cells.
*/
+ (UIImage *)imageForPositionInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    
    // Points for Bezier path
    CGFloat circlesCenterX = rectOrigin.x + rectWidth/2;
    CGFloat circlesCenterY = rectOrigin.y + rectHeight/3;
    CGPoint circlesCenter = CGPointMake(circlesCenterX, circlesCenterY);
    CGPoint arrowPoint = CGPointMake(rectWidth/2, rectHeight);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                   alpha:1.0
    ];
    [normalThemeColor setStroke];
    [normalThemeColor setFill];
    
    UIBezierPath * outterRightBezierPath = [UIBezierPath bezierPath];
    [outterRightBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:3.0*M_PI/2.0 endAngle:5.0*M_PI/6.0 clockwise:NO];
    [outterRightBezierPath addLineToPoint:arrowPoint];
    [outterRightBezierPath fill];
    CGContextAddPath(context, outterRightBezierPath.CGPath);
    
    UIBezierPath * outterLeftBezierPath = [UIBezierPath bezierPath];
    [outterLeftBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:3.0*M_PI/2.0 endAngle:M_PI/6.0 clockwise:YES];
    [outterLeftBezierPath addLineToPoint:arrowPoint];
    [outterLeftBezierPath fill];
    CGContextAddPath(context, outterLeftBezierPath.CGPath);
    
    [[UIColor whiteColor] setFill]; // Clear
    
    UIBezierPath * innerCircleBezierPath = [UIBezierPath bezierPath];
    [innerCircleBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:0 endAngle:2.0*M_PI clockwise:YES];
    [innerCircleBezierPath stroke];
    [innerCircleBezierPath fill];
    CGContextAddPath(context, innerCircleBezierPath.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
@method imageForBeaconInNormalThemeColor
@discussion This method draws the beacon icon for table cells.
*/
+ (UIImage *)imageForBeaconInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    
    // Points for Bezier path
    CGFloat circlesCenterX = rectOrigin.x + rectWidth/2;
    CGFloat circlesCenterY = rectOrigin.y + rectHeight/3;
    CGPoint circlesCenter = CGPointMake(circlesCenterX, circlesCenterY);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:1.0
                                  ];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterRightArcBezierPath = [UIBezierPath bezierPath];
    [outterRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [outterRightArcBezierPath stroke];
    CGContextAddPath(context, outterRightArcBezierPath.CGPath);
    
    UIBezierPath * outterLeftArcBezierPath = [UIBezierPath bezierPath];
    [outterLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [outterLeftArcBezierPath stroke];
    CGContextAddPath(context, outterLeftArcBezierPath.CGPath);
    
    UIBezierPath * middleRightArcBezierPath = [UIBezierPath bezierPath];
    [middleRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/4 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [middleRightArcBezierPath stroke];
    CGContextAddPath(context, middleRightArcBezierPath.CGPath);
    
    UIBezierPath * middleLeftArcBezierPath = [UIBezierPath bezierPath];
    [middleLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/4 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [middleLeftArcBezierPath stroke];
    CGContextAddPath(context, middleLeftArcBezierPath.CGPath);
    
    UIBezierPath * innerRightArcBezierPath = [UIBezierPath bezierPath];
    [innerRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [innerRightArcBezierPath stroke];
    CGContextAddPath(context, innerRightArcBezierPath.CGPath);
    
    UIBezierPath * innerLeftArcBezierPath = [UIBezierPath bezierPath];
    [innerLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [innerLeftArcBezierPath stroke];
    CGContextAddPath(context, innerLeftArcBezierPath.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
@method imageForModelInNormalThemeColor
@discussion This method draws the beacon icon for table cells.
*/
+ (UIImage *)imageForModelInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    CGFloat margin = rectWidth * 0.1;
    CGFloat splitLineHeith = rectHeight * 0.2;
    CGFloat minusHeith = rectHeight * 0.3;
    CGFloat minusX = rectHeight * 0.15;
    CGFloat minusLength = rectHeight * 0.15;
    
    // Points for Bezier path
    CGPoint upperLeftCorner = CGPointMake(rectOrigin.x + margin,
                                          rectOrigin.y + margin);
    CGPoint upperRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                           rectOrigin.y + margin);
    CGPoint bottomRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                            rectOrigin.y + rectHeight - margin);
    CGPoint bottomLeftCorner = CGPointMake(rectOrigin.x + margin,
                                           rectOrigin.y + rectHeight - margin);
    CGPoint leftSplitLine = CGPointMake(rectOrigin.x + margin,
                                        rectOrigin.y + margin + splitLineHeith);
    CGPoint rightSplitLine = CGPointMake(rectOrigin.x + rectWidth - margin,
                                         rectOrigin.y + margin + splitLineHeith);
    CGPoint leftMinusLine = CGPointMake(rectOrigin.x + minusX,
                                        rectOrigin.y + margin + minusHeith);
    CGPoint rightMinusLine = CGPointMake(rectOrigin.x + minusX + minusLength,
                                         rectOrigin.y + margin + minusHeith);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:1.0
                                  ];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterSquare = [UIBezierPath bezierPath];
    [outterSquare moveToPoint:upperLeftCorner];
    [outterSquare addLineToPoint:upperRightCorner];
    [outterSquare addLineToPoint:bottomRightCorner];
    [outterSquare addLineToPoint:bottomLeftCorner];
    [outterSquare addLineToPoint:upperLeftCorner];
    [outterSquare moveToPoint:leftSplitLine];
    [outterSquare addLineToPoint:rightSplitLine];
    [outterSquare moveToPoint:leftMinusLine];
    [outterSquare addLineToPoint:rightMinusLine];
    [outterSquare stroke];
    CGContextAddPath(context, outterSquare.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
@method imageForMeasureInNormalThemeColor
@discussion This method draws the measure icon for buttons.
*/
+ (UIImage *)imageForMeasureInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    CGFloat margin = rectWidth * 0.1;
    CGFloat splitLineHeith = rectHeight * 0.2;
    CGFloat minusHeith = rectHeight * 0.3;
    CGFloat minusX = rectHeight * 0.15;
    CGFloat minusLength = rectHeight * 0.15;
    
    // Points for Bezier path
    CGPoint upperLeftCorner = CGPointMake(rectOrigin.x + margin,
                                          rectOrigin.y + margin);
    CGPoint upperRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                           rectOrigin.y + margin);
    CGPoint bottomRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                            rectOrigin.y + rectHeight - margin);
    CGPoint bottomLeftCorner = CGPointMake(rectOrigin.x + margin,
                                           rectOrigin.y + rectHeight - margin);
    CGPoint leftSplitLine = CGPointMake(rectOrigin.x + margin,
                                        rectOrigin.y + margin + splitLineHeith);
    CGPoint rightSplitLine = CGPointMake(rectOrigin.x + rectWidth - margin,
                                         rectOrigin.y + margin + splitLineHeith);
    CGPoint leftMinusLine = CGPointMake(rectOrigin.x + minusX,
                                        rectOrigin.y + margin + minusHeith);
    CGPoint rightMinusLine = CGPointMake(rectOrigin.x + minusX + minusLength,
                                         rectOrigin.y + margin + minusHeith);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:1.0
                                  ];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterSquare = [UIBezierPath bezierPath];
    [outterSquare moveToPoint:upperLeftCorner];
    [outterSquare addLineToPoint:upperRightCorner];
    [outterSquare addLineToPoint:bottomRightCorner];
    [outterSquare addLineToPoint:bottomLeftCorner];
    [outterSquare addLineToPoint:upperLeftCorner];
    [outterSquare moveToPoint:leftSplitLine];
    [outterSquare addLineToPoint:rightSplitLine];
    [outterSquare moveToPoint:leftMinusLine];
    [outterSquare addLineToPoint:rightMinusLine];
    [outterSquare stroke];
    CGContextAddPath(context, outterSquare.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
@method imageForMeasureInDisabledThemeColor
@discussion This method draws the measure icon for buttons.
*/
+ (UIImage *)imageForMeasureInDisabledThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    CGFloat margin = rectWidth * 0.1;
    CGFloat splitLineHeith = rectHeight * 0.2;
    CGFloat minusHeith = rectHeight * 0.3;
    CGFloat minusX = rectHeight * 0.15;
    CGFloat minusLength = rectHeight * 0.15;
    
    // Points for Bezier path
    CGPoint upperLeftCorner = CGPointMake(rectOrigin.x + margin,
                                          rectOrigin.y + margin);
    CGPoint upperRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                           rectOrigin.y + margin);
    CGPoint bottomRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                            rectOrigin.y + rectHeight - margin);
    CGPoint bottomLeftCorner = CGPointMake(rectOrigin.x + margin,
                                           rectOrigin.y + rectHeight - margin);
    CGPoint leftSplitLine = CGPointMake(rectOrigin.x + margin,
                                        rectOrigin.y + margin + splitLineHeith);
    CGPoint rightSplitLine = CGPointMake(rectOrigin.x + rectWidth - margin,
                                         rectOrigin.y + margin + splitLineHeith);
    CGPoint leftMinusLine = CGPointMake(rectOrigin.x + minusX,
                                        rectOrigin.y + margin + minusHeith);
    CGPoint rightMinusLine = CGPointMake(rectOrigin.x + minusX + minusLength,
                                         rectOrigin.y + margin + minusHeith);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:0.3
                                  ];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterSquare = [UIBezierPath bezierPath];
    [outterSquare moveToPoint:upperLeftCorner];
    [outterSquare addLineToPoint:upperRightCorner];
    [outterSquare addLineToPoint:bottomRightCorner];
    [outterSquare addLineToPoint:bottomLeftCorner];
    [outterSquare addLineToPoint:upperLeftCorner];
    [outterSquare moveToPoint:leftSplitLine];
    [outterSquare addLineToPoint:rightSplitLine];
    [outterSquare moveToPoint:leftMinusLine];
    [outterSquare addLineToPoint:rightMinusLine];
    [outterSquare stroke];
    CGContextAddPath(context, outterSquare.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
