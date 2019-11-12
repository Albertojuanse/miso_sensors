//
//  MDReference.m
//  Sensors test
//
//  Created by Alberto J. on 31/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "MDReference.h"

@implementation MDReference: NSObject

/*!
 @method init
 @discussion Constructor
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        type = [[MDType alloc] init];
        sourceItemId = [[NSString alloc] init];
        targetItemId = [[NSString alloc] init];
    }
    return self;
}

/*!
 @method initWithType:andSourceItemId:
 @discussion Constructor
 */
- (instancetype)initWithType:(MDType *)initType
             andSourceItemId:(NSString*)initSourceItemId
{
    self = [self init];
    if (self) {
        type = nil;
        type = initType;
        sourceItemId = nil;
        sourceItemId = initSourceItemId;
    }
    return self;
}

/*!
 @method initWithType:sourceItemId:andTargetItemId:
 @discussion Constructor
 */
- (instancetype)initWithType:(MDType *)initType
                sourceItemId:(NSString*)initSourceItemId
             andTargetItemId:(NSString*)initTargetItemId
{
    self = [self initWithType:initType andSourceItemId:initSourceItemId];
    if (self) {
        targetItemId = nil;
        targetItemId  = initTargetItemId;
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
    sourceItemId = [decoder decodeObjectForKey:@"sourceItemId"];
    targetItemId = [decoder decodeObjectForKey:@"targetItemId"];
    type = [decoder decodeObjectForKey:@"type"];
    
    return self;
}

/*!
 @method getType
 @discussion Getter of the 'type' attribute.
 */
- (MDType *)getType {
    return type;
}

/*!
 @method setType
 @discussion Setter of the 'type' attribute.
 */
- (void)setType:(MDType *)givenType {
    type = givenType;
}

/*!
 @method setSourceItemId:
 @discussion Setter of the 'sourceItemId' NSString object.
 */
- (void)setSourceItemId:(NSString *)givenId
{
    sourceItemId = nil;
    sourceItemId = givenId;
}

/*!
 @method getSourceItemId:
 @discussion Getter of the 'sourceItem:' NSString object.
 */
- (NSString *)getSourceItemId
{
    return sourceItemId;
}

/*!
 @method setTargetItemId:
 @discussion Setter of the 'targetItemId' NSString object.
 */
- (void)setTargetItemId:(NSString *)givenId
{
    targetItemId = nil;
    targetItemId = givenId;
}

/*!
 @method getTargetItemId:
 @discussion Getter of the 'targetItemId' NSString object.
 */
- (NSString *)getTargetItemId
{
    return targetItemId;
}

/*!
 @method isEqual
 @discussion This method overwrites the isEqual super method.
 */
- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToMDReference:other];
}

/*!
 @method isEqualToMDType
 @discussion This method compares two MDReference objects.
 */
- (BOOL)isEqualToMDReference:(MDReference *)reference
{
    if (reference == self) {
        return YES;
    }
    if (![type isEqualToMDType:[reference getType]]) {
        return NO;
    }
    if (![sourceItemId isEqualToString:[reference getSourceItemId]]) {
        return NO;
    }
    if (![targetItemId isEqualToString:[reference getTargetItemId]]) {
        return NO;
    }
    return YES;
}

/*!
 @method encodeWithCoder:
 @discussion This method is called when this object must be coded as a data object for storing, sharing...
 */
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:sourceItemId forKey:@"sourceItemId"];
    [encoder encodeObject:targetItemId forKey:@"targetItemId"];
    [encoder encodeObject:type forKey:@"type"];
}

/*!
 @method description
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)description
{
    NSString * description = @"";
    description = [description stringByAppendingString:sourceItemId];
    description = [description stringByAppendingString:@" -> "];
    NSString * typeString = [[NSString alloc] initWithFormat:@"%@", type];
    description = [description stringByAppendingString:typeString];
    description = [description stringByAppendingString:@" -> "];
    description = [description stringByAppendingString:targetItemId];
    return description;
}

/*!
 @method stringValue
 @discussion This method creates an NSString object for showing and loggin purposes; equivalent to 'toString()'.
 */
- (NSString *)stringValue
{
    return [self description];
}


@end
