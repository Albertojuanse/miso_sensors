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
    rHeight = 1.0;
    rWidth = 1.0;
    
    // Canvas configurations
    [self setUserInteractionEnabled:NO];
    self.backgroundColor = [UIColor colorWithRed:218/255.0 green:224/255.0 blue:235/255.0 alpha:0.6];
    
    // Center point
    UIBezierPath *centerBezierPath = [UIBezierPath bezierPath];
    center.x = self.frame.size.width/2;
    center.y = self.frame.size.height/2;
    [centerBezierPath moveToPoint:CGPointMake(center.x - 3.0, center.y)];
    [centerBezierPath addLineToPoint:CGPointMake(center.x + 3.0, center.y)];
    [centerBezierPath moveToPoint:CGPointMake(center.x, center.y - 3.0)];
    [centerBezierPath addLineToPoint:CGPointMake(center.x, center.y + 3.0)];
    
    CAShapeLayer *centerLayer = [[CAShapeLayer alloc] init];
    [centerLayer setPath:centerBezierPath.CGPath];
    [centerLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [centerLayer setFillColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    // TO DO: This one is not centered
    // [self.layer addSublayer:centerLayer];
    
    [self setNeedsDisplay];
}

/*!
 @method drawRect:
 @discussion This method controls the display of a new drown area; is called when a new draw must be created and displayed.
 */
- (void)drawRect:(CGRect)rect {
 
    /* TEST CANVAS
     NSMutableArray * realPoints = [[NSMutableArray alloc] init];
     
     RDPosition * point1 = [[RDPosition alloc] init];
     point1.x = [[NSNumber alloc] initWithFloat:1000.0];
     point1.y = [[NSNumber alloc] initWithFloat:1000.0];
     point1.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point2 = [[RDPosition alloc] init];
     point2.x = [[NSNumber alloc] initWithFloat:1000.0];
     point2.y = [[NSNumber alloc] initWithFloat:-1000.0];
     point2.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point3 = [[RDPosition alloc] init];
     point3.x = [[NSNumber alloc] initWithFloat:-1000.0];
     point3.y = [[NSNumber alloc] initWithFloat:1000.0];
     point3.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point4 = [[RDPosition alloc] init];
     point4.x = [[NSNumber alloc] initWithFloat:-1000.0];
     point4.y = [[NSNumber alloc] initWithFloat:-1000.0];
     point4.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point5 = [[RDPosition alloc] init];
     point5.x = [[NSNumber alloc] initWithFloat:500.0];
     point5.y = [[NSNumber alloc] initWithFloat:0.0];
     point5.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point6 = [[RDPosition alloc] init];
     point6.x = [[NSNumber alloc] initWithFloat:0.0];
     point6.y = [[NSNumber alloc] initWithFloat:-500.0];
     point6.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point7 = [[RDPosition alloc] init];
     point7.x = [[NSNumber alloc] initWithFloat:0.0];
     point7.y = [[NSNumber alloc] initWithFloat:500.0];
     point7.z = [[NSNumber alloc] initWithFloat:0.0];
     RDPosition * point8 = [[RDPosition alloc] init];
     point8.x = [[NSNumber alloc] initWithFloat:-500.0];
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
    
    ************************** END TEST CANVAS ****************************** */
    
    // Delete previus layers
    if (self.layer.sublayers.count > 0) {
        NSArray *oldLayers = [NSArray arrayWithArray:self.layer.sublayers];
        for (CALayer *oldLayer in oldLayers) {
            if ([oldLayer isKindOfClass:[CAShapeLayer class]]) {
                [oldLayer removeFromSuperlayer];
            }
        }
    }
    
    NSLog(@"[INFO][CA] Old layers removing; layers displayed: %ld", self.layer.sublayers.count);
    
    // Center point; if canvas' dimensions change, the center must be updated, so this is always done.
    center.x = self.frame.size.width/2;
    center.y = self.frame.size.height/2;
    UIBezierPath *centerBezierPath = [UIBezierPath bezierPath];
    [centerBezierPath moveToPoint:CGPointMake(center.x - 3.0, center.y)];
    [centerBezierPath addLineToPoint:CGPointMake(center.x + 3.0, center.y)];
    [centerBezierPath moveToPoint:CGPointMake(center.x, center.y - 3.0)];
    [centerBezierPath addLineToPoint:CGPointMake(center.x, center.y + 3.0)];
    
    CAShapeLayer *centerLayer = [[CAShapeLayer alloc] init];
    [centerLayer setPath:centerBezierPath.CGPath];
    [centerLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [centerLayer setFillColor:[UIColor clearColor].CGColor];
    [self.layer addSublayer:centerLayer];
    
    // Inspect dictionary from location manager for data retrieving
    //
    // { "measurePosition1":                              //  rangedBeaconsDic
    //     { "measurePosition": measurePosition;          //  positionDic
    //       "positionMeasures":
    //         { "measureUuid1":                          //  uuidDicDic
    //             { "uuid" : uuid1;                      //  uuidDic
    //               "uuidMeasures":
    //                 { "measure1":                      //  measureDicDic
    //                     { "type": "rssi"/"heading";    //  measureDic
    //                       "measure": rssi/heading
    //                     };
    //                   "measure2":  { (···) }
    //                 }
    //             };
    //           "measureUuid2": { (···) }
    //         }
    //     };
    //   "measurePosition2": { (···) }
    // }
    //
    // Declare the inner dictionaries.
    NSMutableDictionary * measureDic;
    NSMutableDictionary * measureDicDic;
    NSMutableDictionary * uuidDic;
    NSMutableDictionary * uuidDicDic;
    NSMutableDictionary * positionDic;
    
    // The positios must be scaled before its displaying
    NSMutableArray * realPositions = [[NSMutableArray alloc] init];
    NSArray * positionKeys = [self.rangedBeaconsDic allKeys];
    for (id positionKey in positionKeys) {
        // ...get the dictionary for this position...
        positionDic = [self.rangedBeaconsDic objectForKey:positionKey];
        // ...and the position.
        RDPosition * dicPosition = positionDic[@"measurePosition"];
        RDPosition * position = [[RDPosition alloc] init];
        position.x = dicPosition.x;
        position.y = dicPosition.y;
        position.z = dicPosition.z;
        [realPositions addObject:position];
    }
    NSMutableArray * canvasPositions = [self transformRealPointsToCanvasPoints:realPositions];
    
    // For every (canvas) position where measures were taken
    NSInteger positionIndex = 0;
    for (id positionKey in positionKeys) {
        // ...get the dictionary for this position...
        positionDic = [self.rangedBeaconsDic objectForKey:positionKey];
        // ...but get the transformed position.
        RDPosition * position = [canvasPositions objectAtIndex:positionIndex];
        NSLog(@"[INFO][CA] Position to show: (%.2f, %.2f, %.2f)", [position.x floatValue], [position.y floatValue],[position.z floatValue]);
        
        // DEFINE POSITION CANVAS REPRESENTATION (METHOD)
        UIBezierPath *positionBezierPath = [UIBezierPath bezierPath];
        [positionBezierPath addArcWithCenter:[position toNSPoint] radius:1 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        CAShapeLayer *positionLayer = [[CAShapeLayer alloc] init];
        [positionLayer setPath:positionBezierPath.CGPath];
        [positionLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
        [positionLayer setFillColor:[UIColor clearColor].CGColor];
        [[self layer] addSublayer:positionLayer];
        // * END * DEFINE POSITION CANVAS REPRESENTATION (METHOD)
        
        /* ******************************************************************
        
        // Get the the dictionary with the UUID's dictionaries...
        uuidDicDic = positionDic[@"positionMeasures"];
        // ...and for every UUID...
        NSArray * uuidKeys = [uuidDicDic allKeys];
        // Color for every UUID
        NSInteger UUIDindex = 0;
        for (id uuidKey in uuidKeys) {
            
            // ...get the dictionary...
            uuidDic = [uuidDicDic objectForKey:uuidKey];
            // ...and get the uuid.
            NSString * uuid = [NSString stringWithString:uuidDic[@"uuid"]];
            
            // DEFINE UUID CANVAS REPRESENTATION (METHOD)
            
            // * END * DEFINE UUID CANVAS REPRESENTATION (METHOD)
            
            // Get the the dictionary with the measures dictionaries...
            measureDicDic = uuidDic[@"uuidMeasures"];
            // ...and for every measure...
            NSArray * measuresKeys = [measureDicDic allKeys];
            for (id measureKey in measuresKeys) {
                // ...get the dictionary for this measure...
                measureDic = [measureDicDic objectForKey:measureKey];
                // ...and the measure.
                NSNumber * measure = [NSNumber numberWithFloat:[measureDic[@"measure"] floatValue]];
                
                // DEFINE MEASURE CANVAS REPRESENTATION (METHOD)
                RDPosition * canvasPosition = [canvasPositions objectAtIndex:positionIndex];
                CGRect rect = CGRectMake([canvasPosition.x floatValue] - [measure floatValue] * rWidth,
                                         [canvasPosition.y floatValue] - [measure floatValue] * rHeight,
                                         2.0 * [measure floatValue] * rWidth,
                                         2.0 * [measure floatValue] * rHeight);
                NSLog(@"[INFO][CA] Oval displayed with coordinates");
                NSLog(@"[INFO][CA] -> %.2f", [canvasPosition.x floatValue] - [measure floatValue] * rWidth);
                NSLog(@"[INFO][CA] -> %.2f", [canvasPosition.y floatValue] - [measure floatValue] * rHeight);
                NSLog(@"[INFO][CA] -> %.2f", 2.0 * [measure floatValue] * rWidth);
                NSLog(@"[INFO][CA] -> %.2f", 2.0 * [measure floatValue] * rHeight);
                NSLog(@"[INFO][CA] -> %.2f", 2.0 * rWidth);
                NSLog(@"[INFO][CA] -> %.2f", 2.0 * rHeight);
                NSLog(@"[INFO][CA] -> %.2f", 2.0 * [measure floatValue]);
                NSLog(@"[INFO][CA] -> %.2f", 2.0 * [measure floatValue]);
                UIBezierPath *measureBezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];

                
                CAShapeLayer *beaconLayer = [[CAShapeLayer alloc] init];
                [beaconLayer setPath:measureBezierPath.CGPath];
                
                switch (UUIDindex) {
                    case 0:
                        [beaconLayer setStrokeColor:[UIColor colorWithRed:255/255.0 green:0.0 blue:0.0 alpha:0.2].CGColor];
                        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                        break;
                        
                    case 1:
                        [beaconLayer setStrokeColor:[UIColor colorWithRed:0.0 green:255/255.0 blue:0.0 alpha:0.2].CGColor];
                        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                        break;
                        
                    case 2:
                        [beaconLayer setStrokeColor:[UIColor colorWithRed:0.0 green:0.0 blue:255/255.0 alpha:0.2].CGColor];
                        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                        break;
                        
                    case 3:
                        [beaconLayer setStrokeColor:[UIColor colorWithRed:127.0/255.0 green:128.0/255.0 blue:0.0 alpha:0.2].CGColor];
                        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                        break;
                        
                    case 4:
                        [beaconLayer setStrokeColor:[UIColor colorWithRed:127.0/255.0 green:0.0 blue:128.0/255.0 alpha:0.2].CGColor];
                        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                        break;
                        
                    case 5:
                        [beaconLayer setStrokeColor:[UIColor colorWithRed:0.0 green:127.0/255.0 blue:128.0/255.0 alpha:0.2].CGColor];
                        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                        break;
                        
                    case 6:
                        [beaconLayer setStrokeColor:[UIColor colorWithRed:127.0/255.0 green:64.0 blue:64.0 alpha:0.2].CGColor];
                        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                        break;
                        
                    case 7:
                        [beaconLayer setStrokeColor:[UIColor colorWithRed:64.0 green:127.0/255.0 blue:64.0 alpha:0.2].CGColor];
                        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                        break;
                        
                    default:
                        break;
                }
                [[self layer] addSublayer:beaconLayer];
                // * END * DEFINE MEASURE CANVAS REPRESENTATION (METHOD)
            }
            UUIDindex++;
        }
         ****************************************************************** */
        positionIndex++;
    }
    [self setNeedsDisplay];
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
 @method add:
 @discussion This method subtracts a 'RDPosition' point from another one.
 */
- (RDPosition *) add:(RDPosition *)pointA
                  to:(RDPosition *)pointB {
    RDPosition * addition = [[RDPosition alloc] init];
    addition.x = [[NSNumber alloc] initWithFloat:[pointB.x floatValue] + [pointA.x floatValue]];
    addition.y = [[NSNumber alloc] initWithFloat:[pointB.y floatValue] + [pointA.y floatValue]];
    addition.z = [[NSNumber alloc] initWithFloat:[pointB.z floatValue] + [pointA.z floatValue]];
    return addition;
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
    RDPosition * RDcenter = [[RDPosition alloc] init];
    RDcenter.x = [[NSNumber alloc] initWithFloat:center.x];
    RDcenter.y = [[NSNumber alloc] initWithFloat:center.y];
    
    // Case only one point
    if (realPoints.count == 1) {
        
        RDPosition * canvasPoint = [[RDPosition alloc] init];
        RDPosition * realPoint = [realPoints objectAtIndex:0];
        canvasPoint.x = [[NSNumber alloc] initWithFloat:[realPoint.x floatValue] + [RDcenter.x floatValue]];
        canvasPoint.y = [[NSNumber alloc] initWithFloat:[realPoint.y floatValue] + [RDcenter.y floatValue]];
        canvasPoint.z = realPoint.z;
        [canvasPoints addObject:canvasPoint];
        rWidth = 5.0;
        rHeight = 5.0;
        
    } else {
    
        // Define a safe area
        float widthSafe = canvasWidth * 0.15;
        float heightSafe = canvasHeight * 0.15;
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
        rWidth = (widthSafeMax - widthSafeMin)/(maxX - minX);;
        rHeight = (heightSafeMax - heightSafeMin)/(maxY - minY);
        
        // Transform the point's coordinates.
        // The first position is always (0, 0), and it is centered at the origin of the canvas, the upper left corner. Hence, a correction must be done in orther to center the set in the canvas. But as is not intended to display (0, 0) in the center of te canvas, but the barycenter of the set es calculated and translated to the center of the canvas. For this, the 'vector' needed for adding is the subtract of the center of the canvas minus the barycenter.
        
        // Get the proportionate set of canvas points with centered at the orgin of the canvas
        NSMutableArray * centeredCanvasPoints = [[NSMutableArray alloc] init];
        for (RDPosition * realPoint in realPoints) {
            RDPosition * centeredCanvasPoint = [[RDPosition alloc] init];
            centeredCanvasPoint.x = [[NSNumber alloc] initWithFloat:[realPoint.x floatValue] * rWidth];
            centeredCanvasPoint.y = [[NSNumber alloc] initWithFloat:[realPoint.y floatValue] * rHeight];
            centeredCanvasPoint.z = realPoint.z;
            [centeredCanvasPoints addObject:centeredCanvasPoint];
        }
        // Correct the points location.
        RDPosition * barycenter = [self getBarycenterOf:centeredCanvasPoints];
        RDPosition * correction = [self subtract:RDcenter from:barycenter];
        for (RDPosition * centeredCanvasPoint in centeredCanvasPoints) {
            RDPosition * correctedCanvasPoint = [self add:centeredCanvasPoint to:correction];
            [canvasPoints addObject:correctedCanvasPoint];
        }
        
    }
    return canvasPoints;
}

@end
