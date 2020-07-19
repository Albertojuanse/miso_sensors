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
    firstDisplay = YES;
    componentsLoaded = 0;
    scale = 1.0;
    transformToCanvas = CGAffineTransformMake(1, 0, 0, 1, 0, 0); // Identity transform
    barycenter = [[RDPosition alloc] init];
    barycenter.x = [NSNumber numberWithFloat:0.0];
    barycenter.y = [NSNumber numberWithFloat:0.0];
    barycenter.z = [NSNumber numberWithFloat:0.0];
    
    // Canvas configurations
    [self setUserInteractionEnabled:YES];
    [self setBackgroundColor:[VCDrawings getCanvasColor]];
    
    // Gestures
    UIPinchGestureRecognizer * scalingGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(scale:)];
    [scalingGesture setDelegate:self];
    [self addGestureRecognizer:scalingGesture];
    UIPanGestureRecognizer * moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(move:)];
    [self addGestureRecognizer:moveGesture];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(canvasRefresh:)
                                                 name:@"canvas/refresh"
                                               object:nil];

    [self setNeedsDisplay];
}

#pragma mark - Notifications events handlers
/*!
 @method canvasRefresh:
 @discussion This method gets the beacons that must be represented in canvas and ask it to upload; this method is called when someone submits the 'canvas/refresh' notification.
 */
- (void) canvasRefresh:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"canvas/refresh"]){
        NSLog(@"[NOTI][VC] Notification \"canvas/refresh\" recived.");
        [self setNeedsDisplay];
    }
    
}

#pragma mark - Event handlers
/*!
 @method scale:
 @discussion This method gets the gesture parameters and uploads the scaling value; this method is called when user performs a pinch gesture over the canvas.
 */
- (void) scale:(UIPinchGestureRecognizer *)scalingGesture
{
    // Different behaviour depending on the state
    if ([scalingGesture state] == UIGestureRecognizerStateBegan ||
        [scalingGesture state] == UIGestureRecognizerStateChanged)
    {
        // Upload scale dinamically
        CGFloat instantScale = [scalingGesture scale];
        scale = scale * instantScale;
        
        // Upload barycenter dinamically
        UIView * pinchView = scalingGesture.view;
        CGRect bounds = pinchView.bounds;
        CGPoint pinchCenter = [scalingGesture locationInView:pinchView];
        pinchCenter.x -= CGRectGetMidX(bounds);
        pinchCenter.y -= CGRectGetMidY(bounds);
        CGAffineTransform transformBarycenterToPinch = CGAffineTransformMake(1, 0,
                                                                             0, 1,
                                                                             pinchCenter.x, pinchCenter.y);
        CGPoint barycenterPoint = [barycenter toCGPoint];
        CGPoint barycenterInPinchCenter = CGPointApplyAffineTransform(barycenterPoint,
                                                                      transformBarycenterToPinch);
        CGPoint barycenterInPinchCenterScaled = CGPointMake(barycenterInPinchCenter.x * instantScale,
                                                            barycenterInPinchCenter.y * instantScale);
        CGAffineTransform transformPinchToBarycenter = CGAffineTransformInvert(transformBarycenterToPinch);
        CGPoint barycenterScaled = CGPointApplyAffineTransform(barycenterInPinchCenterScaled,
                                                               transformPinchToBarycenter);
        barycenter.x = [NSNumber numberWithFloat:barycenterScaled.x];
        barycenter.y = [NSNumber numberWithFloat:barycenterScaled.y];
    }
    if ([scalingGesture state] == UIGestureRecognizerStateEnded)
    {
        
    }
    // Reset each update as if they where many pinch gestures one after other
    scalingGesture.scale = 1.0;
    [self setNeedsDisplay];
}


/*!
 @method move:
 @discussion This method gets the gesture parameters and uploads the barycenter value; this method is called when user performs a swipe gesture over the canvas.
 */
- (void) move:(UIPanGestureRecognizer *)moveGesture
{
    // Different behaviour depending on the state
    if ([moveGesture state] == UIGestureRecognizerStateBegan ||
        [moveGesture state] == UIGestureRecognizerStateChanged)
    {
        // Upload barycenter dinamically
        CGPoint translation = [moveGesture translationInView:self];
        barycenter.x = [NSNumber numberWithFloat:[barycenter.x floatValue] - translation.x];
        barycenter.y = [NSNumber numberWithFloat:[barycenter.y floatValue] - translation.y];
    }
    if ([moveGesture state] == UIGestureRecognizerStateEnded)
    {
        
    }
    // Reset each update as if they where many pinch gestures one after other
    [moveGesture setTranslation:CGPointMake(0, 0) inView:self];
    [self setNeedsDisplay];
}

#pragma mark - Drawing methods
/*!
 @method drawRect:
 @discussion This method controls the display of a new drawn area; is called when a new draw must be created and displayed.
 */
- (void)drawRect:(CGRect)rect {
    
    // Remove the old layers
    [self removeLayers];
    
    // Inspect shared data for data retrieving
    [self defineTransform];
    [self drawComponentsInRect:rect];
    
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
        NSArray * oldLayers = [NSArray arrayWithArray:self.layer.sublayers];
        for (CALayer * oldLayer in oldLayers) {
            if ([oldLayer isKindOfClass:[CAShapeLayer class]] ||[oldLayer isKindOfClass:[CATextLayer class]] ) {
                [oldLayer removeFromSuperlayer];
            }
            //[oldLayer removeFromSuperlayer];
        }
    }
    if (self.subviews.count > 0) {
        NSArray * oldViews = [NSArray arrayWithArray:self.subviews];
        for (UIView * oldView in oldViews) {
            if ([oldView isKindOfClass:[VCType class]] ||
                [oldView isKindOfClass:[VCComponent class]] ||
                [oldView isKindOfClass:[VCComponentInfo class]] ||
                [oldView isKindOfClass:[VCPosition class]] ||
                [oldView isKindOfClass:[VCCorner class]] ||
                [oldView isKindOfClass:[VCColumn class]] ||
                [oldView isKindOfClass:[VCType class]]
                ) {
                [oldView removeFromSuperview];
            }
            //[oldView removeFromSuperview];
        }
    }
    
    
    NSLog(@"[INFO][CA] Old layers removing; layers displayed: %ld", self.layer.sublayers.count);
}

/*!
 @method defineTransform
 @discussion This method calculate the scale and transform needed to show the real points in the canvas.
 */
- (void) defineTransform
{
    // Canvas must read from the shared data the items to show, and use their real positions to calculate the best transform to show them in the canvas. That way, each item is scaled and trasnlated in the screen to populate it in the best way.
    
    // Get measured, chosen items' and locations' positions and merge them into a single array
    NSMutableArray * itemsPositions = [sharedData fromSessionDataGetPositionsOfItemsChosenByUserDic:credentialsUserDic
                                                                           withCredentialsUserName:credentialsUserDic];
    NSMutableArray * locatedPositions = [sharedData fromItemDataGetPositionsOfLocatedItemsByUser:userDic
                                                                           andCredentialsUserDic:credentialsUserDic];
    NSMutableArray * measurePositions = [sharedData fromMeasuresDataGetPositionsWithCredentialsUserDic:credentialsUserDic];
    NSMutableArray * realPositions = [[NSMutableArray alloc] init];
    for (RDPosition * position in itemsPositions) {
        [realPositions addObject:position];
        NSLog(@"[INFO][CA] Found a real item position %@", position);
    }
    for (RDPosition * position in locatedPositions) {
        [realPositions addObject:position];
        NSLog(@"[INFO][CA] Found a real located position %@", position);
    }
    for (RDPosition * position in measurePositions) {
        [realPositions addObject:position];
        NSLog(@"[INFO][CA] Found a real measure position %@", position);
    }
    
    // The first time that the canvas is compose, an automatic transform is made, but the following ones the user will use zoom and swipe gestures to rearrange the canvas.
    if (firstDisplay || componentsLoaded != [realPositions count]) {
        // Use these positions to calculate the best scaling value and transformation.
        [self scaleToCanvasFromRealPoints:realPositions];
        [self transformToCanvasFromRealPoints:realPositions];
        
        firstDisplay = NO;
    } else {
        // Update the transform since scale is changed by user and screen's center can change
        [self transformToCanvasFromRealPoints:realPositions];
    }
    
    // Keep the track of new elements to show
    componentsLoaded = [realPositions count];
}

/*!
 @method drawComponentsInRect:
 @discussion This method inspects collections in shared data for retrieving the componets and display them.
 */
- (void) drawComponentsInRect:(CGRect)rect
{
    // Get some constants used before
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    NSNumber * infoWidth = layoutDic[@"canvas/info/width"];
    NSNumber * infoHeight = layoutDic[@"canvas/info/height"];
    
    // Inspect the dictionary collections in shared data and get the information to display
    
    //              // ITEMS POSITION //
    // Show the chosen items by the user; the items used for locations like positions or beacons if known.
    // For every item position...
    NSMutableArray * itemsPositions = [sharedData fromSessionDataGetPositionsOfItemsChosenByUserDic:credentialsUserDic
                                                                           withCredentialsUserName:credentialsUserDic];
    for (RDPosition * realItemPosition in itemsPositions) {
        
        // ...get the transformed position...
        CGPoint realItemPoint = [realItemPosition toCGPoint];
        CGPoint canvasItemPoint = CGPointApplyAffineTransform(realItemPoint, transformToCanvas);
        
        RDPosition * canvasItemPosition = [[RDPosition alloc] init];
        canvasItemPosition.x = [NSNumber numberWithFloat:canvasItemPoint.x];
        canvasItemPosition.y = [NSNumber numberWithFloat:canvasItemPoint.y];
        canvasItemPosition.z = realItemPosition.z;
        
        // Not show if the position is out of the bounds
        if (canvasItemPoint.x > [positionWidth floatValue]/2.0  &&
            canvasItemPoint.x < center.x*2 - [infoWidth floatValue] &&
            canvasItemPoint.y > [positionHeight floatValue] &&
            canvasItemPoint.y < center.y*2 - [infoHeight floatValue])
        {
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
                        // TODO: Manage this. Alberto J. 2019/10/1.
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
        
    }
    
    //              // LOCATED POSITION //
    // Show the located positions, the ones located with the radiolocation systems.
    // For every located position...
    NSMutableArray * locatedPositions = [sharedData fromItemDataGetPositionsOfLocatedItemsByUser:userDic
                                                                           andCredentialsUserDic:credentialsUserDic];
    for (RDPosition * realLocatedPosition in locatedPositions) {
        
        // ...get the transformed position...
        CGPoint realLocatedPoint = [realLocatedPosition toCGPoint];
        CGPoint canvasLocatedPoint = CGPointApplyAffineTransform(realLocatedPoint, transformToCanvas);
        
        RDPosition * canvasLocatedPosition = [[RDPosition alloc] init];
        canvasLocatedPosition.x = [NSNumber numberWithFloat:canvasLocatedPoint.x];
        canvasLocatedPosition.y = [NSNumber numberWithFloat:canvasLocatedPoint.y];
        canvasLocatedPosition.z = realLocatedPosition.z;
        
        // Not show if the position is out of the bounds
        if (canvasLocatedPoint.x > [positionWidth floatValue]/2.0  &&
            canvasLocatedPoint.x < center.x*2 - [infoWidth floatValue] &&
            canvasLocatedPoint.y > [positionHeight floatValue] &&
            canvasLocatedPoint.y < center.y*2 - [infoHeight floatValue])
        {
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
                        // TODO: Manage this. Alberto J. 2019/10/1.
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
            CGPoint sourcePoint = [sourcePosition toCGPoint];
            CGPoint canvasSourcePoint = CGPointApplyAffineTransform(sourcePoint, transformToCanvas);
            RDPosition * canvasSourcePosition = [[RDPosition alloc] init];
            canvasSourcePosition.x = [NSNumber numberWithFloat:canvasSourcePoint.x];
            canvasSourcePosition.y = [NSNumber numberWithFloat:canvasSourcePoint.y];
            canvasSourcePosition.z = sourcePosition.z;
            
            CGPoint targetPoint = [targetPosition toCGPoint];
            CGPoint canvasTargetPoint = CGPointApplyAffineTransform(targetPoint, transformToCanvas);
            RDPosition * canvasTargetPosition = [[RDPosition alloc] init];
            canvasTargetPosition.x = [NSNumber numberWithFloat:canvasTargetPoint.x];
            canvasTargetPosition.y = [NSNumber numberWithFloat:canvasTargetPoint.y];
            canvasTargetPosition.z = targetPosition.z;
            
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
    
}

/*!
 @method drawPosition:inCanvasPosition:andUUID
 @discussion This method displays a position in space 'realPosition' using its coordinates in the canvas, 'canvasPosition', given its UUID.
 */
- (void) drawPosition:(RDPosition *)realPosition
     inCanvasPosition:(RDPosition *)canvasPosition
              andUUID:(NSString *)uuid
{
    // Draw the position
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    VCPosition * positionView = [[VCPosition alloc] initWithFrame:CGRectMake([canvasPosition.x floatValue] - [positionWidth floatValue]/2,
                                                                             [canvasPosition.y floatValue] - [positionHeight floatValue],
                                                                             [positionWidth floatValue],
                                                                             [positionHeight floatValue])
                                                     realPosition:realPosition
                                                   canvasPosition:canvasPosition
                                                          andUUID:uuid];
    [self addSubview:positionView];
    
    // Text of real position but in canvas position
    NSNumber * infoWidth = layoutDic[@"canvas/info/width"];
    NSNumber * infoHeight = layoutDic[@"canvas/info/height"];
    VCComponentInfo * positionTextView = [[VCComponentInfo alloc] initWithFrame:CGRectMake([canvasPosition.x floatValue],
                                                                                           [canvasPosition.y floatValue],
                                                                                           [infoWidth floatValue],
                                                                                           [infoHeight floatValue])
                                                                   realPosition:realPosition
                                                                 canvasPosition:canvasPosition
                                                                        andUUID:uuid];
    [self addSubview:positionTextView];
    
    return;
}

/*!
 @method drawPosition:inCanvasPosition:UUID:andWithType:
 @discussion This method displays a position in space 'realPosition' using its coordinates in the canvas, 'canvasPosition', given its UUID and type; this method makes an special draw for types <Corner> and <Column>.
 */
- (void) drawPosition:(RDPosition *)realPosition
     inCanvasPosition:(RDPosition *)canvasPosition
                 UUID:(NSString *)uuid
          andWithType:(MDType *)type
{
    // TODO: maybe this can be done in other way, not hardcoded. Alberto J. 2020/03/23.
    if (
        [@"Corner" isEqualToString:[type getName]] ||
        [@"Column" isEqualToString:[type getName]]
        ) {
        
        if ([@"Corner" isEqualToString:[type getName]]) {
            
            // Draw the corner
            NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
            NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
            NSNumber * cornerWidth = layoutDic[@"canvas/corner/width"];
            NSNumber * cornerHeight = layoutDic[@"canvas/corner/height"];
            VCCorner * cornerView = [[VCCorner alloc] initWithFrame:CGRectMake([canvasPosition.x floatValue] - [cornerWidth floatValue]/2.0,
                                                                               [canvasPosition.y floatValue] - [cornerHeight floatValue]/2.0,
                                                                               [cornerWidth floatValue],
                                                                               [cornerHeight floatValue])
                                                       realPosition:realPosition
                                                     canvasPosition:canvasPosition
                                                            andUUID:uuid];
            [self addSubview:cornerView];
            
        }
        if ([@"Column" isEqualToString:[type getName]]) {
            
            // Draw the column
            NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
            NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
            NSNumber * columnWidth = layoutDic[@"canvas/column/width"];
            NSNumber * columnHeight = layoutDic[@"canvas/column/height"];
            VCColumn * columnView = [[VCColumn alloc] initWithFrame:CGRectMake([canvasPosition.x floatValue] - [columnWidth floatValue]/2.0,
                                                                               [canvasPosition.y floatValue] - [columnHeight floatValue]/2.0,
                                                                               [columnWidth floatValue],
                                                                               [columnHeight floatValue])
                                                       realPosition:realPosition
                                                     canvasPosition:canvasPosition
                                                            andUUID:uuid];
            [self addSubview:columnView];
            
        }
        
    } else{
        // Call the position representation
        [self drawPosition:realPosition inCanvasPosition:canvasPosition andUUID:uuid];
        
        // Draw the type
        // Get its color...
        NSUInteger typeIndex = 0;
        NSMutableArray * types = [sharedData getTypesDataWithCredentialsUserDic:credentialsUserDic];
        for (MDType * eachType in types) {
            typeIndex = typeIndex + 1;
            NSString * eachTypeName = [eachType getName];
            if ([eachTypeName isEqualToString:[type getName]]) {
                break;
            }
        }
        UIColor * color = [self getColorForIndex:typeIndex];
        VCType * typeView = [[VCType alloc] initWithFrame:CGRectMake([canvasPosition.x floatValue] + 5.0,
                                                                     [canvasPosition.y floatValue] - 10.0,
                                                                     400,
                                                                     20)
                                                    color:color
                                                  andName:[type getName]];
        
        
        [self  addSubview:typeView];
    }
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
    NSNumber * desired_distance = [NSNumber numberWithDouble:[distance floatValue] - 0];
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
    if (![@"" isEqualToString:[referenceType getName]]) {
        VCType * typeView = [[VCType alloc] initWithFrame:CGRectMake([middleX floatValue] + 5.0,
                                                                     [middleY floatValue] - 10.0,
                                                                     400,
                                                                     20)
                                                    color:color
                                                  andName:[referenceType getName]];
        [self addSubview:typeView];
    }
    
    return;
}

/*!
 @method getColorForIndex:
 @discussion This method returns a 'UIColor' object given the index in which certain object is found while dictionaries inspection; it provides a feed of different colors.
 */
- (UIColor *) getColorForIndex:(NSInteger)index {
    // Choose a color for each UUID
    UIColor *color;
    switch (index % 8) {
        case 0:
            color = [UIColor colorWithRed:204.0/255.0 green:0.0 blue:0.0 alpha:1.0];
            break;
        case 1:
            color = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:255/255.0 alpha:1.0];
            break;
        case 2:
            color = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:0.0 alpha:1.0];
            break;
        case 3:
            color = [UIColor colorWithRed:0.0 green:204.0/255.0 blue:0.0 alpha:1.0];
            break;
        case 4:
            color = [UIColor colorWithRed:0.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            break;
        case 5:
            color = [UIColor colorWithRed:0.0 green:0.0 blue:204.0/255.0 alpha:1.0];
            break;
        case 6:
            color = [UIColor colorWithRed:102.0/255.0 green:0.0 blue:204.0/255.0 alpha:1.0];
            break;
        case 7:
            color = [UIColor colorWithRed:204.0/255.0 green:0.0 blue:102.0/255.0 alpha:1.0];
            break;
        default:
            color = [UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:255/255.0 alpha:1.0];
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
    CGPoint realPoint = [realPosition toCGPoint];
    CGPoint canvasPoint = CGPointApplyAffineTransform(realPoint, transformToCanvas);
    RDPosition * canvasPosition = [[RDPosition alloc] init];
    canvasPosition.x = [NSNumber numberWithFloat:canvasPoint.x];
    canvasPosition.y = [NSNumber numberWithFloat:canvasPoint.y];
    canvasPosition.z = realPosition.z;
    
    if ([type isEqualToString:@"rssi"]) {
        //UIBezierPath *measureBezierPath = [UIBezierPath bezierPath];
        //[measureBezierPath addArcWithCenter:[canvasPosition toNSPoint] radius:[measure floatValue]*(rWidth+rHeight)/2.0 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        //NSLog(@"[INFO][CA][TRAN] Radius measured: %.2f",  [measure floatValue]);
        //NSLog(@"[INFO][CA][TRAN] Radius canvas: %.2f",  [measure floatValue]*(rWidth+rHeight)/2.0);
        
        
        CGRect rect = CGRectMake([canvasPosition.x floatValue] - [measure floatValue] * scale,
                                 [canvasPosition.y floatValue] - [measure floatValue] * scale,
                                 2.0 * [measure floatValue] * scale,
                                 2.0 * [measure floatValue] * scale);
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
                                                      [canvasPosition.x doubleValue] + (self.frame.size.height/2 - 100.0) * scale * sin([measure doubleValue]),
                                                      [canvasPosition.y doubleValue] - (self.frame.size.width/2 - 100.0) * scale * cos([measure doubleValue])
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
 @method scaleToCanvasFromRealPoints:
 @discussion This method calculate the the scale needed for showing a set of real points in the canvas.
 */
- (void) scaleToCanvasFromRealPoints:(NSMutableArray *)realPoints
{
    // Get the canvas dimensions and its center
    float canvasWidth = self.frame.size.width;
    float canvasHeight = self.frame.size.height;
    center.x = self.frame.size.width/2;
    center.y = self.frame.size.height/2;
    
    // Case only one point
    if (realPoints.count == 1) {
        scale = 1.0;
    } else {
        
        // Get the safe area ratio, which defines a safe area near the canvas' boundaries in wich the points won't be allocated, and it is tipically 0.4, and only the centered 20% of the canvas will allocate the points.
        NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
        NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
        NSNumber * safeAreaRatioSaved = layoutDic[@"canvas/safeAreaRatio"];
        NSNumber * safeAreaRatio = [NSNumber numberWithFloat:[safeAreaRatioSaved floatValue]/100.0];
        
        // Use it to define a safe area
        float widthSafe = canvasWidth * [safeAreaRatio floatValue];
        float heightSafe = canvasHeight * [safeAreaRatio floatValue];
        float safeMinX = 0 + widthSafe;
        float safeMaxX = canvasWidth - widthSafe;
        float safeMinY = 0 + heightSafe;
        float safeMaxY = canvasHeight - heightSafe;
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
        float newWidthRatio;
        float newHeightRatio;
        // Get the relations of the transformation
        if ( maxX != minX ) { // Division by zero preventing
            newWidthRatio = (safeMaxX - safeMinX)/(maxX - minX);
        } else {
            newWidthRatio = 1.0;
        }
        if ( maxY != minY ) { // Division by zero preventing
            newHeightRatio = (safeMaxY - safeMinY)/(maxY - minY);
        } else {
            newHeightRatio = 1.0;
        }
        scale = MIN(newWidthRatio, newHeightRatio); // Minimum is the worse case
    }
    transformToCanvas = CGAffineTransformMake(scale, 0, 0, scale, center.x, center.y);
}

/*!
 @method transformToCanvasFromRealPoints:
 @discussion This method updates the the transform needed for showing a set of real points in the canvas.
 */
- (void) transformToCanvasFromRealPoints:(NSMutableArray *)realPoints
{
    if (firstDisplay) {
        // First, scale the real points to calculate their barycenter
        NSMutableArray * centeredCanvasPoints = [[NSMutableArray alloc] init];
        for (RDPosition * realPoint in realPoints) {
            RDPosition * centeredCanvasPoint = [[RDPosition alloc] init];
            centeredCanvasPoint.x = [[NSNumber alloc] initWithFloat:[realPoint.x floatValue] * scale];
            centeredCanvasPoint.y = [[NSNumber alloc] initWithFloat:[realPoint.y floatValue] * scale];
            centeredCanvasPoint.z = realPoint.z;
            [centeredCanvasPoints addObject:centeredCanvasPoint];
        }
        barycenter = [self getBarycenterOf:centeredCanvasPoints];
        
    }   // Second, define the transform
    RDPosition * centerPosition = [[RDPosition alloc] init];
    centerPosition.x = [[NSNumber alloc] initWithFloat:center.x];
    centerPosition.y = [[NSNumber alloc] initWithFloat:center.y];
    centerPosition.z = barycenter.x;
    RDPosition * barycenterCentered = [self subtract:centerPosition from:barycenter];
    transformToCanvas = CGAffineTransformMake(scale, 0,
                                              0, scale,
                                              [barycenterCentered.x floatValue], [barycenterCentered.y floatValue]);
}

@end
