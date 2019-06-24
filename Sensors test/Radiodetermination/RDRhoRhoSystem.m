//
//  RDRhoRhoSystem.m
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDRhoRhoSystem.h"

@implementation RDRhoRhoSystem : NSObject

- (instancetype)init
{
    self = [super init];
    return self;
}

/*!
 @method get2DPositionWithRssi1:andRssi2:andReference1:andReference2:andPrediction:
 @discussion This method calculates the position in 2D space given other two reference positions and two measured RSSI values.
 */
- (RDPosition *) get2DPositionWithRssi1:(NSInteger) rssi1
                               andRssi2:(NSInteger) rssi2
                          andReference1:(RDPosition *) ref1
                          andReference2:(RDPosition *) ref2
                          andPrediction:(RDPosition *) pred
{
    // Retrieve coordinates from the reference positions
    NSNumber * x1 = ref1.x;
    NSNumber * y1 = ref1.y;
    NSNumber * x2 = ref2.x;
    NSNumber * y2 = ref2.y;
    // Estimate the distance given the RSSI values
    NSNumber * dis1 = [RDRhoRhoSystem calculateDistanceWithRssi:rssi1];
    NSNumber * dis2 = [RDRhoRhoSystem calculateDistanceWithRssi:rssi2];
    
    RDPosition * pos = [[RDPosition alloc] init];
    pos.x = x1;
    return pos;
}

/*!
 @method getLocationsUsingGridAproximationWithMeasures:
 precision:
 @discussion This method calculates any posible location with the measures taken from each beacon at different positions; it uses a simple grid search of the minimum of the least square of distances from positions were the measures were taken to the grid and the measures and the same point in the grid.
 */
- (NSMutableArray *) getLocationsUsingGridAproximationWithMeasures:(SharedData*)sharedData
                                                      andPrecision:(NSNumber*)precision
{
    
    NSMutableDictionary * measuresDic = [sharedData getMeasuresDic];
    
    // Inspect dictionary from location manager for data retrieving
    //
    // { "measurePosition1":                              //  measuresDic
    //     { "measurePosition": measurePosition;          //  positionDic
    //       "positionRangeMeasures":
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
    //       "positionHeadingMeasures":
    //         { "measureUuid1":                          //  uuidDicDic
    //             { "uuid" : uuid1;                      //  uuidDic
    //               "uuidMeasures":
    //                 { "measure3":                      //  measureDicDic
    //                     { "type": "rssi"/"heading";    //  measureDic
    //                       "measure": rssi/heading
    //                     };
    //                   "measure4":  { (···) }
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
    
    // The grid is calculed with the positions
    NSMutableArray * measurePositions = [sharedData fromMeasuresDicGetPositions];
    
    // MIN
    
    NSInteger positionIndex = 0;
    NSArray * positionKeys = [measuresDic allKeys];
    // For every (canvas) position where measures were taken
    for (id positionKey in positionKeys) {
        // ...get the dictionary for this position...
        positionDic = [measuresDic objectForKey:positionKey];
        // ...but also get the transformed position.
        RDPosition * realPosition = positionDic[@"measurePosition"];
        RDPosition * canvasPosition = [canvasPositions objectAtIndex:positionIndex];
        NSLog(@"[INFO][CA] Real position to show: %@", realPosition);
        NSLog(@"[INFO][CA] Canvas position to show: %@",  canvasPosition);
        NSLog(@"[INFO][CA] rWith: %.2f", rWidth);
        NSLog(@"[INFO][CA] rHeight: %.2f", rHeight);
        
        // DEFINE POSITION CANVAS REPRESENTATION (METHOD)
        
        // Draw the point
        UIBezierPath *positionBezierPath = [UIBezierPath bezierPath];
        [positionBezierPath addArcWithCenter:[canvasPosition toNSPoint] radius:1 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        CAShapeLayer *positionLayer = [[CAShapeLayer alloc] init];
        [positionLayer setPath:positionBezierPath.CGPath];
        [positionLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
        [positionLayer setFillColor:[UIColor clearColor].CGColor];
        [[self layer] addSublayer:positionLayer];
        
        // Text of real position but in canvas position
        CATextLayer *positionTextLayer = [CATextLayer layer];
        positionTextLayer.position = CGPointMake([canvasPosition.x floatValue] + 5.0, [canvasPosition.y floatValue] + 5.0);
        positionTextLayer.frame = CGRectMake([canvasPosition.x floatValue] + 5.0,
                                             [canvasPosition.y floatValue] + 5.0,
                                             100,
                                             20);
        positionTextLayer.string = [NSString stringWithFormat:@"(%.2f, %.2f)", [realPosition.x floatValue], [realPosition.y floatValue]];
        positionTextLayer.fontSize = 10;
        positionTextLayer.alignmentMode = kCAAlignmentCenter;
        positionTextLayer.backgroundColor = [[UIColor clearColor] CGColor];
        positionTextLayer.foregroundColor = [[UIColor blackColor] CGColor];
        [[self layer] addSublayer:positionTextLayer];
        
        // * END * DEFINE POSITION CANVAS REPRESENTATION (METHOD)
        
        // Get the the dictionary with the UUID's dictionaries...
        uuidDicDic = positionDic[@"positionRangeMeasures"];
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
            
            UIBezierPath *uuidBezierPath = [UIBezierPath bezierPath];
            
            // Choos a color for each UUID
            UIColor *colorUUID;
            switch (UUIDindex % 8) {
                case 0:
                    colorUUID = [UIColor colorWithRed:255/255.0 green:0.0 blue:0.0 alpha:0.2];
                    break;
                case 1:
                    colorUUID = [UIColor colorWithRed:0.0 green:255/255.0 blue:0.0 alpha:0.2];
                    break;
                case 2:
                    colorUUID = [UIColor colorWithRed:0.0 green:0.0 blue:255/255.0 alpha:0.2];
                    break;
                case 3:
                    colorUUID = [UIColor colorWithRed:127.0/255.0 green:128.0/255.0 blue:0.0 alpha:0.2];
                    break;
                case 4:
                    colorUUID = [UIColor colorWithRed:127.0/255.0 green:0.0 blue:128.0/255.0 alpha:0.2];
                    break;
                case 5:
                    colorUUID = [UIColor colorWithRed:0.0 green:127.0/255.0 blue:128.0/255.0 alpha:0.2];
                    break;
                case 6:
                    colorUUID = [UIColor colorWithRed:127.0/255.0 green:64.0 blue:64.0 alpha:0.2];
                    break;
                case 7:
                    colorUUID = [UIColor colorWithRed:64.0 green:127.0/255.0 blue:64.0 alpha:0.2];
                    break;
                default:
                    colorUUID = [UIColor colorWithRed:255/255.0 green:0.0 blue:0.0 alpha:0.2];
                    break;
            }
            
            // Choose a position for display the UUID
            [uuidBezierPath moveToPoint:CGPointMake(16.0, 8.0 * (UUIDindex + 1.0) + 10.0)];
            [uuidBezierPath addLineToPoint:CGPointMake(16.0 + 100.0, 8.0 * (UUIDindex + 1.0) + 10.0)];
            
            CAShapeLayer *uuidLayer = [[CAShapeLayer alloc] init];
            [uuidLayer setPath:uuidBezierPath.CGPath];
            [uuidLayer setStrokeColor:colorUUID.CGColor];
            [uuidLayer setFillColor:[UIColor clearColor].CGColor];
            [self.layer addSublayer:uuidLayer];
            
            // Add the description
            CATextLayer *uuidTextLayer = [CATextLayer layer];
            uuidTextLayer.position = CGPointMake(116.0, 8.0 * (UUIDindex + 1.0));
            uuidTextLayer.frame = CGRectMake(116.0, 8.0 * (UUIDindex + 1.0), 400, 20);
            uuidTextLayer.string = [NSString stringWithFormat:@"UUID: %@", uuid];
            uuidTextLayer.fontSize = 12;
            uuidTextLayer.alignmentMode = kCAAlignmentCenter;
            uuidTextLayer.backgroundColor = [[UIColor clearColor] CGColor];
            uuidTextLayer.foregroundColor = [[UIColor blackColor] CGColor];
            [[self layer] addSublayer:uuidTextLayer];
            
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
                
                //UIBezierPath *measureBezierPath = [UIBezierPath bezierPath];
                //[measureBezierPath addArcWithCenter:[canvasPosition toNSPoint] radius:[measure floatValue]*(rWidth+rHeight)/2.0 startAngle:0 endAngle:2 * M_PI clockwise:YES];
                //NSLog(@"[INFO][CA][TRAN] Radius measured: %.2f",  [measure floatValue]);
                //NSLog(@"[INFO][CA][TRAN] Radius canvas: %.2f",  [measure floatValue]*(rWidth+rHeight)/2.0);
                
                
                CGRect rect = CGRectMake([canvasPosition.x floatValue] - [measure floatValue] * rWidth,
                                         [canvasPosition.y floatValue] - [measure floatValue] * rHeight,
                                         2.0 * [measure floatValue] * rWidth,
                                         2.0 * [measure floatValue] * rHeight);
                UIBezierPath *measureBezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];
                NSLog(@"[INFO][CA][TRAN] Ellipse measured: %.2f, %.2f",  [measure floatValue],  [measure floatValue]);
                NSLog(@"[INFO][CA][TRAN] Ellipse canvas: %.2f, %.2f",  [measure floatValue] * rWidth, [measure floatValue] * rHeight);
                
                
                
                CAShapeLayer *beaconLayer = [[CAShapeLayer alloc] init];
                [beaconLayer setPath:measureBezierPath.CGPath];
                [beaconLayer setStrokeColor:colorUUID.CGColor];
                [beaconLayer setFillColor:[UIColor clearColor].CGColor];
                [[self layer] addSublayer:beaconLayer];
                // * END * DEFINE MEASURE CANVAS REPRESENTATION (METHOD)
            }
            UUIDindex++;
        }
        positionIndex++;
    }
    
    
    
}

/*!
 @method calculateDistanceWithRssi:
 @discussion This method calculates the distance from a signal was transmited using reception's RSSI value.
 */
+ (NSNumber *) calculateDistanceWithRssi: (NSInteger) rssi
{
    // Absolute values of speed of light, frecuency, and antenna's join gain
    float C = 299792458.0;
    float F = 2440000000.0; // 2400 - 2480 MHz
    float G = 1.0; // typically 2.16 dBi
    // Calculate the distance
    NSLog(@"[HOLA] aa %.2f", (float)rssi);
    NSNumber * distance = [[NSNumber alloc] initWithFloat:( (C / (4.0 * M_PI * F)) * sqrt(G * pow(10.0, (float)rssi/ 10.0)) )];
    NSLog(@"[HOLA] aa %.2f", [distance floatValue]);
    return distance;
}

@end
