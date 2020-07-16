//
//  MDAttribute.m
//  Sensors test
//
//  Created by Alberto J. on 4/2/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "MDAttribute.h"

@implementation MDAttribute: NSObject

/*!
 @method init
 @discussion Constructor
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        name = [[NSString alloc] init];
        attribute = nil;
    }
    return self;
}

/*!
 @method initWithName:
 @discussion Constructor
 */
- (instancetype)initWithName:(NSString *)givenName
{
    self = [self init];
    if (self) {
        name = nil;
        name = givenName;
    }
    return self;
}

/*!
 @method initWithName:andAttribute:
 @discussion Constructor
 */
- (instancetype)initWithName:(NSString *)givenName
                andAttribute:(id)givenAttribute
{
    self = [self initWithName:givenName];
    if (self) {
        attribute = nil;
        attribute = givenAttribute;
    }
    return self;
}

#pragma mark - Instance methods
/*!
 @method getName
 @discussion Getter of the 'name' attribute.
 */
- (NSString *)getName
{
    return name;
}

/*!
 @method setName
 @discussion Setter of the 'name' attribute.
 */
- (void)setName:(NSString *)givenName
{
    name = givenName;
}

/*!
 @method getAttribute
 @discussion Getter of the 'attribute' object.
 */
- (NSMutableArray *)getAttribute
{
    return attribute;
}

/*!
 @method setAttribute
 @discussion Setter of the 'attribute' object.
 */
- (void)setAttribute:(id)givenAttribute
{
    attribute = givenAttribute;
}

/*!
 @method isEqual
 @discussion This method overwrites the isEqual super method.
 */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]])
    {
        return NO;
    }
    return [self isEqualToMDAttribute:other];
}

/*!
 @method isEqualToMDAttribute
 @discussion This method compares two MDType objects.
 */
- (BOOL)isEqualToMDAttribute:(MDAttribute *)givenAttribute
{
    if (givenAttribute == self) {
        return YES;
    }
    if (name != [givenAttribute getName]) {
        return NO;
    }
    if (![attribute isEqual:[givenAttribute getAttribute]]) {
        return NO;
    }
    return YES;
}

/*!
 @method description
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)description
{
    if (attribute) {
        return [NSString stringWithFormat: @"%@ = %@", name, attribute];
    } else {
        return [NSString stringWithFormat: @"%@ = ", name];
    }
}

/*!
 @method stringValue
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)stringValue
{
    return [self description];
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
    
    name = [decoder decodeObjectForKey:@"name"];
    attribute = [decoder decodeObjectForKey:@"attribute"];
    
    return self;
}

/*!
 @method encodeWithCoder:
 @discussion This method is called when this object must be coded as a data object for storing, sharing...
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:attribute forKey:@"attribute"];
}

@end
