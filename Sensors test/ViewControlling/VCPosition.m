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
        [self setOpaque:NO];
        // Add the gesture recognizers needed
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(handleTap:)];
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

/*!
@method initWithFrame:initRealPosition:andUUID
@discussion Constructor with a given specific frame in which be embedded, real position and UUID identifier.
*/
-(instancetype)initWithFrame:(CGRect)frame
                realPosition:(RDPosition *)initRealPosition
                     andUUID:(NSString *)initUUID
{
    self = [self initWithFrame:frame];
    if (self) {
        realPosition = initRealPosition;
        uuid = initUUID;
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
    
    // Points for Bezier path
    CGFloat circlesCenterX = rectOrigin.x + rectWidth/2;
    CGFloat circlesCenterY = rectOrigin.y + rectHeight/3;
    CGPoint circlesCenter = CGPointMake(circlesCenterX, circlesCenterY);
    CGPoint arrowPoint = CGPointMake(rectWidth/2, rectHeight);
    
    // Color of canvas
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    UIColor * canvasColor = [UIColor colorWithRed:[layoutDic[@"canvas/red"] floatValue]/255.0
                                            green:[layoutDic[@"canvas/green"] floatValue]/255.0
                                             blue:[layoutDic[@"canvas/blue"] floatValue]/255.0
                                            alpha:1.0
                             ];
    
    // Draw the path
    UIBezierPath * outterRightBezierPath = [UIBezierPath bezierPath];
    [outterRightBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:3.0*M_PI/2.0 endAngle:5.0*M_PI/6.0 clockwise:NO];
    [outterRightBezierPath addLineToPoint:arrowPoint];
    [outterRightBezierPath fill];
    CAShapeLayer *outterRightLayer = [[CAShapeLayer alloc] init];
    [outterRightLayer setPath:outterRightBezierPath.CGPath];
    [outterRightLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [outterRightLayer setFillColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [[self layer] addSublayer:outterRightLayer];
    
    UIBezierPath * outterLeftBezierPath = [UIBezierPath bezierPath];
    [outterLeftBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:3.0*M_PI/2.0 endAngle:M_PI/6.0 clockwise:YES];
    [outterLeftBezierPath addLineToPoint:arrowPoint];
    [outterLeftBezierPath fill];
    CAShapeLayer *outterLeftLayer = [[CAShapeLayer alloc] init];
    [outterLeftLayer setPath:outterLeftBezierPath.CGPath];
    [outterLeftLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [outterLeftLayer setFillColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [[self layer] addSublayer:outterLeftLayer];
    
    UIBezierPath * innerCircleBezierPath = [UIBezierPath bezierPath];
    [innerCircleBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:0 endAngle:2.0*M_PI clockwise:YES];
    CAShapeLayer *innerCircleLayer = [[CAShapeLayer alloc] init];
    [innerCircleLayer setPath:innerCircleBezierPath.CGPath];
    [innerCircleLayer setStrokeColor:canvasColor.CGColor];
    [innerCircleLayer setFillColor:canvasColor.CGColor];
    [[self layer] addSublayer:innerCircleLayer];

}

#pragma mark Handle gestures methods
/*!
 @method handleTap:
 @discussion This method handles the tap gesture and asks the view to present the edit component pop up view.
 */
-(void)handleTap:(UITapGestureRecognizer *)recog
{
    // When user taps this view, the edit component view must be presented
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
    [dataDic setObject:realPosition forKey:@"realPosition"];
    [dataDic setObject:uuid forKey:@"uuid"];
    // And send the notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEditComponentView"
                                                        object:nil
                                                      userInfo:dataDic];
    NSLog(@"[NOTI][LM] Notification \"presentEditComponentView\" posted.");
}

@end
