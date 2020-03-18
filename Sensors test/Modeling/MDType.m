//
//  MDType.m
//  Sensors test
//
//  Created by Alberto J. on 26/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//  TODO: MDMetamodel for save more than one

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
@method setIcon
@discussion Setter of the 'icon' UIImage object.
*/
- (void)setIcon:(UIImage *)givenIcon
{
    icon = givenIcon;
}

/*!
@method getIcon
@discussion Getter of the 'icon' UIImage object.
*/
- (UIImage *)getIcon
{
    return icon;
}

/*!
@method isIcon
@discussion Asker of the 'icon' UIImage object.
*/
- (BOOL)isIcon
{
    if (icon) {
        return YES;
    } else {
        return NO;
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
/*!
 @method writableTypeIdentifiersForItemProvider
 @discussion Synthesized getter of property 'writableTypeIdentifiersForItemProvider'.
 */
+ (NSArray<NSString *> * _Nullable)writableTypeIdentifiersForItemProvider
{
    NSString* identifier = NSStringFromClass(self.class);
    return @[identifier];
}

/*!
 @method loadDataWithTypeIdentifier:forItemProviderCompletionHandler:
 @discussion This method is called when an instance of this object is dragged in a view to create a NSData data object of it.
 */
- (NSProgress *)loadDataWithTypeIdentifier:(NSString *)typeIdentifier
          forItemProviderCompletionHandler:(void (^)(NSData *data, NSError *error))completionHandler
{
    NSLog(@"[INFO][MDT] An instance of MDType %@ dragged.", [self description]);
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    completionHandler(data, nil);
    return nil;
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
/*!
 @method readableTypeIdentifiersForItemProvider
 @discussion Synthesized getter of property 'readableTypeIdentifiersForItemProvider'.
 */
+ (NSArray<NSString *> * _Nullable)readableTypeIdentifiersForItemProvider
{
    NSString* identifier = NSStringFromClass(self.class);
    return @[identifier];
}

/*!
 @method objectWithItemProviderData:typeIdentifier:error:
 @discussion This method is called when a NSData data object is dropped in a view to create an instance of this object with it.
 */
+ (nullable instancetype)objectWithItemProviderData:(nonnull NSData *)data
                                     typeIdentifier:(nonnull NSString *)typeIdentifier
                                              error:(NSError * _Nullable __autoreleasing * _Nullable)outError
{
    MDType * type = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return type;
}
@end
