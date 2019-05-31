//
//  Canvas.m
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "Canvas.h"

@implementation Canvas: UIView

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    self.rangedBeacons = [[NSMutableArray alloc] init];
    return self;
}

/*!
 @method initWithFrame:
 @discussion Constructor with a given specific frame in which be embedded.
 */
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    self.rangedBeacons = [[NSMutableArray alloc] init];
    return self;
}

/*!
 @method prepareCanvas
 @discussion This method initializes some properties of the canvas; is called when the main view is loaded by its controller.
 */
-(void)prepareCanvas{
    // Initialize variables
    self.rangedBeacons = [[NSMutableArray alloc] init];
    
    // Canvas configurations
    [self setUserInteractionEnabled:NO];
    self.backgroundColor = [UIColor colorWithRed:218/255.0 green:224/255.0 blue:235/255.0 alpha:0.6];
    
    // Center point
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint center;
    center.x = self.frame.size.width/2;
    center.y = self.frame.size.height/2;
    [bezierPath addArcWithCenter:center radius:1 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    CAShapeLayer *centerLayer = [[CAShapeLayer alloc] init];
    [centerLayer setPath:bezierPath.CGPath];
    [centerLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [centerLayer setFillColor:[UIColor clearColor].CGColor];
    // TO DO: This one is not centered
    // [self.layer addSublayer:centerLayer];
    
    [self setNeedsDisplay];
}

/*!
 @method drawRect:
 @discussion This method controls the display of a new drown area; is called when a new draw must be created and displayed.
 */
- (void)drawRect:(CGRect)rect {
    
    // Delete previus 
    if (self.layer.sublayers.count > 0) {
        for (CALayer *layer in self.layer.sublayers) {
            if ([layer isKindOfClass:[CAShapeLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }
    }
    
    // Center point
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint center;
    center.x = self.frame.size.width/2;
    center.y = self.frame.size.height/2;
    [bezierPath addArcWithCenter:center radius:1 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    CAShapeLayer *centerLayer = [[CAShapeLayer alloc] init];
    [centerLayer setPath:bezierPath.CGPath];
    [centerLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [centerLayer setFillColor:[UIColor clearColor].CGColor];
    
    NSInteger index = 0;
    for (CLBeacon * beacon in self.rangedBeacons){
        NSLog(@"beacon");
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        CGPoint center;
        center.x = self.frame.size.width/2;
        center.y = self.frame.size.height/2;
        [bezierPath addArcWithCenter:center radius:3*[[NSNumber numberWithInteger:[beacon rssi]] integerValue] startAngle:0 endAngle:2 * M_PI clockwise:YES];
        CAShapeLayer *beaconLayer = [[CAShapeLayer alloc] init];
        [beaconLayer setPath:bezierPath.CGPath];
        
        switch (index) {
            case 0:
                [beaconLayer setStrokeColor:[UIColor redColor].CGColor];
                [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                break;
                
            case 1:
                [beaconLayer setStrokeColor:[UIColor greenColor].CGColor];
                [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                break;
                
            case 2:
                [beaconLayer setStrokeColor:[UIColor blueColor].CGColor];
                [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                break;
                
            case 3:
                [beaconLayer setStrokeColor:[UIColor yellowColor].CGColor];
                [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                break;
                
            default:
                break;
        }
        // If there is previus layers, change them; if not, create new ones.
        if (self.currentLayers.count > 0) {
            //[[self layer] replaceSublayer:[[[self layer] sublayers] objectAtIndex:index] with:beaconLayer];
        }else{
            [[self layer] addSublayer:beaconLayer];
        }
        index++;
    }
    [self setNeedsDisplay];
}

@end
