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

#pragma mark - Drag and drop delegate methods
/*!
 @method dropInteraction:performDrop:
 @discussion Handles drag and drop gestures of views; handles the drop of the dragged items' collection.
 */
- (void)dropInteraction:(UIDropInteraction *)interaction
            performDrop:(id<UIDropSession>)session
{
    NSLog(@"[INFO][VCCo] User did droppped in the VCComponent view %@.", uuid);

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
    NSLog(@"[INFO][VCCo] Droppped provided item being copied.");
    
    // Load every class that can be dropped: VCComponent, VCCorner, VCPosition
    [session loadObjectsOfClass:VCComponent.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * objects) {
        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // The object dropped is the VCComponent dragged
            VCComponent * droppedVCComponent = object;
            NSLog(@"[INFO][VCCo] Droppped and copied a VCComponent %@ item.", [droppedVCComponent getUUID]);
            
            // Ask to create the reference
            NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
            dataDic[@"sourceView"] = self;
            dataDic[@"targetView"] = droppedVCComponent;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createReference"
                                                                object:nil
                                                              userInfo:dataDic];
            NSLog(@"[NOTI][VCCo] Notification \"createReference\" posted.");
        }
         ];
    }
     ];
    
    [session loadObjectsOfClass:VCPosition.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * objects) {
        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {

            // The object dropped is the VCComponent dragged
            VCPosition * droppedComponent = object;
            NSLog(@"[INFO][VCCo] Droppped and copied a VCPosition %@ item.", [droppedComponent getUUID]);

            // Ask to create the reference
            NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
            dataDic[@"sourceView"] = self;
            dataDic[@"targetView"] = droppedComponent;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createReference"
                                                                object:nil
                                                              userInfo:dataDic];
            NSLog(@"[NOTI][VCCo] Notification \"createReference\" posted.");
        }
         ];
    }
     ];
    
    [session loadObjectsOfClass:VCCorner.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * objects) {
        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {

            // The object dropped is the VCComponent dragged
            VCCorner * droppedComponent = object;
            NSLog(@"[INFO][VCCo] Droppped and copied a VCCorner %@ item.", [droppedComponent getUUID]);

            // Ask to create the reference
            NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
            dataDic[@"sourceView"] = self;
            dataDic[@"targetView"] = droppedComponent;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createReference"
                                                                object:nil
                                                              userInfo:dataDic];
            NSLog(@"[NOTI][VCCo] Notification \"createReference\" posted.");
        }
         ];
    }
     ];
}

@end
