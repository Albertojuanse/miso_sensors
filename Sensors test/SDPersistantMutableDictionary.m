//
//  SDPersistantMutableDictionary.m
//  Sensors test
//
//  Created by Alberto J. on 18/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "SDPersistantMutableDictionary.h"

@implementation SDPersistantMutableDictionary

@synthesize title;
@synthesize author;
@synthesize published;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.author = [decoder decodeObjectForKey:@"author"];
        self.published = [decoder decodeBoolForKey:@"published"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:title forKey:@"title"];
    [encoder encodeObject:author forKey:@"author"];
    [encoder encodeBool:published forKey:@"published"];
}

@end
