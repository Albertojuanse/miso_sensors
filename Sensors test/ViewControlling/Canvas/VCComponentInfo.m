//
//  VCComponentInfo.m
//  Sensors test
//
//  Created by Alberto J. on 12/03/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCComponentInfo.h"

@implementation VCComponentInfo: UIView

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
    
    // Text of real position but in canvas position
    UILabel * positionTextView = [[UILabel alloc] initWithFrame:CGRectMake(rectOrigin.x,
                                                                           rectOrigin.y + 5.0,
                                                                           rectWidth,
                                                                           rectHeight)
                                  ];
    [positionTextView setText:[NSString stringWithFormat:@"(%.2f, %.2f)", [realPosition.x floatValue], [realPosition.y floatValue]]];
    [positionTextView setFont:[UIFont systemFontOfSize:14]];
    [positionTextView setTextAlignment:NSTextAlignmentLeft];
    [positionTextView setBackgroundColor:[UIColor clearColor]];
    [positionTextView setTextColor:[UIColor blackColor]];
    [self addSubview:positionTextView];
    
    // Text of UUID in canvas position
    if (uuid) { // can be nil
        UILabel * uuidTextView = [[UILabel alloc] initWithFrame:CGRectMake(rectOrigin.x,
                                                                           rectOrigin.y + 20.0,
                                                                           rectWidth,
                                                                           rectHeight)
                                  ];
        [uuidTextView setText:[NSString stringWithFormat:@"%@", [uuid substringFromIndex:30]]];
        [uuidTextView setFont:[UIFont systemFontOfSize:14]];
        [uuidTextView setTextAlignment:NSTextAlignmentLeft];
        [uuidTextView setBackgroundColor:[UIColor clearColor]];
        [uuidTextView setTextColor:[UIColor blackColor]];
        [self addSubview:uuidTextView];
    }

}


@end
