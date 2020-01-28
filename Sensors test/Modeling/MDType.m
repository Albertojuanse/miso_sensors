//
//  MDType.m
//  Sensors test
//
//  Created by Alberto J. on 26/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//  TO DO: MDMetamodel for save more than one

#import "MDType.h"

@implementation MDType: NSObject

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
 @method initWithName:andAttributes:
 @discussion Constructor
 */
- (instancetype)initWithName:(NSString *)givenName
               andAttributes:(NSMutableArray *)givenAttributes
{
    self = [self initWithName:givenName];
    if (self) {
        attributes = nil;
        attributes = givenAttributes;
    }
    return self;
}

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
 @method getAttributes
 @discussion Getter of the 'attributes' NSMutableArray object.
 */
- (NSMutableArray *)getAttributes
{
    return attributes;
}

/*!
 @method setAttributes
 @discussion Setter of the 'attributes' NSMutableArray object.
 */
- (void)setAttributes:(NSMutableArray *)givenAttributes
{
    attributes = givenAttributes;
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
    return [self isEqualToMDType:other];
}

/*!
 @method isEqualToMDType
 @discussion This method compares two MDType objects.
 */
- (BOOL)isEqualToMDType:(MDType *)type
{
    if (type == self) {
        return YES;
    }
    if (name != [type getName]) {
        return NO;
    }
    if (![attributes isEqual:[type getAttributes]]) {
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
    return [NSString stringWithFormat: @"<%@>", name];
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
    attributes = [decoder decodeObjectForKey:@"attributes"];
    
    return self;
}

/*!
 @method encodeWithCoder:
 @discussion This method is called when this object must be coded as a data object for storing, sharing...
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:attributes forKey:@"attributes"];
}

#pragma mark - NSItemProviderWriting methods

+ (NSArray<NSString *> * _Nullable)writableTypeIdentifiersForItemProvider {
    return @[@"es.uam.miso.mdtype"];
}

/*!
 @method loadDataWithTypeIdentifier:forItemProviderCompletionHandler:
 @discussion This method is called when this object is dragged or dropped in view.
 */
- (NSProgress *)loadDataWithTypeIdentifier:(NSString *)typeIdentifier
          forItemProviderCompletionHandler:(void (^)(NSData *data, NSError *error))completionHandler
{
    NSLog(@"[INFO][MDT] Asked current progress.");
    return [NSProgress currentProgress];
}

/*!
 @method itemProviderVisibilityForRepresentationWithTypeIdentifier:
 @discussion This method is called when this object is dragged or dropped in view.
 */
+ (NSItemProviderRepresentationVisibility)itemProviderVisibilityForRepresentationWithTypeIdentifier:(NSString *)typeIdentifier
{
    NSLog(@"[INFO][MDT] Asked providerVisibility value.");
    return NSItemProviderRepresentationVisibilityOwnProcess;
}

#pragma mark - NSItemProviderReading methods

+ (NSArray<NSString *> * _Nullable)readableTypeIdentifiersForItemProvider {
    return @[@"es.uam.miso.mdtype"];
}

/*!
 @method objectWithItemProviderData:typeIdentifier:error:
 @discussion This method is called when this object is dragged or dropped in view.
 */
+ (instancetype)objectWithItemProviderData:(NSData *)data
                            typeIdentifier:(NSString *)typeIdentifier
                                     error:(NSError * _Nullable *)outError
{
    return self;
}

@end
