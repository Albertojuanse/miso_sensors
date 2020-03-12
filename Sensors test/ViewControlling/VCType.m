//
//  VCType.m
//  Sensors test
//
//  Created by Alberto J. on 1/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "VCType.h"

@implementation VCType: UIView

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
 @method initWithFrame:
 @discussion Constructor with a given specific frame in which be embedded.
 */
-(instancetype)initWithFrame:(CGRect)frame
                       color:(UIColor *)initColor
                     andName:(NSString *)initName
{
    self = [self initWithFrame:frame];
    if (self) {
        color = initColor;
        name = initName;
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
    
    // Draw the point
    UILabel * typeTextView = [[UILabel alloc] initWithFrame:rect];
    [typeTextView setText:[NSString stringWithFormat:@"<%@>", name]];
    [typeTextView setFont:[UIFont systemFontOfSize:16]];
    [typeTextView setTextAlignment:NSTextAlignmentCenter];
    [typeTextView setBackgroundColor:[UIColor clearColor]];
    [typeTextView setTextColor:color];
    [self addSubview:typeTextView];
}


@end

