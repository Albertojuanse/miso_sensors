//
//  Entity.m
//  Sensors test
//
//  Created by MISO on 26/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "Entity.h"

@implementation Entity: NSObject

/*!
 @method init
 @discussion Constructor
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        name = [[NSString alloc] init];
        attributes = [[NSMutableArray alloc] init];
    }
    return self;
}

/*!
 @method getName
 @discussion Getter of the 'name' attribute.
 */
- (NSString*)getName {
    return name;
}

/*!
 @method setName
 @discussion Setter of the 'name' attribute.
 */
- (void)setName:(NSString*)newName {
    name = newName;
}

/*!
 @method getAttributes
 @discussion Getter of the 'attributes' NSMutableArray object.
 */
- (NSMutableArray*)getAttributes {
    return attributes;
}

/*!
 @method setAttributes
 @discussion Setter of the 'attributes' NSMutableArray object.
 */
- (void)setAttributes:(NSMutableArray*)newAttributes {
    attributes = newAttributes;
}

/*!
  @method isEqual
  @discussion This method overwrites the isEqual super method.
  */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToEntity:other];
}

/*!
 @method isEqualToRDPosition
 @discussion This method compares two RDPosition objects.
 */
- (BOOL)isEqualToEntity:(Entity *)entity {
    if (entity == self) {
        return YES;
    }
    if (name != [entity getName]) {
        return NO;
    }
    if (![attributes isEqual:[entity getAttributes]]) {
        return NO;
    }
    return YES;
}

/*!
 @method description
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)description {
    return [NSString stringWithFormat: @"<%@>", name];
}

@end
