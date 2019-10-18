//
//  SDPrintableMutableArray.m
//  Sensors test
//
//  Created by Alberto J. on 18/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "SDPrintableMutableArray.h"

@implementation NSMutableArray (SDPrintableMutableArray)

-(NSString *)description
{
    NSString * description = @"";
    for (id each in self) {
        [description stringByAppendingString:[NSString stringWithFormat:@"%@\n", each]];
    }
    return description;
}

@end

