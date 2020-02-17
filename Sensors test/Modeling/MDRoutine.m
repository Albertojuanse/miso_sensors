//
//  MDRoutine.m
//  Sensors test
//
//  Created by Alberto J. on 22/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "MDRoutine.h"

@implementation MDRoutine: NSObject

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
        modes = [[NSMutableArray alloc] init];
        metamodels = [[NSMutableArray alloc] init];
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
 @method initWithName:description:modes:andMetamodels:
 @discussion Constructor
 */
- (instancetype)initWithName:(NSString *)initName
                 description:(NSString *)initDescription
                       modes:(NSMutableArray *)initModes
               andMetamodels:(NSMutableArray *)initMetamodels
{
    self = [self initWithName:initName andDescription:description];
    if (self) {
        modes = nil;
        modes = initModes;
        metamodels = nil;
        metamodels = initMetamodels;
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
    modes = [decoder decodeObjectForKey:@"modes"];
    metamodels = [decoder decodeObjectForKey:@"metamodels"];
    
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
 @method getModes
 @discussion Getter of the 'modes' NSMutableArray object.
 */
- (NSMutableArray *)getModes {
    return modes;
}

/*!
 @method getMetamodels
 @discussion Getter of the 'metamodels' NSMutableArray object.
 */
- (NSMutableArray *)getMetamodels {
    return metamodels;
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
 @method setModes
 @discussion Setter of the 'modes' NSMutableArray object.
 */
- (void)setModes:(NSMutableArray *)givenModes {
    modes = givenModes;
}

/*!
 @method setMetamodels
 @discussion Setter of the 'metamodels' NSMutableArray object.
 */
- (void)setMetamodels:(NSMutableArray *)givenMetamodels {
    metamodels = givenMetamodels;
}

/*!
 @method addMetamodel
 @discussion Setter of a single metamodel MDMetamodel if is not yet.
 */
- (BOOL)addMetamodel:(MDMetamodel *)givenMetamodel {
    
    BOOL metamodelNew = YES;
    for (MDMetamodel * eachMetamodel in metamodels) {
        if ([eachMetamodel isEqualToMDMetamodel:givenMetamodel]) {
            metamodelNew = NO;
        }
    }
    if (metamodelNew) {
        [metamodels addObject:givenMetamodel];
    }
    return metamodelNew;
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
    return [self isEqualToMDRoutine:other];
}

/*!
 @method isEqualToMDMetamodel
 @discussion This method compares two MDRoutine objects.
 */
- (BOOL)isEqualToMDRoutine:(MDRoutine *)routine {
    if (routine == self) {
        return YES;
    }
    if (name != [routine getName]) {
        return NO;
    }
    if (description != [routine getDescription]) {
        return NO;
    }
    if (![modes isEqual:[routine getModes]]) {
        return NO;
    }
    if (![metamodels isEqual:[routine getMetamodels]]) {
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
    [encoder encodeObject:modes forKey:@"modes"];
    [encoder encodeObject:metamodels forKey:@"metamodels"];
}

/*!
 @method description
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)description {
    return [NSString stringWithFormat: @"%@", name];
}

/*!
 @method stringValue
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)stringValue {
    return [self description];
}

@end
