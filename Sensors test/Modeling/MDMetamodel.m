//
//  MDMetamodel.m
//  Sensors test
//
//  Created by Alberto J. on 22/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "MDMetamodel.h"

@implementation MDMetamodel: NSObject

/*!
 @method init
 @discussion Constructor
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        name = [[NSString alloc] init];
        description = [[NSString alloc] init];
        types = [[NSMutableArray alloc] init];
    }
    return self;
}

/*!
 @method initWithName:andDescription:
 @discussion Constructor
 */
- (instancetype)initWithName:(NSString *)initName
              andDescription:(NSString *)initDescription
{
    self = [self init];
    if (self) {
        name = nil;
        name = initName;
        description = nil;
        description = initDescription;
    }
    return self;
}

/*!
 @method initWithName:description:andTypes:
 @discussion Constructor
 */
- (instancetype)initWithName:(NSString *)initName
                 description:(NSString *)initDescription
                    andTypes:(NSMutableArray*)initTypes
{
    self = [self initWithName:initName andDescription:description];
    if (self) {
        types = nil;
        types = initTypes;
    }
    return self;
}

/*!
 @method initWithCoder:
 @discussion Constructor called when an object must be initiated with the data stored, shared... with a coding way.
 */
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    name = [decoder decodeObjectForKey:@"name"];
    description = [decoder decodeObjectForKey:@"description"];
    types = [decoder decodeObjectForKey:@"types"];
    
    return self;
}

/*!
 @method getName
 @discussion Getter of the 'name' attribute.
 */
- (NSString *)getName {
    return name;
}

/*!
 @method getDescription
 @discussion Getter of the 'description' attribute.
 */
- (NSString *)getDescription {
    return description;
}

/*!
 @method getTypes
 @discussion Getter of the 'types' NSMutableArray object.
 */
- (NSMutableArray *)getTypes {
    return types;
}

/*!
 @method setName
 @discussion Setter of the 'name' attribute.
 */
- (void)setName:(NSString *)givenName {
    name = givenName;
}

/*!
 @method setDescription
 @discussion Setter of the 'name' attribute.
 */
- (void)setDescription:(NSString *)givenDescription {
    description = givenDescription;
}

/*!
 @method setTypes
 @discussion Setter of the 'types' NSMutableArray object.
 */
- (void)setTypes:(NSMutableArray *)givenTypes {
    types = givenTypes;
}

/*!
 @method addType
 @discussion Setter of a new type in NSMutableArray 'type'.
 */
- (void)addType:(MDType *)givenType {
    newType = YES;
    for (MDType * eachType in types) {
        if ([[eachType getName] isEqualToString:[givenType getName]]) {
            newType = NO;
        }
    }
    if (newType) {
        [types addObject:givenType];
    }
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
    return [self isEqualToMDMetamodel:other];
}

/*!
 @method isEqualToMDMetamodel
 @discussion This method compares two MDMetamodel objects.
 */
- (BOOL)isEqualToMDMetamodel:(MDMetamodel *)metamodel {
    if (metamodel == self) {
        return YES;
    }
    if (name != [metamodel getName]) {
        return NO;
    }
    if (description != [metamodel getDescription]) {
        return NO;
    }
    if (![types isEqual:[metamodel getTypes]]) {
        return NO;
    }
    return YES;
}

/*!
 @method encodeWithCoder:
 @discussion This method is called when this object must be coded as a data object for storing, sharing...
 */
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:description forKey:@"description"];
    [encoder encodeObject:types forKey:@"types"];
}

/*!
 @method description
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)description {
    return [NSString stringWithFormat: @"{%@}", name];
}

/*!
 @method stringValue
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)stringValue {
    return [self description];
}

@end
