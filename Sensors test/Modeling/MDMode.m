//
//  MDMode.m
//  Sensors test
//
//  Created by Alberto J. on 17/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "MDMode.h"

@implementation MDMode: NSObject

/*!
 @method init
 @discussion Constructor
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/*!
 @method initWithModeKey:
 @discussion Constructor
 */
- (instancetype)initWithModeKey:(MDModes)initMode
{
    self = [self init];
    if (self) {
        mode = initMode;
        finished = NO;
    }
    return self;
}

#pragma mark - Instance methods
/*!
 @method getMode
 @discussion Getter of the 'mode' attribute.
 */
- (MDModes)getMode {
    return mode;
}

/*!
 @method getMetamodels
 @discussion Getter of the 'metamodels' attribute.
 */
- (NSMutableArray *)getMetamodels
{
    return metamodels;
}

/*!
 @method setMode
 @discussion Setter of the 'mode' attribute.
 */
- (void)setMode:(enum MDModes)givenMode {
    mode = givenMode;
}

/*!
 @method setFinished:
 @discussion Setter of the 'finished' attribute.
 */
- (void)setFinished:(BOOL)givenFinished
{
    finished = givenFinished;
}

/*!
 @method isFinished
 @discussion Getter of the 'finished' attribute.
 */
- (BOOL)isFinished
{
    return finished;
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
    return [self isEqualToMDMode:other];
}

/*!
 @method isEqualToMDMode
 @discussion This method compares two MDReference objects.
 */
- (BOOL)isEqualToMDMode:(MDMode *)reference
{
    if (reference == self) {
        return YES;
    }
    if (mode != [reference getMode]) {
        return NO;
    }
    return YES;
}

/*!
 @method isModeKey
 @discussion This method compares a MDReference object to a MDModes key.
 */
- (BOOL)isModeKey:(MDModes)key
{
    if (mode != key) {
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
    NSString * description;
    switch (mode) {
        case 0:
            description = @"Monitorig";
            break;
        case 1:
            description = @"Locate others using iBeacon";
            break;
        case 2:
            description = @"Locate others using iBeacon and compass";
            break;
        case 3:
            description = @"Locate others using compass";
            break;
        case 4:
            description = @"Self locate using iBeacon";
            break;
        case 5:
            description = @"Self locate using iBeacon and compass";
            break;
        case 6:
            description = @"Self locate using compass";
            break;
        case 7:
            description = @"Self locate using GPS";
            break;
        case 8:
            description = @"Self heading using compass";
            break;
        default:
            description = @"MODE_NAME_NOT_AVALIBLE";
            break;
    }
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

#pragma mark - NSCoding methods
/*!
 @method initWithCoder:
 @discussion Constructor called when an object must be initiated with the data stored, shared... with a coding way.
 */
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    NSNumber * codedMode = [decoder decodeObjectForKey:@"mode"];
    mode = [codedMode intValue];
    return self;
}

/*!
 @method encodeWithCoder:
 @discussion This method is called when this object must be coded as a data object for storing, sharing...
 */
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSNumber numberWithInt:mode] forKey:@"mode"];
}

#pragma mark - NSItemProviderWriting methods
/*!
 @method writableTypeIdentifiersForItemProvider
 @discussion Synthesized getter of property 'writableTypeIdentifiersForItemProvider'.
 */
+ (NSArray<NSString *> *)writableTypeIdentifiersForItemProvider
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
    NSLog(@"[INFO][MDM] An instance of MDMode %@ dragged.", [self description]);
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
    NSLog(@"[INFO][MDM] Asked providerVisibility value.");
    return NSItemProviderRepresentationVisibilityOwnProcess;
}

#pragma mark - NSItemProviderReading methods
/*!
 @method readableTypeIdentifiersForItemProvider
 @discussion Synthesized getter of property 'readableTypeIdentifiersForItemProvider'.
 */
+ (NSArray<NSString *> *)readableTypeIdentifiersForItemProvider
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
    MDMode * mode = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return mode;
}
@end
