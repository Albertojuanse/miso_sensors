//
//  SDPrintableMutableArray.m
//  Sensors test
//
//  Created by Alberto J. on 18/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "NSMutableArray+Printable.h"

@implementation NSMutableArray (Printable)

/*!
 @method description
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
-(NSString *)description
{
    NSString * description = @"";
    for (NSMutableDictionary * each in self ) {
        NSString * eachString = [[NSString alloc] initWithFormat:@"%@\n", each];
        description = [description stringByAppendingString:eachString];
    }
    return description;
}

/*!
 @method stringValue
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)stringValue {
    NSLog(@"[HOLA] stringValue called.");
    return [self description];
}

@end

