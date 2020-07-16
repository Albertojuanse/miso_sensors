//
//  VCToolbar.m
//  Sensors test
//
//  Created by Alberto J. on 23/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCToolbar.h"

@implementation VCToolbar

- (void)drawRect:(CGRect)rect
{
    // Layout
    // TODO: This is not working. Alberto J. 2020/01/23.
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.backgroundColor = [VCDrawings getNormalThemeColor];
    
    // Tittle
    float nameLabelWidth = 100.0;
    UILabel * name = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0 - nameLabelWidth/2.0,
                                                               self.frame.origin.y,
                                                               nameLabelWidth,
                                                               self.frame.size.height)];
    name.text = layoutDic[@"general/name"];
    name.font=[UIFont boldSystemFontOfSize:20.0];
    name.textColor=[UIColor blackColor];
    name.backgroundColor=[UIColor clearColor];
    [self addSubview:name];
    
    // Icon
    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0 + nameLabelWidth/2.0+10,
                                                                       self.frame.origin.y+18,
                                                                       (self.frame.size.height)-20.0,
                                                                       (self.frame.size.height*3.0/4.0)-20.0)];
    icon.image = [UIImage imageNamed:@"icon.png"];
    [self addSubview:icon];
    
    [self setNeedsDisplay];
}

@end
