//
//  VCPosition.m
//  Sensors test
//
//  Created by MISO on 23/03/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCPosition.h"

@implementation VCPosition: VCComponent

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

#pragma mark - Drag and drop delegate methods
/*!
 @method dropInteraction:performDrop:
 @discussion Handles drag and drop gestures of views; handles the drop of the dragged items' collection.
 */
- (void)dropInteraction:(UIDropInteraction *)interaction
            performDrop:(id<UIDropSession>)session
{
    NSLog(@"[INFO][VCP] User did droppped in the VCComponent view %@.", uuid);

    // Different behaviour depending on dropping proposal
    // TODO: Aparently is not possible in this drag and drop session. Alberto J. 2020/03/19.
    /*
    switch (session.localDragSession.proposal.operation) {
        case UIDropOperationCancel:
            break;
        case UIDropOperationForbidden:
            break;
        case UIDropOperationMove:
            break;
        case UIDropOperationCopy:
    }
    */
    NSLog(@"[INFO][VCP] Droppped provided item being copied.");
    
    // Load every class that can be dropped: VCComponent, VCCorner, VCPosition
    [session loadObjectsOfClass:VCComponent.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * objects) {
        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // The object dropped is the VCComponent dragged
            VCComponent * droppedVCComponent = object;
            NSLog(@"[INFO][VCP] Droppped and copied a VCComponent %@ item.", [droppedVCComponent getUUID]);
            
            // Ask to create the reference
            NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
            dataDic[@"sourceView"] = self;
            dataDic[@"targetView"] = droppedVCComponent;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createReference"
                                                                object:nil
                                                              userInfo:dataDic];
            NSLog(@"[NOTI][VCP] Notification \"createReference\" posted.");
        }
         ];
    }
     ];
    
    [session loadObjectsOfClass:VCPosition.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * objects) {
        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {

            // The object dropped is the VCComponent dragged
            VCPosition * droppedComponent = object;
            NSLog(@"[INFO][VCP] Droppped and copied a VCPosition %@ item.", [droppedComponent getUUID]);

            // Ask to create the reference
            NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
            dataDic[@"sourceView"] = self;
            dataDic[@"targetView"] = droppedComponent;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createReference"
                                                                object:nil
                                                              userInfo:dataDic];
            NSLog(@"[NOTI][VCP] Notification \"createReference\" posted.");
        }
         ];
    }
     ];
    
    [session loadObjectsOfClass:VCCorner.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * objects) {
        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {

            // The object dropped is the VCComponent dragged
            VCCorner * droppedComponent = object;
            NSLog(@"[INFO][VCP] Droppped and copied a VCCorner %@ item.", [droppedComponent getUUID]);

            // Ask to create the reference
            NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
            dataDic[@"sourceView"] = self;
            dataDic[@"targetView"] = droppedComponent;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createReference"
                                                                object:nil
                                                              userInfo:dataDic];
            NSLog(@"[NOTI][VCP] Notification \"createReference\" posted.");
        }
         ];
    }
     ];
}

@end
