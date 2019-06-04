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
    return self;
}

/*!
 @method prepareCanvas
 @discussion This method initializes some properties of the canvas; is called when the main view is loaded by its controller.
 */
-(void)prepareCanvas{
    // Initialize variables
    self.rangedBeaconsDic = [[NSMutableDictionary alloc] init];
    
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
 
    /*
     NSMutableArray * realPoints = [[NSMutableArray alloc] init];
     
     RDPosition * point1 = [[RDPosition alloc] init];
     point1.x = [[NSNumber alloc] initWithFloat:10.0];
     point1.y = [[NSNumber alloc] initWithFloat:10.0];
     point1.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point2 = [[RDPosition alloc] init];
     point2.x = [[NSNumber alloc] initWithFloat:10.0];
     point2.y = [[NSNumber alloc] initWithFloat:-10.0];
     point2.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point3 = [[RDPosition alloc] init];
     point3.x = [[NSNumber alloc] initWithFloat:-10.0];
     point3.y = [[NSNumber alloc] initWithFloat:10.0];
     point3.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point4 = [[RDPosition alloc] init];
     point4.x = [[NSNumber alloc] initWithFloat:-10.0];
     point4.y = [[NSNumber alloc] initWithFloat:-10.0];
     point4.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point5 = [[RDPosition alloc] init];
     point5.x = [[NSNumber alloc] initWithFloat:5.0];
     point5.y = [[NSNumber alloc] initWithFloat:0.0];
     point5.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point6 = [[RDPosition alloc] init];
     point6.x = [[NSNumber alloc] initWithFloat:0.0];
     point6.y = [[NSNumber alloc] initWithFloat:-5.0];
     point6.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point7 = [[RDPosition alloc] init];
     point7.x = [[NSNumber alloc] initWithFloat:0.0];
     point7.y = [[NSNumber alloc] initWithFloat:5.0];
     point7.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point8 = [[RDPosition alloc] init];
     point8.x = [[NSNumber alloc] initWithFloat:-5.0];
     point8.y = [[NSNumber alloc] initWithFloat:0.0];
     point8.z = [[NSNumber alloc] initWithFloat:0.0];
     
     [realPoints addObject:point1];
     [realPoints addObject:point2];
     [realPoints addObject:point3];
     [realPoints addObject:point4];
     [realPoints addObject:point5];
     [realPoints addObject:point6];
     [realPoints addObject:point7];
     [realPoints addObject:point8];
     
     NSMutableArray * canvasPoints = [self transformRealPointsToCanvasPoints:realPoints];
     
     for (RDPosition * canvasPoint in canvasPoints) {
     UIBezierPath *bezierPath = [UIBezierPath bezierPath];
     [bezierPath addArcWithCenter:[canvasPoint toNSPoint] radius:1 startAngle:0 endAngle:2 * M_PI clockwise:YES];
     
     CAShapeLayer *pointLayer = [[CAShapeLayer alloc] init];
     [pointLayer setPath:bezierPath.CGPath];
     [pointLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
     [pointLayer setFillColor:[UIColor clearColor].CGColor];
     [[self layer] addSublayer:pointLayer];
     }
     
     [self setNeedsDisplay];
     NSLog(@"[INFO][CA] Test finished.");
    */
    
    
    
    /*
    // Delete previus
    if (self.layer.sublayers.count > 0) {
        for (CALayer *layer in self.layer.sublayers) {
            if ([layer isKindOfClass:[CAShapeLayer class]]) {
                [layer setHidden:YES];
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
    [self.layer addSublayer:centerLayer];
    
    NSInteger index = 0;
    NSArray *beacons = [self.rangedBeacons allValues];
    for (CLBeacon *beacon in beacons){
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
     */
}

/*!
 @method getBarycenterOf:
 @discussion This method calculated the barycenter of a given set of RDPosition objects.
 */
- (RDPosition *) getBarycenterOf:(NSMutableArray *)points {
    RDPosition * barycenter = [[RDPosition alloc] init];
    float sumx = 0.0;
    float sumy = 0.0;
    float sumz = 0.0;
    for (RDPosition * point in points) {
        sumx = sumx + [point.x floatValue];
        sumy = sumy + [point.y floatValue];
        sumz = sumz + [point.z floatValue];
    }
    barycenter.x = [[NSNumber alloc] initWithFloat: sumx / points.count];
    barycenter.y = [[NSNumber alloc] initWithFloat: sumy / points.count];
    barycenter.z = [[NSNumber alloc] initWithFloat: sumz / points.count];
    return barycenter;
}

/*!
 @method subtract:
 @discussion This method subtracts a 'RDPosition' point from another one.
 */
- (RDPosition *) subtract:(RDPosition *)pointB
                     from:(RDPosition *)pointA {
    RDPosition * difference = [[RDPosition alloc] init];
    difference.x = [[NSNumber alloc] initWithFloat:[pointB.x floatValue] - [pointA.x floatValue]];
    difference.y = [[NSNumber alloc] initWithFloat:[pointB.y floatValue] - [pointA.y floatValue]];
    difference.z = [[NSNumber alloc] initWithFloat:[pointB.z floatValue] - [pointA.z floatValue]];
    return difference;
}

/*!
 @method transformRealPointsToCanvasPoints:
 @discussion This method transform a 3D RDPosition that represents a physical location to a canvas point; z coordinate is not transformed.
 */
- (NSMutableArray *) transformRealPointsToCanvasPoints:(NSMutableArray *)realPoints {
    
    // Result array initialization
    NSMutableArray * canvasPoints = [[NSMutableArray alloc] init];
    
    // Get the canvas dimensions and its center
    float canvasWidth = self.frame.size.width;
    float canvasHeight = self.frame.size.height;
    RDPosition * center = [[RDPosition alloc] init];
    center.x = [[NSNumber alloc] initWithFloat:self.frame.size.width/2];
    center.y = [[NSNumber alloc] initWithFloat:self.frame.size.height/2];
    
    // Define a safe area
    float widthSafe = self.frame.size.width * 0.05;
    float heightSafe = self.frame.size.height * 0.05;
    float widthSafeMin = 0 + widthSafe;
    float widthSafeMax = canvasWidth - widthSafe;
    float heightSafeMin = 0 + heightSafe;
    float heightSafeMax = canvasHeight - heightSafe;

    // Get the minimum and maximum x and y values
    float maxX = -FLT_MAX;
    float minX = FLT_MAX;
    float maxY = -FLT_MAX;
    float minY = FLT_MAX;
    for (RDPosition * realPoint in realPoints) {
        if ([realPoint.x floatValue] > maxX) {
            maxX = [realPoint.x floatValue];
        }
        if ([realPoint.x floatValue] < minX) {
            minX = [realPoint.x floatValue];
        }
        if ([realPoint.y floatValue] > maxY) {
            maxY = [realPoint.y floatValue];
        }
        if ([realPoint.y floatValue] < minY) {
            minY = [realPoint.y floatValue];
        }
    }
    
    // Get the relations of the transformation
    float rWidth = (widthSafeMax - widthSafeMin)/(maxX - minX);;
    float rHeight = (heightSafeMax - heightSafeMin)/(maxY - minY);
    
    // Transform the point's coordinates; they would be centered at the origin, hence the senter point is added
    for (RDPosition * realPoint in realPoints) {
        RDPosition * canvasPoint = [[RDPosition alloc] init];
        canvasPoint.x = [[NSNumber alloc] initWithFloat:[realPoint.x floatValue] * rWidth + [center.x floatValue]];
        canvasPoint.y = [[NSNumber alloc] initWithFloat:[realPoint.y floatValue] * rHeight + [center.y floatValue]];
        canvasPoint.z = realPoint.z;
        [canvasPoints addObject:canvasPoint];
    }
    
    // If a ponderate representation is wanted, the center of the screen should be alingned with the barycenter of the set os points
    // RDPosition * barycenter = [self getBarycenterOf:canvasPoints];
    
    return canvasPoints;
}

@end
