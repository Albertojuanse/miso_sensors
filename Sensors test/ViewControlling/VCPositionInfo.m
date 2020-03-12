//
//  VCPositionInfo.m
//  Sensors test
//
//  Created by Alberto J. on 12/03/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCPositionInfo.h"

@implementation VCPositionInfo: UIView

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
@method initWithFrame:initRealPosition:andUUID
@discussion Constructor with a given specific frame in which be embedded, real position and UUID identifier.
*/
-(instancetype)initWithFrame:(CGRect)frame
                realPosition:(RDPosition *)initRealPosition
                     andUUID:(NSString *)initUUID
{
    self = [self initWithFrame:frame];
    if (self) {
        realPosition = initRealPosition;
        uuid = initUUID;
    }
    return self;
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
    [positionTextView setTextAlignment:NSTextAlignmentCenter];
    [positionTextView setBackgroundColor:[UIColor clearColor]];
    [positionTextView setTextColor:[UIColor blackColor]];
    [self addSubview:positionTextView];
    
    // Text of UUID in canvas position
    UILabel * uuidTextView = [[UILabel alloc] initWithFrame:CGRectMake(rectOrigin.x,
                                                                       rectOrigin.y + 20.0,
                                                                       rectWidth,
                                                                       rectHeight)
                              ];
    [uuidTextView setText:[NSString stringWithFormat:@"%@", [uuid substringFromIndex:30]]];
    [uuidTextView setFont:[UIFont systemFontOfSize:14]];
    [uuidTextView setTextAlignment:NSTextAlignmentCenter];
    [uuidTextView setBackgroundColor:[UIColor clearColor]];
    [uuidTextView setTextColor:[UIColor blackColor]];
    [self addSubview:uuidTextView];

}


@end
