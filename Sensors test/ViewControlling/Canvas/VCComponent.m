//
//  VCComponent.m
//  Sensors test
//
//  Created by Alberto J. on 17/9/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "VCComponent.h"

@implementation VCComponent: UIView

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
                                                                       action:@selector(handleTapOnView:)];
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handleDoubleTapOnView:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [doubleTapGestureRecognizer setNumberOfTouchesRequired:1];
        doubleTapGestureRecognizer.delegate = self;
        //[tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        [self setUserInteractionEnabled:YES];
        
        // Gestures for drag and drop
        UIDragInteraction * dragInteraction = [[UIDragInteraction alloc] initWithDelegate:self];
        [self addInteraction:dragInteraction];
        [dragInteraction setEnabled:YES];
        UIDropInteraction * dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
        [self addInteraction:dropInteraction];
        
    }
    return self;
}

/*!
@method initWithFrame:realPosition:canvasPosition:andUUID
@discussion Constructor with a given specific frame in which be embedded, real position and UUID identifier.
*/
-(instancetype)initWithFrame:(CGRect)frame
                realPosition:(RDPosition *)initRealPosition
              canvasPosition:(RDPosition *)initCanvasPosition
                     andUUID:(NSString *)initUUID
{
    self = [self initWithFrame:frame];
    if (self) {
        realPosition = initRealPosition;
        canvasPosition = initCanvasPosition;
        uuid = initUUID;
    }
    return self;
}

#pragma mark - Instance methods
/*!
 @method getRealPosition
 @discussion Getter of the 'realPosition' attribute.
 */
- (RDPosition *)getRealPosition
{
    return realPosition;
}

/*!
 @method setRealPosition
 @discussion Setter of the 'realPosition' attribute.
 */
- (void)setRealPosition:(RDPosition *)givenRealPosition
{
    realPosition = givenRealPosition;
    
}

/*!
 @method getCanvasPosition
 @discussion Getter of the 'canvasPosition' attribute.
 */
- (RDPosition *)getCanvasPosition
{
    return canvasPosition;
}

/*!
 @method setCanvasPosition
 @discussion Setter of the 'canvasPosition' attribute.
 */
- (void)setCanvasPosition:(RDPosition *)givenCanvasPosition
{
    canvasPosition = givenCanvasPosition;
    
}

/*!
 @method getUUID
 @discussion Getter of the 'uuid' attribute.
 */
- (NSString *)getUUID
{
    return uuid;
}

/*!
 @method setUUID
 @discussion Setter of the 'uuid' attribute.
 */
- (void)setUUID:(NSString *)givenUUID
{
    uuid = givenUUID;
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
    
    // Draw the path
    UIBezierPath * componentBezierPath = [UIBezierPath bezierPath];
    [componentBezierPath moveToPoint:rectOrigin];
    [componentBezierPath addLineToPoint:CGPointMake(rectOrigin.x, rectOrigin.y + rectWidth)];
    [componentBezierPath addLineToPoint:CGPointMake(rectOrigin.x + rectHeight, rectOrigin.y + rectWidth)];
    [componentBezierPath addLineToPoint:CGPointMake(rectOrigin.x + rectHeight, rectOrigin.y)];
    [componentBezierPath addLineToPoint:rectOrigin];
    [componentBezierPath moveToPoint:rectOrigin];
    [componentBezierPath addLineToPoint:CGPointMake(rectOrigin.x + rectHeight, rectOrigin.y + rectWidth)];
    [componentBezierPath moveToPoint:CGPointMake(rectOrigin.x, rectOrigin.y + rectWidth)];
    [componentBezierPath addLineToPoint:CGPointMake(rectOrigin.x + rectHeight, rectOrigin.y)];
    CAShapeLayer * componentLayer = [[CAShapeLayer alloc] init];
    [componentLayer setPath:componentBezierPath.CGPath];
    [componentLayer setStrokeColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [componentLayer setFillColor:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [[self layer] addSublayer:componentLayer];

}

#pragma mark - Handle gestures methods
/*!
 @method handleTapOnView:
 @discussion This method handles the tap gesture and asks the view to present the edit component pop up view.
 */
-(void)handleTapOnView:(UITapGestureRecognizer *)recog
{
    // When user taps this view, the edit component view must be presented
    // And send the notification
    [UIView animateWithDuration:0.1
                          delay:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        CGRect oldRect = [self frame];
        CGRect newRect = CGRectMake(oldRect.origin.x,
                                    oldRect.origin.y - 20,
                                    oldRect.size.width,
                                    oldRect.size.height);
        [self setFrame:newRect];
    }
                     completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.15 animations:^{
                CGRect oldRect = [self frame];
                CGRect newRect = CGRectMake(oldRect.origin.x,
                                            oldRect.origin.y + 20,
                                            oldRect.size.width,
                                            oldRect.size.height);
                [self setFrame:newRect];
            }];
        }
    }
     ];
    
    NSLog(@"[INFO][VCC] User did tap on the view %@", uuid);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vcEditing/chooseItem"
                                                        object:self
                                                      userInfo:nil];
    NSLog(@"[NOTI][VCC]  Notification \"vcEditing/chooseItem\" posted.");
}

/*!
 @method handleDoubleTapOnView:
 @discussion This method handles the double tap gesture and asks the view to present the edit component pop up view.
 */
-(void)handleDoubleTapOnView:(UITapGestureRecognizer *)recog
{
    // When user taps this view, the edit component view must be presented
    // And send the notification
    NSLog(@"[INFO][VCC] User did double tap on the view %@", uuid);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vcEditing/presentEditComponentView"
                                                        object:self
                                                      userInfo:nil];
    NSLog(@"[NOTI][VCC] Notification \"vcEditing/presentEditComponentView\" posted.");
}

#pragma mark - NSItemProviderWriting methods
/*!
 @method writableTypeIdentifiersForItemProvider
 @discussion Synthesized getter of property 'writableTypeIdentifiersForItemProvider'.
 */
+ (NSArray<NSString *> *)writableTypeIdentifiersForItemProvider
{
    NSString* identifier = NSStringFromClass(self.class);
    return @[identifier];
}

/*!
 @method loadDataWithTypeIdentifier:forItemProviderCompletionHandler:
 @discussion This method is called when an instance of this object is dragged in a view to create a NSData data object of it.
 */
- (NSProgress *)loadDataWithTypeIdentifier:(NSString *)typeIdentifier
          forItemProviderCompletionHandler:(void (^)(NSData *data, NSError *error))completionHandler
{
    NSLog(@"[INFO][MDT] An instance of MDType %@ dragged.", uuid);
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    completionHandler(data, nil);
    return nil;
}

/*!
 @method itemProviderVisibilityForRepresentationWithTypeIdentifier:
 @discussion This method is called when this object is dragged or dropped in view.
 */
+ (NSItemProviderRepresentationVisibility)itemProviderVisibilityForRepresentationWithTypeIdentifier:(NSString *)typeIdentifier
{
    NSLog(@"[INFO][MDT] Asked providerVisibility value.");
    return NSItemProviderRepresentationVisibilityOwnProcess;
}

#pragma mark - NSCoding methods
/*!
 @method initWithCoder:
 @discussion Constructor called when an object must be initiated with the data stored, shared... with a coding way.
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // Decode the attributes
    realPosition = [decoder decodeObjectForKey:@"realPosition"];
    canvasPosition = [decoder decodeObjectForKey:@"canvasPosition"];
    uuid = [decoder decodeObjectForKey:@"uuid"];
    
    return self;
}

/*!
 @method encodeWithCoder:
 @discussion This method is called when this object must be coded as a data object for storing, sharing...
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:realPosition forKey:@"realPosition"];
    [encoder encodeObject:canvasPosition forKey:@"canvasPosition"];
    [encoder encodeObject:uuid forKey:@"uuid"];
}

#pragma mark - NSItemProviderReading methods
/*!
 @method readableTypeIdentifiersForItemProvider
 @discussion Synthesized getter of property 'readableTypeIdentifiersForItemProvider'.
 */
+ (NSArray<NSString *> *)readableTypeIdentifiersForItemProvider
{
    NSString* identifier = NSStringFromClass(self.class);
    return @[identifier];
}

/*!
 @method objectWithItemProviderData:typeIdentifier:error:
 @discussion This method is called when a NSData data object is dropped in a view to create an instance of this object with it.
 */
+ (nullable instancetype)objectWithItemProviderData:(nonnull NSData *)data
                                     typeIdentifier:(nonnull NSString *)typeIdentifier
                                              error:(NSError * _Nullable __autoreleasing * _Nullable)outError
{
    VCComponent * position = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return position;
}

#pragma mark - Drag and drop delegate methods
/*!
 @method dragInteraction:itemsForBeginningSession:
 @discussion Handles drag and drop gestures of views; returns the initial set of items for a drag and drop session.
 */
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction
                  itemsForBeginningSession:(id<UIDragSession>)session
{
    NSLog(@"[INFO][VCC] User did try to start drag and drop of %@.", uuid);
    
    // Return the array with the initial set of items to drag
    NSItemProvider * selfItemProvider = [[NSItemProvider alloc] initWithObject:self];
    UIDragItem * typeDragItem = [[UIDragItem alloc] initWithItemProvider:selfItemProvider];
    NSLog(@"[INFO][VCC] User did start drag and drop; item %@ provided.", uuid);
    return [[NSArray alloc] initWithObjects:typeDragItem,nil];
}

/*!
 @method dropInteraction:canHandleSession:
 @discussion Handles drag and drop gestures of views; cheks if the destination table can handle a drag and drop session.
 */
- (BOOL)dropInteraction:(UIDropInteraction *)interaction
       canHandleSession:(id<UIDropSession>)session
{
    // This table can only handle drops of VCComponent classes.
    if (session.items.count == 1) {
        //if([session hasItemsConformingToTypeIdentifiers:[VCComponent readableTypeIdentifiersForItemProvider]]) {
            NSLog(@"[INFO][VCC] Allowed to drop provided item in this VCComponent view.");
            return YES;
        //} else {
        //    NSLog(@"[INFO][VCC] Only VCComponent class intances can be dropped in this VCComponent view.");
        //    return NO;
        //}
    } else {
        NSLog(@"[INFO][VCC] Only one provided item can be dropped in this VCComponent view.");
        return NO;
    }
}

/*!
 @method dropInteraction:sessionDidUpdate:
 @discussion Handles drag and drop gestures of views; propose how the destination view handles a drag and drop session.
 */
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction
                   sessionDidUpdate:(id<UIDropSession>)session
{
    NSLog(@"[INFO][VCC] User wants to drop in VCComponent view %@", uuid);
    
    UIDropProposal * proposal;
                
    // This table can only handle drops of VCComponent classes.
    if (session.items.count == 1) {
        
        proposal = [[UIDropProposal alloc] initWithDropOperation:UIDropOperationCopy];
    } else {
        return nil;
    }
    return proposal;
}

/*!
 @method dropInteraction:performDrop:
 @discussion Handles drag and drop gestures of views; handles the drop of the dragged items' collection.
 */
- (void)dropInteraction:(UIDropInteraction *)interaction
            performDrop:(id<UIDropSession>)session
{
    NSLog(@"[INFO][VCC] User did droppped in the VCComponent view %@.", uuid);

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
    NSLog(@"[INFO][VCC] Droppped provided item being copied.");
    
    // Load every class that can be dropped: VCComponent, VCCorner, VCPosition
    [session loadObjectsOfClass:VCComponent.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * objects) {
        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // The object dropped is the VCComponent dragged
            VCComponent * droppedVCComponent = object;
            NSLog(@"[INFO][VCC] Droppped and copied a VCComponent %@ item.", [droppedVCComponent getUUID]);
            
            // Ask to create the reference
            NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
            dataDic[@"sourceView"] = self;
            dataDic[@"targetView"] = droppedVCComponent;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"vcEditing/createReference"
                                                                object:nil
                                                              userInfo:dataDic];
            NSLog(@"[NOTI][VCC] Notification \"vcEditing/createReference\" posted.");
        }
         ];
    }
     ];
}

@end
