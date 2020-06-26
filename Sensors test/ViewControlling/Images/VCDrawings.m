//
//  VCDrawings.m
//  Sensors test
//
//  Created by Alberto J. on 18/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCDrawings.h"

@implementation VCDrawings

#pragma mark - Color methods
/*!
@method getNormalThemeColor
@discussion This method returns the default theme color to normal states.
*/
+ (UIColor *)getNormalThemeColor
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                           green:[layoutDic[@"navbar/green"] floatValue]/255.0
                            blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                           alpha:1.0
            ];
}

/*!
@method getDisabledThemeColor
@discussion This method returns the default theme color to disabled states.
*/
+ (UIColor *)getDisabledThemeColor
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                           green:[layoutDic[@"navbar/green"] floatValue]/255.0
                            blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                           alpha:0.3
            ];
}

#pragma mark - Drawing methods
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
    UIColor * normalThemeColor = [self getNormalThemeColor];
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
    UIColor * normalThemeColor = [self getNormalThemeColor];
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
    UIColor * normalThemeColor = [self getNormalThemeColor];
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
    NSNumber * buttonWidth = layoutDic[@"buttons/big/measure/width"];
    NSNumber * buttonHeight = layoutDic[@"buttons/big/measure/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [buttonWidth integerValue],
                             [buttonHeight integerValue]);

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
    CGFloat innerRadius = rectWidth/2;
    CGFloat outterRadius = rectWidth/1.3;
    CGFloat startAngle = 8.0*M_PI/6.0;
    CGFloat endAngle = 10.0*M_PI/6.0;
    CGFloat innerDialRadius = rectWidth/1.6;
    CGFloat outterDialRadius = rectWidth/1.4;
    CGFloat stepDialAngle = (endAngle-startAngle)/8.0;
    
    // Points for Bezier path
    CGPoint bottomCenter = CGPointMake((rectOrigin.x + rectWidth)/2.0,
                                       rectOrigin.y + rectHeight);
    CGPoint leftLineOutter = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle),
                                         bottomCenter.y + outterRadius*sinf(startAngle));
    CGPoint leftLineInner = CGPointMake(bottomCenter.x + innerRadius*cosf(startAngle),
                                        bottomCenter.y + innerRadius*sinf(startAngle));
    CGPoint rightLineOutter = CGPointMake(bottomCenter.x + outterRadius*cosf(endAngle),
                                          bottomCenter.y + outterRadius*sinf(endAngle));
    CGPoint rightLineInner = CGPointMake(bottomCenter.x + innerRadius*cosf(endAngle),
                                         bottomCenter.y + innerRadius*sinf(endAngle));
    
    
    CGPoint dialLineOutter = CGPointMake(bottomCenter.x + innerDialRadius*cosf(startAngle + stepDialAngle),
                                         bottomCenter.y + innerDialRadius*sinf(startAngle + stepDialAngle));
    CGPoint dialLineInner = CGPointMake(bottomCenter.x + innerRadius*cosf(startAngle + stepDialAngle),
                                        bottomCenter.y + innerRadius*sinf(startAngle + stepDialAngle));
    CGPoint scaleLineOutter1 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + stepDialAngle));
    CGPoint scaleLineInner1 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + stepDialAngle));
    CGPoint scaleLineOutter2 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 2.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 2.0*stepDialAngle));
    CGPoint scaleLineInner2 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 2.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 2.0*stepDialAngle));
    CGPoint scaleLineOutter3 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 3.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 3.0*stepDialAngle));
    CGPoint scaleLineInner3 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 3.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 3.0*stepDialAngle));
    CGPoint scaleLineOutter4 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 4.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 4.0*stepDialAngle));
    CGPoint scaleLineInner4 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 4.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 4.0*stepDialAngle));
    CGPoint scaleLineOutter5 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 5.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 5.0*stepDialAngle));
    CGPoint scaleLineInner5 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 5.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 5.0*stepDialAngle));
    CGPoint scaleLineOutter6 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 6.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 6.0*stepDialAngle));
    CGPoint scaleLineInner6 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 6.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 6.0*stepDialAngle));
    CGPoint scaleLineOutter7 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 7.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 7.0*stepDialAngle));
    CGPoint scaleLineInner7 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 7.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 7.0*stepDialAngle));
    
    // Draw the path
    UIColor * normalThemeColor = [self getNormalThemeColor];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterArcBezierPath = [UIBezierPath bezierPath];
    [outterArcBezierPath addArcWithCenter:bottomCenter radius:innerRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [outterArcBezierPath stroke];
    CGContextAddPath(context, outterArcBezierPath.CGPath);
    
    UIBezierPath * innerArcBezierPath = [UIBezierPath bezierPath];
    [innerArcBezierPath addArcWithCenter:bottomCenter radius:outterRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [innerArcBezierPath stroke];
    CGContextAddPath(context, innerArcBezierPath.CGPath);
    
    UIBezierPath * leftLineBezierPath = [UIBezierPath bezierPath];
    [leftLineBezierPath moveToPoint:leftLineOutter];
    [leftLineBezierPath addLineToPoint:leftLineInner];
    [leftLineBezierPath stroke];
    CGContextAddPath(context, leftLineBezierPath.CGPath);
    
    UIBezierPath * rightLineBezierPath = [UIBezierPath bezierPath];
    [rightLineBezierPath moveToPoint:rightLineOutter];
    [rightLineBezierPath addLineToPoint:rightLineInner];
    [rightLineBezierPath stroke];
    CGContextAddPath(context, rightLineBezierPath.CGPath);
    
    UIBezierPath * dialLineBezierPath = [UIBezierPath bezierPath];
    [dialLineBezierPath moveToPoint:dialLineOutter];
    [dialLineBezierPath addLineToPoint:dialLineInner];
    [dialLineBezierPath stroke];
    CGContextAddPath(context, rightLineBezierPath.CGPath);
    
    UIBezierPath * scaleLineBezierPath1 = [UIBezierPath bezierPath];
    [scaleLineBezierPath1 moveToPoint:scaleLineOutter1];
    [scaleLineBezierPath1 addLineToPoint:scaleLineInner1];
    [scaleLineBezierPath1 stroke];
    CGContextAddPath(context, scaleLineBezierPath1.CGPath);
    
    UIBezierPath * scaleLineBezierPath2 = [UIBezierPath bezierPath];
    [scaleLineBezierPath2 moveToPoint:scaleLineOutter2];
    [scaleLineBezierPath2 addLineToPoint:scaleLineInner2];
    [scaleLineBezierPath2 stroke];
    CGContextAddPath(context, scaleLineBezierPath2.CGPath);
    
    UIBezierPath * scaleLineBezierPath3 = [UIBezierPath bezierPath];
    [scaleLineBezierPath3 moveToPoint:scaleLineOutter3];
    [scaleLineBezierPath3 addLineToPoint:scaleLineInner3];
    [scaleLineBezierPath3 stroke];
    CGContextAddPath(context, scaleLineBezierPath3.CGPath);
    
    UIBezierPath * scaleLineBezierPath4 = [UIBezierPath bezierPath];
    [scaleLineBezierPath4 moveToPoint:scaleLineOutter4];
    [scaleLineBezierPath4 addLineToPoint:scaleLineInner4];
    [scaleLineBezierPath4 stroke];
    CGContextAddPath(context, scaleLineBezierPath4.CGPath);
    
    UIBezierPath * scaleLineBezierPath5 = [UIBezierPath bezierPath];
    [scaleLineBezierPath5 moveToPoint:scaleLineOutter5];
    [scaleLineBezierPath5 addLineToPoint:scaleLineInner5];
    [scaleLineBezierPath5 stroke];
    CGContextAddPath(context, scaleLineBezierPath5.CGPath);
    
    UIBezierPath * scaleLineBezierPath6 = [UIBezierPath bezierPath];
    [scaleLineBezierPath6 moveToPoint:scaleLineOutter6];
    [scaleLineBezierPath6 addLineToPoint:scaleLineInner6];
    [scaleLineBezierPath6 stroke];
    CGContextAddPath(context, scaleLineBezierPath6.CGPath);
    
    UIBezierPath * scaleLineBezierPath7 = [UIBezierPath bezierPath];
    [scaleLineBezierPath7 moveToPoint:scaleLineOutter7];
    [scaleLineBezierPath7 addLineToPoint:scaleLineInner7];
    [scaleLineBezierPath7 stroke];
    CGContextAddPath(context, scaleLineBezierPath7.CGPath);
    
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
    NSNumber * buttonWidth = layoutDic[@"buttons/big/measure/width"];
    NSNumber * buttonHeight = layoutDic[@"buttons/big/measure/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [buttonWidth integerValue],
                             [buttonHeight integerValue]);

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
    CGFloat innerRadius = rectWidth/2;
    CGFloat outterRadius = rectWidth/1.3;
    CGFloat startAngle = 8.0*M_PI/6.0;
    CGFloat endAngle = 10.0*M_PI/6.0;
    CGFloat innerDialRadius = rectWidth/1.6;
    CGFloat outterDialRadius = rectWidth/1.4;
    CGFloat stepDialAngle = (endAngle-startAngle)/8.0;
    CGFloat innerCrossRadius = rectWidth/2.3;
    CGFloat outterCrossRadius = rectWidth/1.2;
    
    // Points for Bezier path
    CGPoint bottomCenter = CGPointMake((rectOrigin.x + rectWidth)/2.0,
                                       rectOrigin.y + rectHeight);
    CGPoint leftLineOutter = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle),
                                         bottomCenter.y + outterRadius*sinf(startAngle));
    CGPoint leftLineInner = CGPointMake(bottomCenter.x + innerRadius*cosf(startAngle),
                                        bottomCenter.y + innerRadius*sinf(startAngle));
    CGPoint rightLineOutter = CGPointMake(bottomCenter.x + outterRadius*cosf(endAngle),
                                          bottomCenter.y + outterRadius*sinf(endAngle));
    CGPoint rightLineInner = CGPointMake(bottomCenter.x + innerRadius*cosf(endAngle),
                                         bottomCenter.y + innerRadius*sinf(endAngle));
    
    
    CGPoint dialLineOutter = CGPointMake(bottomCenter.x + innerDialRadius*cosf(startAngle + stepDialAngle),
                                         bottomCenter.y + innerDialRadius*sinf(startAngle + stepDialAngle));
    CGPoint dialLineInner = CGPointMake(bottomCenter.x + innerRadius*cosf(startAngle + stepDialAngle),
                                        bottomCenter.y + innerRadius*sinf(startAngle + stepDialAngle));
    CGPoint scaleLineOutter1 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + stepDialAngle));
    CGPoint scaleLineInner1 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + stepDialAngle));
    CGPoint scaleLineOutter2 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 2.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 2.0*stepDialAngle));
    CGPoint scaleLineInner2 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 2.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 2.0*stepDialAngle));
    CGPoint scaleLineOutter3 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 3.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 3.0*stepDialAngle));
    CGPoint scaleLineInner3 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 3.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 3.0*stepDialAngle));
    CGPoint scaleLineOutter4 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 4.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 4.0*stepDialAngle));
    CGPoint scaleLineInner4 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 4.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 4.0*stepDialAngle));
    CGPoint scaleLineOutter5 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 5.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 5.0*stepDialAngle));
    CGPoint scaleLineInner5 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 5.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 5.0*stepDialAngle));
    CGPoint scaleLineOutter6 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 6.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 6.0*stepDialAngle));
    CGPoint scaleLineInner6 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 6.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 6.0*stepDialAngle));
    CGPoint scaleLineOutter7 = CGPointMake(bottomCenter.x + outterRadius*cosf(startAngle + 7.0*stepDialAngle),
                                           bottomCenter.y + outterRadius*sinf(startAngle + 7.0*stepDialAngle));
    CGPoint scaleLineInner7 = CGPointMake(bottomCenter.x + outterDialRadius*cosf(startAngle + 7.0*stepDialAngle),
                                          bottomCenter.y + outterDialRadius*sinf(startAngle + 7.0*stepDialAngle));
    
    CGPoint leftCrossOutter = CGPointMake(bottomCenter.x + outterCrossRadius*cosf(startAngle + 1.5*stepDialAngle),
                                           bottomCenter.y + outterCrossRadius*sinf(startAngle + 1.5*stepDialAngle));
    CGPoint leftCrossInner = CGPointMake(bottomCenter.x + innerCrossRadius*cosf(startAngle),
                                          bottomCenter.y + innerCrossRadius*sinf(startAngle));
    CGPoint rightCrossOutter = CGPointMake(bottomCenter.x + outterCrossRadius*cosf(startAngle + 6.5*stepDialAngle),
                                           bottomCenter.y + outterCrossRadius*sinf(startAngle + 6.5*stepDialAngle));
    CGPoint rightCrossInner = CGPointMake(bottomCenter.x + innerCrossRadius*cosf(endAngle),
                                          bottomCenter.y + innerCrossRadius*sinf(endAngle));
    
    // Draw the path
    UIColor * disabledThemeColor = [self getDisabledThemeColor];
    [disabledThemeColor setStroke];
    
    UIBezierPath * outterArcBezierPath = [UIBezierPath bezierPath];
    [outterArcBezierPath addArcWithCenter:bottomCenter radius:innerRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [outterArcBezierPath stroke];
    CGContextAddPath(context, outterArcBezierPath.CGPath);
    
    UIBezierPath * innerArcBezierPath = [UIBezierPath bezierPath];
    [innerArcBezierPath addArcWithCenter:bottomCenter radius:outterRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [innerArcBezierPath stroke];
    CGContextAddPath(context, innerArcBezierPath.CGPath);
    
    UIBezierPath * leftLineBezierPath = [UIBezierPath bezierPath];
    [leftLineBezierPath moveToPoint:leftLineOutter];
    [leftLineBezierPath addLineToPoint:leftLineInner];
    [leftLineBezierPath stroke];
    CGContextAddPath(context, leftLineBezierPath.CGPath);
    
    UIBezierPath * rightLineBezierPath = [UIBezierPath bezierPath];
    [rightLineBezierPath moveToPoint:rightLineOutter];
    [rightLineBezierPath addLineToPoint:rightLineInner];
    [rightLineBezierPath stroke];
    CGContextAddPath(context, rightLineBezierPath.CGPath);
    
    UIBezierPath * dialLineBezierPath = [UIBezierPath bezierPath];
    [dialLineBezierPath moveToPoint:dialLineOutter];
    [dialLineBezierPath addLineToPoint:dialLineInner];
    [dialLineBezierPath stroke];
    CGContextAddPath(context, rightLineBezierPath.CGPath);
    
    UIBezierPath * scaleLineBezierPath1 = [UIBezierPath bezierPath];
    [scaleLineBezierPath1 moveToPoint:scaleLineOutter1];
    [scaleLineBezierPath1 addLineToPoint:scaleLineInner1];
    [scaleLineBezierPath1 stroke];
    CGContextAddPath(context, scaleLineBezierPath1.CGPath);
    
    UIBezierPath * scaleLineBezierPath2 = [UIBezierPath bezierPath];
    [scaleLineBezierPath2 moveToPoint:scaleLineOutter2];
    [scaleLineBezierPath2 addLineToPoint:scaleLineInner2];
    [scaleLineBezierPath2 stroke];
    CGContextAddPath(context, scaleLineBezierPath2.CGPath);
    
    UIBezierPath * scaleLineBezierPath3 = [UIBezierPath bezierPath];
    [scaleLineBezierPath3 moveToPoint:scaleLineOutter3];
    [scaleLineBezierPath3 addLineToPoint:scaleLineInner3];
    [scaleLineBezierPath3 stroke];
    CGContextAddPath(context, scaleLineBezierPath3.CGPath);
    
    UIBezierPath * scaleLineBezierPath4 = [UIBezierPath bezierPath];
    [scaleLineBezierPath4 moveToPoint:scaleLineOutter4];
    [scaleLineBezierPath4 addLineToPoint:scaleLineInner4];
    [scaleLineBezierPath4 stroke];
    CGContextAddPath(context, scaleLineBezierPath4.CGPath);
    
    UIBezierPath * scaleLineBezierPath5 = [UIBezierPath bezierPath];
    [scaleLineBezierPath5 moveToPoint:scaleLineOutter5];
    [scaleLineBezierPath5 addLineToPoint:scaleLineInner5];
    [scaleLineBezierPath5 stroke];
    CGContextAddPath(context, scaleLineBezierPath5.CGPath);
    
    UIBezierPath * scaleLineBezierPath6 = [UIBezierPath bezierPath];
    [scaleLineBezierPath6 moveToPoint:scaleLineOutter6];
    [scaleLineBezierPath6 addLineToPoint:scaleLineInner6];
    [scaleLineBezierPath6 stroke];
    CGContextAddPath(context, scaleLineBezierPath6.CGPath);
    
    UIBezierPath * scaleLineBezierPath7 = [UIBezierPath bezierPath];
    [scaleLineBezierPath7 moveToPoint:scaleLineOutter7];
    [scaleLineBezierPath7 addLineToPoint:scaleLineInner7];
    [scaleLineBezierPath7 stroke];
    CGContextAddPath(context, scaleLineBezierPath7.CGPath);
    
    UIBezierPath * crossLineBezierPath1 = [UIBezierPath bezierPath];
    [crossLineBezierPath1 moveToPoint:leftCrossOutter];
    [crossLineBezierPath1 addLineToPoint:rightCrossInner];
    [crossLineBezierPath1 stroke];
    CGContextAddPath(context, crossLineBezierPath1.CGPath);
    
    UIBezierPath * crossLineBezierPath2 = [UIBezierPath bezierPath];
    [crossLineBezierPath2 moveToPoint:rightCrossOutter];
    [crossLineBezierPath2 addLineToPoint:leftCrossInner];
    [crossLineBezierPath2 stroke];
    CGContextAddPath(context, crossLineBezierPath2.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
