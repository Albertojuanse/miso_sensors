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
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - Instance methods

/*!
 @method setCredentialsUserDic:
 @discussion This method sets the NSMutableDictionary with the security purposes user credentials.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    credentialsUserDic = givenCredentialsUserDic;
}

/*!
 @method setUserDic:
 @discussion This method sets the NSMutableDictionary with the identifying purposes user credentials.
 */
- (void) setUserDic:(NSMutableDictionary *)givenUserDic
{
    userDic = givenUserDic;
}

/*!
 @method prepareCanvasWithSharedData:userDic:andCredentialsUserDic:
 @discussion This method initializes some properties of the canvas; is called when the main view is loaded by its controller.
 */
- (void)prepareCanvasWithSharedData:(SharedData *)givenSharedData
                            userDic:(NSMutableDictionary *)givenUserDic
              andCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    // Initialize components and variables
    sharedData = givenSharedData;
    credentialsUserDic = givenCredentialsUserDic;
    userDic = givenUserDic;
    credentialsUserDic = givenCredentialsUserDic;
    rHeight = 1.0;
    rWidth = 1.0;
    barycenter = [[RDPosition alloc] init];
    barycenter.x = [NSNumber numberWithFloat:0.0];
    barycenter.y = [NSNumber numberWithFloat:0.0];
    barycenter.z = [NSNumber numberWithFloat:0.0];
    
    // Canvas configurations
    [self setUserInteractionEnabled:NO];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    UIColor * canvasColor = [UIColor colorWithRed:[layoutDic[@"canvas/red"] floatValue]/255.0
                                            green:[layoutDic[@"canvas/green"] floatValue]/255.0
                                             blue:[layoutDic[@"canvas/blue"] floatValue]/255.0
                                            alpha:1.0
                             ];
    self.backgroundColor = canvasColor;
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
    
    // Center point
    [self displayCenter];

    [self setNeedsDisplay];
}

#pragma mark - Notifications events handlers
/*!
 @method refreshCanvas:
 @discussion This method gets the beacons that must be represented in canvas and ask it to upload; this method is called when someone submits the 'refreshCanvas' notification.
 */
- (void) refreshCanvas:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"refreshCanvas"]){
        NSLog(@"[NOTI][VC] Notification \"refreshCanvas\" recived.");
        // TO DO. Logic. Alberto J. 2019/09/13.
    }
    [self setNeedsDisplay];
}

#pragma mark - Drawing methods

/*!
 @method testCanvas
 @discussion This method displays a pattern of 8 points in canvas to test its adjustment.
 */
- (void)testCanvas
{
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
    NSLog(@"[INFO][CA] Testing finished.");

    [self setNeedsDisplay];
}

/*!
 @method drawRect:
 @discussion This method controls the display of a new drawn area; is called when a new draw must be created and displayed.
 */
- (void)drawRect:(CGRect)rect {
    
    // Remove the old layers
    [self removeLayers];
    
    // Display the center point
    [self displayCenter];
    
    // Inspect shared data for data retrieving
    [self inspectDataDicsAndDrawTheInfoInRect:rect];
    
    [self setNeedsDisplay];
}

/*!
 @method removeLayers
 @discussion This method removes every layer displayed from the canvas; it is called by 'drawRect:' every time it is called.
 */
- (void)removeLayers
{
    // Delete previus layers
    if (self.layer.sublayers.count > 0) {
        NSArray *oldLayers = [NSArray arrayWithArray:self.layer.sublayers];
        for (CALayer *oldLayer in oldLayers) {
            if ([oldLayer isKindOfClass:[CAShapeLayer class]] ||[oldLayer isKindOfClass:[CATextLayer class]] ) {
                [oldLayer removeFromSuperlayer];
            }
        }
    }
    
    NSLog(@"[INFO][CA] Old layers removing; layers displayed: %ld", self.layer.sublayers.count);
}

/*!
 @method displayCenter
 @discussion This method creates and display a layer with the center point of the canvas.
 */
- (void)displayCenter
{
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
}

/*!
 @method inspectDataDicsAndDrawTheInfoInRect:
 @discussion This method inspects collections in shared data for retrieving and ask to display the information.
 */
- (void) inspectDataDicsAndDrawTheInfoInRect:(CGRect)rect {
    
    //                // USER DATA //
    //
    // The schema of the userData collection is:
    //
    //  [{ "name": (NSString *)name1;                  // userDic
    //     "pass": (NSString *)pass1;
    //     "role": (NSString *)role1;
    //   },
    //   { "name": (NSString *)name2;                  // userDic
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    //              // SESSION DATA //
    //
    // The schema of the sessionData collection is:
    //
    //  [{ "user": { "name": (NSString *)name1;                  // sessionDic; userDic
    //               "pass": (NSString *)pass1;
    //               "role": (NSString *)role1;
    //             }
    //     "modes": (NSMutableArray *)modes;
    //     "mode": (NSString *)mode1;
    //     "routine": (BOOL)routine;
    //     "routineModel": (NSMutableDictionary *)routineModelDic;
    //     "state": (NSString *)state1;
    //     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
    //     "itemsChosenByUser": (NSMutableArray *)items1;
    //     "typeChosenByUser": (MDType *)type1;
    //     "referencesByUser": (NSMutableArray *)references1
    //   },
    //   { "user": { "name": (NSString *)name2;                  // sessionDic; userDic
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    //             // ITEMS DATA //
    //
    // The schema of the itemsData collection is:
    //
    //  [{ "sort": @"beacon" | @"position";                      //  itemDic
    //     "identifier": (NSString *)identifier1;
    //
    //     "uuid": (NSString *)uuid1;
    //
    //     "major": (NSString *)major1;
    //     "minor": (NSString *)minor1;
    //
    //     "position": (RDPosition *)position1;
    //
    //     "located": @"YES" | @"NO";
    //
    //     "type": (MDType *)type1
    //   },
    //   { "sort": @"beacon" | @"position";
    //     "identifier": (NSString *)identifier2;
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    //            // MEASURES DATA //
    //
    //  [{ "user": { "name": (NSString *)name1;                  // measureDic; userDic
    //               "pass": (NSString *)pass1;
    //               "role": (NSString *)role1;
    //             }
    //     "position": (RDPosition *)position1;
    //     "itemUUID": (NSString *)itemUUID1;
    //     "deviceUUID": (NSString *)deviceUUID1;
    //     "sort" : (NSString *)type1;
    //     "measure": (NSNumber *)measure1
    //   },
    //   { "user": { "name": (NSString *)name2;                  // measureDic; userDic
    //               "pass": (NSString *)pass2;
    //               "role": (NSString *)role2;
    //             }
    //     "position": (RDPosition *)position2;
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    //               // TYPES DATA //
    //
    // The schema of typesData collection is
    //
    //  [ (MDType *)type1,
    //    (···)
    //  ]
    //
    //            // METAMODEL DATA //
    //
    // The schema of metamodelsData collection is
    //
    //  [ (MDMetamodel *)metamodel1,
    //    (···)
    //  ]
    //
    //              // MODEL DATA //
    //
    // The schema of modelData collection is is
    //
    //  [{ "name": name1;                                        //  modelDic
    //     "components": [
    //         { "position": (RDPosition *)position1;            //  componentDic
    //           "type": (MDType *)type1;
    //           "sourceItem": (NSMutableDictionary *)itemDic1;  //  itemDic
    //         { "position": (RDPosition *)positionB;
    //           (···)
    //         },
    //         (···)
    //     ];
    //     "references": [
    //         (MDReference *)reference1,
    //         (···)
    //     ]
    //   },
    //   { "name": name2;                                        //  modelDic
    //     (···)
    //   },
    //  ]
    //
    
    // The positions must be scaled before its displaying
    // Get measured, chosen items' and locations' positions and merge them into a single array
    NSMutableArray * itemsPositions = [sharedData fromSessionDataGetPositionsOfItemsChosenByUserDic:credentialsUserDic
                                                                            withCredentialsUserName:credentialsUserDic];
    NSMutableArray * locatedPositions = [sharedData fromItemDataGetPositionsOfLocatedItemsByUser:userDic
                                                                andCredentialsUserDic:credentialsUserDic];
    NSMutableArray * measurePositions = [sharedData fromMeasuresDataGetPositionsWithCredentialsUserDic:credentialsUserDic];
    NSMutableArray * realPositions = [[NSMutableArray alloc] init];
    for (RDPosition * position in itemsPositions) {
        [realPositions addObject:position];
        NSLog(@"[INFO][CA] Got real item position %@", position);
    }
    for (RDPosition * position in locatedPositions) {
        [realPositions addObject:position];
        NSLog(@"[INFO][CA] Got real located position %@", position);
    }
    for (RDPosition * position in measurePositions) {
        [realPositions addObject:position];
        NSLog(@"[INFO][CA] Got real measure position %@", position);
    }
    
    // Transform the real positions to an apropiate canvas ones, with the barycenter of the set of points in the center of the canvas
    // This method also sets the ratios in the class variables 'rWidth' and 'rHeight'; then, they will be used for transform every single point
    // TO DO: make the SafeAreaRatio configurable (zoom). Alberto J. 2019/09/16.
    [self calculateRatiosOfTransformationFromRealPointsToCanvasPoints:realPositions
                                                    withSafeAreaRatio:[NSNumber numberWithFloat:0.35]];
    NSLog(@"[INFO][CA] Calculated trasformation ratio rWith: %.2f", rWidth);
    NSLog(@"[INFO][CA] Calculated trasformation ratio rHeight: %.2f", rHeight);
    
    // Now, inspect the dictionary and get the information to display
    
    
    // Registro de lo que se representa
    
    // Representar las posiciones localizadas
        // ¿Ya esta representada?
            // Si sí, completar
            // Si no
                // Representar los tipos de las posiciones
                // Representar los UUID de las posiciones
    
    // Representar las posiciones de medida
        // ¿Ya esta representada?
            // Si sí, completar
            // Si no
                // Representar los UUID de las medidas
    
    // Hay que representar por tanto
        // Posiciones
        // Tipos centrados en ellas
        // UUID en interfaz
        // UUID centrados en ellas
        // Medidas centrados en ellas
    
    
    //              // ITEMS POSITION //
    // Show the chosen items by the user; the items used for locations like positions or beacons if known.
    // For every item position...
    for (RDPosition * realItemPosition in itemsPositions) {
        
        // ...get the transformed position...
        RDPosition * canvasItemPosition = [self transformSingleRealPointToCanvasPoint:realItemPosition];
        NSLog(@"[INFO][CA] Drawing canvas item position %@", canvasItemPosition);
        
        // ...,its type and UUID, ...
        NSMutableArray * itemsInRealItemPosition = [sharedData fromItemDataGetItemsWithPosition:realItemPosition
                                                                          andCredentialsUserDic:credentialsUserDic];
        MDType * itemType;
        NSString * itemUUID;
        if (itemsInRealItemPosition) {
            if (itemsInRealItemPosition.count != 0) {
                if (!(itemsInRealItemPosition.count > 1)) {
                    NSMutableDictionary * itemDicSelected = [itemsInRealItemPosition objectAtIndex:0];
                    itemType = itemDicSelected[@"type"];
                    itemUUID = itemDicSelected[@"uuid"];
                } else {  // More than one items found
                    NSLog(@"[ERROR][CA] Too items types found when getting types for some item's position; using first one.");
                    // TO DO: Manage this. Alberto J. 2019/10/1.
                    NSMutableDictionary * itemDicSelected = [itemsInRealItemPosition objectAtIndex:0];
                    itemType = itemDicSelected[@"type"];
                    itemUUID = itemDicSelected[@"uuid"];
                }
            } else {  // Items not found
                NSLog(@"[ERROR][CA] No items found when getting types for some item's position; empty array returned.");
            }
        } else {  // Acess could not be granted or items not found
            NSLog(@"[ERROR][CA] No items found when getting types for some item's position; null returned.");
        }
        
        // ...and draw it.
        if (itemUUID) {  // Items UUID are always required
            if (!itemType) {
                [self drawPosition:realItemPosition
                  inCanvasPosition:canvasItemPosition
                           andUUID:itemUUID];
            } else {
                [self drawPosition:realItemPosition
                  inCanvasPosition:canvasItemPosition
                              UUID:itemUUID
                       andWithType:itemType];
            }
        } else {
            NSLog(@"[ERROR][CA] No item's UUID found in item while its showing.");
        }
        
    }
    
    //              // LOCATED POSITION //
    // Show the located positions, the ones located with the radiolocation systems.
    // For every located position...
    for (RDPosition * realLocatedPosition in locatedPositions) {
        
        // ...get the transformed position...
        RDPosition * canvasLocatedPosition = [self transformSingleRealPointToCanvasPoint:realLocatedPosition];
        NSLog(@"[INFO][CA] Drawing canvas located position %@", canvasLocatedPosition);
        
        // ...,its type and UUID, ...
        NSMutableArray * itemsInRealLocatedPosition = [sharedData fromItemDataGetItemsWithPosition:realLocatedPosition
                                                                             andCredentialsUserDic:credentialsUserDic];
        MDType * itemType;
        NSString * itemUUID;
        if (itemsInRealLocatedPosition) {
            if (itemsInRealLocatedPosition.count != 0) {
                if (!(itemsInRealLocatedPosition.count > 1)) {
                    NSMutableDictionary * itemDicSelected = [itemsInRealLocatedPosition objectAtIndex:0];
                    itemType = itemDicSelected[@"type"];
                    itemUUID = itemDicSelected[@"uuid"];
                } else {  // More than one items found
                    NSLog(@"[ERROR][CA] Too items types found when getting types for some located position; using first one.");
                    // TO DO: Manage this. Alberto J. 2019/10/1.
                }
            } else {  // Items not found
                NSLog(@"[ERROR][CA] No items found when getting types for some located position; empty array returned.");
            }
        } else {  // Acess could not be granted or items not found
            NSLog(@"[ERROR][CA] No items found when getting types for some located position; null returned.");
        }
        
        // ...and draw it.
        if (itemUUID) {  // Items UUID are always required
            if (!itemType) {
                [self drawPosition:realLocatedPosition
                  inCanvasPosition:canvasLocatedPosition
                           andUUID:itemUUID];
            } else {
                [self drawPosition:realLocatedPosition
                  inCanvasPosition:canvasLocatedPosition
                              UUID:itemUUID
                       andWithType:itemType];
            }
        } else {
            NSLog(@"[ERROR][CA] No located position's UUID found in item while its showing.");
        }
        
    }
    
    //              // REFERENCES //
    // Show the references.
    // Reatrrieve the references...
    NSMutableArray * references = [sharedData fromSessionDataGetReferencesByUserDic:userDic
                                                             withCredentialsUserDic:credentialsUserDic];
    // ... show them.
    // For every reference...
    for (MDReference * reference in references) {
        
        // ...get the source and target position
        NSString * sourceItemId = [reference getSourceItemId];
        NSMutableDictionary * sourceItem = [[sharedData fromItemDataGetItemsWithIdentifier:sourceItemId
                                                                     andCredentialsUserDic:credentialsUserDic]
                                            objectAtIndex:0];
        RDPosition * sourcePosition = sourceItem[@"position"];
        NSString * targetItemId = [reference getTargetItemId];
        NSMutableDictionary * targetItem = [[sharedData fromItemDataGetItemsWithIdentifier:targetItemId
                                                                     andCredentialsUserDic:credentialsUserDic]
                                            objectAtIndex:0];
        RDPosition * targetPosition = targetItem[@"position"];
        // ...and show the reference between them if they both exist.
        if (targetPosition && sourcePosition) {
          
            // Get the transformed position...
            RDPosition * canvasSourcePosition = [self transformSingleRealPointToCanvasPoint:sourcePosition];
            RDPosition * canvasTargetPosition = [self transformSingleRealPointToCanvasPoint:targetPosition];
            NSLog(@"[INFO][CA] Drawing canvas located reference between %@ and %@", canvasSourcePosition, canvasTargetPosition);
            
            // ..., the reference type, ...
            MDType * referenceType = [reference getType];
            
            // ...and draw it.
            if (!referenceType) {
                [self drawReferenceFromSourcePosition:canvasSourcePosition
                                     toTargetPosition:canvasTargetPosition
                 ];
            } else {
                [self drawReferenceFromSourcePosition:canvasSourcePosition
                                     toTargetPosition:canvasTargetPosition
                                              andType:referenceType
                 ];
            }
            
        } else { // Error, some position does not exist
            NSLog(@"[ERROR][CA] Some reference position, target, spurce or both, do not exist.");
        }
    }
    
    // For every (canvas) position where measures were taken...
    for (RDPosition * realMeasurePosition in measurePositions) {
        
        // ...get the transformed position...
        //RDPosition * canvasMeasurePosition = [self transformSingleRealPointToCanvasPoint:realMeasurePosition];
        //NSLog(@"[INFO][CA] Drawing canvas mesure position %@", canvasMeasurePosition);
        // ...and draw it.
        // [self drawPosition:realMeasurePosition inCanvasPosition:canvasMeasurePosition];
        //VCPosition * positionView = [[VCPosition alloc] initWithFrame:CGRectMake([canvasMeasurePosition.x floatValue],[canvasMeasurePosition.y floatValue],3.0,3.0)];
        //[self addSubview:positionView];
        
        
        
        //NSLog(@"[INFO][CA] Real position to show: %@", realMeasurePosition);
        //NSLog(@"[INFO][CA] Canvas position to show: %@",  canvasMeasurePosition);
        //NSLog(@"[INFO][CA] rWith: %.2f", rWidth);
        //NSLog(@"[INFO][CA] rHeight: %.2f", rHeight);
        
        // Get the collection of UUID measured from that position...
        // NSMutableArray * measuredUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic withCredentialsUserDic:credentialsUserDic];
        
    }
    
    /*
    for (id positionKey in positionKeys) {
        // ...get the dictionary for this position...
        positionDic = [self.measuresDic objectForKey:positionKey];
        // ...but also get the transformed position.
        RDPosition * realPosition = positionDic[@"measurePosition"];
        RDPosition * canvasPosition = [self transformSingleRealPointToCanvasPoint:realPosition];
        
        //NSLog(@"[INFO][CA] Real position to show: %@", realPosition);
        //NSLog(@"[INFO][CA] Canvas position to show: %@",  canvasPosition);
        //NSLog(@"[INFO][CA] rWith: %.2f", rWidth);
        //NSLog(@"[INFO][CA] rHeight: %.2f", rHeight);
        
        // ...and draw it.
        [self drawPosition:realPosition inCanvasPosition:canvasPosition];
        
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
            
            // Also get the color for its representation, both
            // - the beacon device or the reference position aimed that is the measures source and
            // - the radiolocated positions, which could be or not the measure source or not.
            
            // Draw the source UUID identifier
            [self drawMeasureUUID:uuid atIndex:UUIDindex andWithColor:[self getColorForIndex:UUIDindex]];
            
            // Get the the dictionary with the measures dictionaries...
            measureDicDic = uuidDic[@"uuidMeasures"];
            // ...and for every measure...
            NSArray * measuresKeys = [measureDicDic allKeys];
            for (id measureKey in measuresKeys) {
                // ...get the dictionary for this measure...
                measureDic = [measureDicDic objectForKey:measureKey];
                // ...and the measure.
                NSNumber * measure = [NSNumber numberWithFloat:[measureDic[@"measure"] floatValue]];
                NSString * type = measureDic[@"sort"];
                
                // Draw the measure
                [self drawMeasure:measure
                           ofType:type
                        withColor:[self getColorForIndex:UUIDindex]
                       atPosition:realPosition
                           inRect:rect];
                
            }
            
            // Before finish, draw any radiolocated position that shares UUID with the drawn one; that means that is the source of the measures or the reference position that they define.
            [self drawLocatedPositionIfItSharesUUIDWith:uuid
                                              withColor:[self getColorForIndex:UUIDindex]];
            
            UUIDindex++;
        }
    }
     */
}

/*!
 @method drawPosition:inCanvasPosition:andUUID
 @discussion This method displays a position in space 'realPosition' using its coordinates in the canvas, 'canvasPosition', given its UUID.
 */
- (void) drawPosition:(RDPosition *)realPosition
     inCanvasPosition:(RDPosition *)canvasPosition
              andUUID:(NSString *)uuid
{
    // Draw the point
    VCPosition *positionView = [[VCPosition alloc] initWithFrame:CGRectMake([canvasPosition.x floatValue],
                                                                            [canvasPosition.y floatValue],
                                                                            20,
                                                                            20)];
    [self addSubview:positionView];
    
    // Text of real position but in canvas position
    CATextLayer *positionTextLayer = [CATextLayer layer];
    positionTextLayer.position = CGPointMake([canvasPosition.x floatValue] + 5.0, [canvasPosition.y floatValue] + 5.0);
    positionTextLayer.frame = CGRectMake([canvasPosition.x floatValue] + 0.0,
                                         [canvasPosition.y floatValue] + 5.0,
                                         100,
                                         20);
    positionTextLayer.string = [NSString stringWithFormat:@"(%.2f, %.2f)", [realPosition.x floatValue], [realPosition.y floatValue]];
    positionTextLayer.fontSize = 10;
    positionTextLayer.alignmentMode = kCAAlignmentCenter;
    positionTextLayer.backgroundColor = [[UIColor clearColor] CGColor];
    positionTextLayer.foregroundColor = [[UIColor blackColor] CGColor];
    [[self layer] addSublayer:positionTextLayer];
    
    // Text of UUID in canvas position
    CATextLayer * uuidTextLayer = [CATextLayer layer];
    uuidTextLayer.position = CGPointMake([canvasPosition.x floatValue] - 0.0, [canvasPosition.y floatValue] + 15.0);
    uuidTextLayer.frame = CGRectMake([canvasPosition.x floatValue] - 0.0,
                                     [canvasPosition.y floatValue] + 15.0,
                                     100,
                                     20);
    uuidTextLayer.string = [NSString stringWithFormat:@"%@", [uuid substringFromIndex:30]];
    uuidTextLayer.fontSize = 10;
    uuidTextLayer.alignmentMode = kCAAlignmentCenter;
    uuidTextLayer.backgroundColor = [[UIColor clearColor] CGColor];
    uuidTextLayer.foregroundColor = [[UIColor blackColor] CGColor];
    [[self layer] addSublayer:uuidTextLayer];
    
    return;
}

/*!
 @method drawPosition:inCanvasPosition:UUID:andWithType:
 @discussion This method displays a position in space 'realPosition' using its coordinates in the canvas, 'canvasPosition', given its UUID and type.
 */
- (void) drawPosition:(RDPosition *)realPosition
     inCanvasPosition:(RDPosition *)canvasPosition
                 UUID:(NSString *)uuid
          andWithType:(MDType *)type
{
    // Call the position representation
    [self drawPosition:realPosition inCanvasPosition:canvasPosition andUUID:uuid];
    
    // Draw the type
    // Get its color...
    NSUInteger typeIndex = 5;
    NSMutableArray * types = [sharedData getTypesDataWithCredentialsUserDic:credentialsUserDic];
    for (MDType * eachType in types) {
        typeIndex++;
        if ([eachType isEqualToMDType:type]) {
            break;
        }
    }
    UIColor * color = [self getColorForIndex:typeIndex];
    VCType * typeView = [[VCType alloc] initWithFrame:CGRectMake([canvasPosition.x floatValue] + 5.0,
                                                                 [canvasPosition.y floatValue] - 10.0,
                                                                 100,
                                                                 20)
                                                color:color
                                              andName:[type getName]];
    
    
    [self  addSubview:typeView];
}

/*!
 @method drawReferenceFromSourcePosition:toTargetPosition:
 @discussion This method displays a reference between two positions using its coordinates in the canvas.
 */
- (void) drawReferenceFromSourcePosition:(RDPosition *)targetPosition
                        toTargetPosition:(RDPosition *)sourcePosition
{
    
    // Given the two points, a line is required not between them but two points near them and separated some distance; if not, the line starts inside them and is not visual.
    // Given two points, the distance between them is
    NSNumber * distance = [NSNumber numberWithDouble:
                           sqrt(
                                ([targetPosition.x doubleValue] - [sourcePosition.x doubleValue]) *
                                ([targetPosition.x doubleValue] - [sourcePosition.x doubleValue]) +
                                ([targetPosition.y doubleValue] - [sourcePosition.y doubleValue]) *
                                ([targetPosition.y doubleValue] - [sourcePosition.y doubleValue])
                                )
                           ];
    // and the desired distance is 20 (pixels)
    NSNumber * desired_distance = [NSNumber numberWithDouble:[distance floatValue] - 20];
    // so the ratio is
    NSNumber * ratio = [NSNumber numberWithFloat:[desired_distance floatValue]/[distance floatValue]];
    // and the two points are
    NSNumber * sourcePointX = [NSNumber numberWithFloat:
                               (1 - [ratio floatValue]) * [sourcePosition.x floatValue] +
                               [ratio floatValue] * [targetPosition.x floatValue]
                               ];
    NSNumber * sourcePointY = [NSNumber numberWithFloat:
                               (1 - [ratio floatValue]) * [sourcePosition.y floatValue] +
                               [ratio floatValue] * [targetPosition.y floatValue]
                               ];
    CGPoint sourcePoint = CGPointMake([sourcePointX floatValue],[sourcePointY floatValue]);
    NSNumber * targetPointX = [NSNumber numberWithFloat:
                               (1 - [ratio floatValue]) * [targetPosition.x floatValue] +
                               [ratio floatValue] * [sourcePosition.x floatValue]
                               ];
    NSNumber * targetPointY = [NSNumber numberWithFloat:
                               (1 - [ratio floatValue]) * [targetPosition.y floatValue] +
                               [ratio floatValue] * [sourcePosition.y floatValue]
                               ];
    CGPoint targetPoint = CGPointMake([targetPointX floatValue],[targetPointY floatValue]);
    
    // Compose the line between them
    UIBezierPath * referenceBezierPath = [UIBezierPath bezierPath];
    [referenceBezierPath moveToPoint:sourcePoint];
    [referenceBezierPath addLineToPoint:targetPoint];
    
    CAShapeLayer *referenceLayer = [[CAShapeLayer alloc] init];
    [referenceLayer setPath:referenceBezierPath.CGPath];
    [referenceLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [referenceLayer setFillColor:[UIColor clearColor].CGColor];
    [[self layer] addSublayer:referenceLayer];
    
    return;
}

/*!
 @method drawReferenceFromSourcePosition:toTargetPosition:andType:
 @discussion This method displays a reference between two positions using its coordinates in the canvas and the type assigned to it.
 */
- (void) drawReferenceFromSourcePosition:(RDPosition *)targetPosition
                        toTargetPosition:(RDPosition *)sourcePosition
                                 andType:(MDType *)referenceType
{
    
    [self drawReferenceFromSourcePosition:targetPosition toTargetPosition:sourcePosition];
    
    // Draw the type
    // Get its color...
    NSUInteger typeIndex = 5;
    NSMutableArray * types = [sharedData getTypesDataWithCredentialsUserDic:credentialsUserDic];
    for (MDType * eachType in types) {
        typeIndex++;
        if ([eachType isEqualToMDType:referenceType]) {
            break;
        }
    }
    UIColor * color = [self getColorForIndex:typeIndex];
    
    // ...the middle point...
    NSNumber * middleX = [NSNumber numberWithFloat:
                          ([targetPosition.x floatValue] + [sourcePosition.x floatValue])/2.0
                          ];
    NSNumber * middleY = [NSNumber numberWithFloat:
                          ([targetPosition.y floatValue] + [sourcePosition.y floatValue])/2.0
                          ];
    CGPoint middlePoint = CGPointMake([middleX floatValue],[middleY floatValue]);
    
    // ...and draw it
    CATextLayer *typeTextLayer = [CATextLayer layer];
    typeTextLayer.position = middlePoint;
    typeTextLayer.frame = CGRectMake(middlePoint.x,
                                     middlePoint.y,
                                     100,
                                     20);
    typeTextLayer.string = [NSString stringWithFormat:@"%@", referenceType];
    typeTextLayer.fontSize = 12;
    typeTextLayer.alignmentMode = kCAAlignmentCenter;
    typeTextLayer.backgroundColor = [[UIColor clearColor] CGColor];
    typeTextLayer.foregroundColor = [color CGColor];
    [[self layer] addSublayer:typeTextLayer];
    
    return;
}

/*

- (void) drawLocatedPositionIfItSharesUUIDWith:(NSString *)uuid
                                     withColor:(UIColor *)color
{
    
    // The schema of the locatedDic object is:
    //
    // { "locatedPosition1":                              //  self.locatedDic
    //     { "locatedUUID": locatedUUID;                  //  positionDic
    //       "locatedPosition": locatedPosition;
    //     };
    //   "locatedPosition2": { (···) }
    // }
    //
    
    // Declare the inner dictionaries.
    NSMutableDictionary * positionDic;
    
    NSArray * locatedKeys = [self.locatedDic allKeys];
    for (id locatedKey in locatedKeys) {
        // ...get the dictionary for this position...
        positionDic = [self.locatedDic objectForKey:locatedKey];
        // ...and the UUID. If it is equal, draw the located position
        NSString * locatedUUID = positionDic[@"locatedUUID"];
        if ([locatedUUID isEqualToString:uuid]) {
            RDPosition * locatedPosition = positionDic[@"locatedPosition"];
            NSLog(@"[INFO][CA] Real located position to show: %@", locatedPosition);
            RDPosition * canvasLocatedPosition = [self transformSingleRealPointToCanvasPoint:locatedPosition];
            NSLog(@"[INFO][CA] Canvas located position to show: %@", canvasLocatedPosition);
            
            UIBezierPath * locatedBezierPath = [UIBezierPath bezierPath];
            
            // Display the located position
            [locatedBezierPath moveToPoint:CGPointMake([canvasLocatedPosition.x floatValue] - 3.0,
                                                       [canvasLocatedPosition.y floatValue]  - 3.0)];
            [locatedBezierPath addLineToPoint:CGPointMake([canvasLocatedPosition.x floatValue] + 3.0,
                                                          [canvasLocatedPosition.y floatValue] + 3.0)];
            [locatedBezierPath moveToPoint:CGPointMake([canvasLocatedPosition.x floatValue] + 3.0,
                                                       [canvasLocatedPosition.y floatValue] - 3.0)];
            [locatedBezierPath addLineToPoint:CGPointMake([canvasLocatedPosition.x floatValue] - 3.0,
                                                          [canvasLocatedPosition.y floatValue] + 3.0)];
            
            CAShapeLayer *locatedLayer = [[CAShapeLayer alloc] init];
            [locatedLayer setPath:locatedBezierPath.CGPath];
            [locatedLayer setStrokeColor:color.CGColor];
            [locatedLayer setFillColor:[UIColor clearColor].CGColor];
            [self.layer addSublayer:locatedLayer];
            
            
            // Text of real located position but in located canvas position
            CATextLayer *locatedTextLayer = [CATextLayer layer];
            locatedTextLayer.position = CGPointMake([canvasLocatedPosition.x floatValue] + 5.0,
                                                    [canvasLocatedPosition.y floatValue] + 5.0);
            locatedTextLayer.frame = CGRectMake([canvasLocatedPosition.x floatValue] + 5.0,
                                                [canvasLocatedPosition.y floatValue] + 5.0,
                                                100,
                                                20);
            locatedTextLayer.string = [NSString stringWithFormat:@"(%.2f, %.2f)",
                                       [locatedPosition.x floatValue],
                                       [locatedPosition.y floatValue]];
            locatedTextLayer.fontSize = 10;
            locatedTextLayer.alignmentMode = kCAAlignmentCenter;
            locatedTextLayer.backgroundColor = [[UIColor clearColor] CGColor];
            locatedTextLayer.foregroundColor = [[UIColor blackColor] CGColor];
            [[self layer] addSublayer:locatedTextLayer];
            
        }
    }
}
 */

/*!
 @method getColorForIndex:
 @discussion This method returns a 'UIColor' object given the index in which certain object is found while dictionaries inspection; it provides a feed of different colors.
 */
- (UIColor *) getColorForIndex:(NSInteger)index {
    // Choose a color for each UUID
    UIColor *color;
    switch (index % 8) {
        case 0:
            color = [UIColor colorWithRed:255/255.0 green:0.0 blue:0.0 alpha:1.0];
            break;
        case 1:
            color = [UIColor colorWithRed:0.0 green:0.0 blue:255/255.0 alpha:1.0];
            break;
        case 2:
            color = [UIColor colorWithRed:0.0 green:255/255.0 blue:0.0 alpha:1.0];
            break;
        case 3:
            color = [UIColor colorWithRed:127.0/255.0 green:128.0/255.0 blue:0.0 alpha:1.0];
            break;
        case 4:
            color = [UIColor colorWithRed:127.0/255.0 green:0.0 blue:128.0/255.0 alpha:1.0];
            break;
        case 5:
            color = [UIColor colorWithRed:0.0 green:127.0/255.0 blue:128.0/255.0 alpha:1.0];
            break;
        case 6:
            color = [UIColor colorWithRed:127.0/255.0 green:64.0 blue:64.0 alpha:1.0];
            break;
        case 7:
            color = [UIColor colorWithRed:64.0 green:127.0/255.0 blue:64.0 alpha:1.0];
            break;
        default:
            color = [UIColor colorWithRed:255/255.0 green:0.0 blue:0.0 alpha:1.0];
            break;
    }
    return color;
}

/*!
 @method drawMeasureUUID
 @discussion This method displays a certain measure source UUID given its color.
 */
- (void) drawMeasureUUID:(NSString *)uuid
                 atIndex:(NSInteger)index
            andWithColor:(UIColor *)color
{
    UIBezierPath * uuidBezierPath = [UIBezierPath bezierPath];
    
    
    
    // Choose a position for display the UUID
    [uuidBezierPath moveToPoint:CGPointMake(16.0, 16.0 * (index + 1.0) + 2.0 + 10.0)];
    [uuidBezierPath addLineToPoint:CGPointMake(16.0 + 100.0, 16.0 * (index + 1.0) + 2.0 + 10.0)];
    
    CAShapeLayer *uuidLayer = [[CAShapeLayer alloc] init];
    [uuidLayer setPath:uuidBezierPath.CGPath];
    [uuidLayer setStrokeColor:color.CGColor];
    [uuidLayer setFillColor:[UIColor clearColor].CGColor];
    [self.layer addSublayer:uuidLayer];
    
    // Add the description
    CATextLayer *uuidTextLayer = [CATextLayer layer];
    uuidTextLayer.position = CGPointMake(116.0, 16.0 * (index + 1.0));
    uuidTextLayer.frame = CGRectMake(116.0, 16.0 * (index + 1.0), 400, 20);
    uuidTextLayer.string = [NSString stringWithFormat:@"Source UUID: %@", uuid];
    uuidTextLayer.fontSize = 12;
    uuidTextLayer.alignmentMode = kCAAlignmentCenter;
    uuidTextLayer.backgroundColor = [[UIColor clearColor] CGColor];
    uuidTextLayer.foregroundColor = [[UIColor blackColor] CGColor];
    [[self layer] addSublayer:uuidTextLayer];
}

/*!
 @method drawMeasure:ofSort:withColor:atPosition:inRect:
 @discussion This method displays a measure given its color, position, sort and the object 'CGRect' in which the canvas is being drawn.
 */
- (void) drawMeasure:(NSNumber *)measure
              ofSort:(NSString *)type
           withColor:(UIColor *)color
          atPosition:(RDPosition *)realPosition
              inRect:(CGRect)rect
{
    RDPosition * canvasPosition = [self transformSingleRealPointToCanvasPoint:realPosition];
    if ([type isEqualToString:@"rssi"]) {
        //UIBezierPath *measureBezierPath = [UIBezierPath bezierPath];
        //[measureBezierPath addArcWithCenter:[canvasPosition toNSPoint] radius:[measure floatValue]*(rWidth+rHeight)/2.0 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        //NSLog(@"[INFO][CA][TRAN] Radius measured: %.2f",  [measure floatValue]);
        //NSLog(@"[INFO][CA][TRAN] Radius canvas: %.2f",  [measure floatValue]*(rWidth+rHeight)/2.0);
        
        
        CGRect rect = CGRectMake([canvasPosition.x floatValue] - [measure floatValue] * rWidth,
                                 [canvasPosition.y floatValue] - [measure floatValue] * rHeight,
                                 2.0 * [measure floatValue] * rWidth,
                                 2.0 * [measure floatValue] * rHeight);
        UIBezierPath *measureBezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        //NSLog(@"[INFO][CA][TRAN] Ellipse measured: %.2f, %.2f",  [measure floatValue],  [measure floatValue]);
        //NSLog(@"[INFO][CA][TRAN] Ellipse canvas: %.2f, %.2f",  [measure floatValue] * rWidth, [measure floatValue] * rHeight);
        
        
        
        CAShapeLayer *beaconLayer = [[CAShapeLayer alloc] init];
        [beaconLayer setPath:measureBezierPath.CGPath];
        [beaconLayer setStrokeColor:color.CGColor];
        [beaconLayer setFillColor:[UIColor clearColor].CGColor];
        [[self layer] addSublayer:beaconLayer];
    }
    if ([type isEqualToString:@"heading"]) {
        // Represent a line from the point to the heading direction.
        UIBezierPath *measureBezierPath = [UIBezierPath bezierPath];
        [measureBezierPath moveToPoint:CGPointMake([canvasPosition.x doubleValue], [canvasPosition.y doubleValue])];
        // The device is aiming the reference position, but an other way round representation is required, such as the heading measure is done from the position; a couterphase in y coordinate is needed (minus sign)
        [measureBezierPath addLineToPoint:CGPointMake(
                                                      [canvasPosition.x doubleValue] + (self.frame.size.height/2 - 100.0) * rHeight * sin([measure doubleValue]),
                                                      [canvasPosition.y doubleValue] - (self.frame.size.width/2 - 100.0) * rWidth * cos([measure doubleValue])
                                                      )];
        
        CAShapeLayer *headingLayer = [[CAShapeLayer alloc] init];
        [headingLayer setPath:measureBezierPath.CGPath];
        [headingLayer setStrokeColor:color.CGColor];
        [headingLayer setFillColor:[UIColor clearColor].CGColor];
        [[self layer] addSublayer:headingLayer];
    }
}

#pragma mark - Drawing methods helpers
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
        rWidth = 1.0;
        rHeight = 1.0;
        
    } else {
    
        // Define a safe area
        float widthSafe = canvasWidth * 0.4;
        float heightSafe = canvasHeight * 0.4;
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
        if ( maxX != minX ) { // Division by zero preventing
            rWidth = (widthSafeMax - widthSafeMin)/(maxX - minX);
        } else {
            rWidth = 1.0;
        }
        if ( maxY != minY ) { // Division by zero preventing
            rHeight = (heightSafeMax - heightSafeMin)/(maxY - minY);
        } else {
            rHeight = 1.0;
        }
        
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
        barycenter = [self getBarycenterOf:centeredCanvasPoints];
        // NSLog(@"-> [INFO][CA] transform barycenter %@", barycenter);
        RDPosition * correction = [self subtract:RDcenter from:barycenter];
        for (RDPosition * centeredCanvasPoint in centeredCanvasPoints) {
            RDPosition * correctedCanvasPoint = [self add:centeredCanvasPoint to:correction];
            [canvasPoints addObject:correctedCanvasPoint];
        }
    }
    return canvasPoints;
}

/*!
 @method calculateRatiosOfTransformationFromRealPointsToCanvasPoints:withSafeAreaRatio:
 @discussion This method calculate the ratios needed for showing a set of real points in the canvas; the 'safeAreaRatio' defines a safe area near the canvas' boundaries in wich the points won't be allocated, and it is tipically 0.4, and only the centered 20% of the canvas will allocate the points.
 */
- (void) calculateRatiosOfTransformationFromRealPointsToCanvasPoints:(NSMutableArray *)realPoints
                                                   withSafeAreaRatio:(NSNumber *)safeAreaRatio
{
    // Get the canvas dimensions and its center
    float canvasWidth = self.frame.size.width;
    float canvasHeight = self.frame.size.height;
    RDPosition * RDcenter = [[RDPosition alloc] init];
    RDcenter.x = [[NSNumber alloc] initWithFloat:center.x];
    RDcenter.y = [[NSNumber alloc] initWithFloat:center.y];
    
    // Case only one point
    if (realPoints.count == 1) {
        
        rWidth = 1.0;
        rHeight = 1.0;
        
        barycenter = [[RDPosition alloc] init];
        barycenter.x = [[NSNumber alloc] initWithFloat:0.0];
        barycenter.y = [[NSNumber alloc] initWithFloat:0.0];
        barycenter.z = [[NSNumber alloc] initWithFloat:0.0];
        
    } else {
        
        // Define a safe area
        float widthSafe = canvasWidth * [safeAreaRatio floatValue];
        float heightSafe = canvasHeight * [safeAreaRatio floatValue];
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
        if ( maxX != minX ) { // Division by zero preventing
            rWidth = (widthSafeMax - widthSafeMin)/(maxX - minX);
        } else {
            rWidth = 1.0;
        }
        if ( maxY != minY ) { // Division by zero preventing
            rHeight = (heightSafeMax - heightSafeMin)/(maxY - minY);
        } else {
            rHeight = 1.0;
        }
        
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
        barycenter = [self getBarycenterOf:centeredCanvasPoints];
        // NSLog(@"-> [INFO][CA] caculate ratios barycenter %@", barycenter);
    }
}

/*!
 @method transformSingleRealPointToCanvasPoint:
 @discussion This method transform a 3D RDPosition that represents a physical location to a canvas point; z coordinate is not transformed. The method 'calculateRatiosOfTransformationFromRealPointsToCanvasPoints:withSafeAreaRatio:' must be called before.
 */
- (RDPosition *) transformSingleRealPointToCanvasPoint:(RDPosition *)realPoint
{
    // Get the canvas' center
    RDPosition * RDcenter = [[RDPosition alloc] init];
    RDcenter.x = [[NSNumber alloc] initWithFloat:center.x];
    RDcenter.y = [[NSNumber alloc] initWithFloat:center.y];
        
    // Transform the point's coordinates.
    // The first position is always (0, 0), and it is centered at the origin of the canvas, the upper left corner. Hence, a correction must be done in orther to center the set in the canvas. But as is not intended to display (0, 0) in the center of te canvas, but the barycenter of the set es calculated and translated to the center of the canvas. For this, the 'vector' needed for adding is the subtract of the center of the canvas minus the barycenter.
    
    // Get the proportionate canvas point centered at the orgin of the canvas
    RDPosition * centeredCanvasPoint = [[RDPosition alloc] init];
    centeredCanvasPoint.x = [[NSNumber alloc] initWithFloat:[realPoint.x floatValue] * rWidth];
    centeredCanvasPoint.y = [[NSNumber alloc] initWithFloat:[realPoint.y floatValue] * rHeight];
    centeredCanvasPoint.z = realPoint.z;
    // Correct the points location.
    RDPosition * correction = [self subtract:RDcenter from:barycenter];
    RDPosition * correctedCanvasPoint = [self add:centeredCanvasPoint to:correction];
    //NSLog(@"-> [INFO][CA] RDCenter %@", RDcenter);
    //NSLog(@"-> [INFO][CA] centeredCanvasPoint %@", centeredCanvasPoint);
    //NSLog(@"-> [INFO][CA] correction %@", correction);
    //NSLog(@"-> [INFO][CA] correctedCanvasPoint %@", correctedCanvasPoint);
    //NSLog(@"-> [INFO][CA] barycenter %@", barycenter);
    
    return correctedCanvasPoint;
}


@end
