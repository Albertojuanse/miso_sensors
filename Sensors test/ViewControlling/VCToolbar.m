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
    NSLog(@"[HOLA]");
    // Layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                           green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                            blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                           alpha:1.0
                            ];
    
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
