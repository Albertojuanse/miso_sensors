//
//  MDReference.h
//  Sensors test
//
//  Created by Alberto J. on 31/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "MDType.h"

/*!
 @protocol MDReference
 @discussion Abstract definition of any reference from an item to another that can be used for modeling
 */
@protocol MDReference

@required
- (instancetype)init;
- (void)setSourceItemId:(NSString *)givenId;
- (NSString *)getSourceItemId;
- (void)setTargetItemId:(NSString *)givenId;
- (NSString *)getTargetItemId;
- (void)setType:(MDType *)givenType;
- (MDType *)getType;

@optional
- (BOOL)isEqual:(id)object;
- (NSString *)description;
- (NSString *)stringValue;

@end

/*!
 @class MDReference
 @discussion Definition of any reference from an item to another that can be used for modeling
 */
@interface MDReference: NSObject <MDReference, NSCoding> {
    
    NSString * sourceItemId;
    NSString * targetItemId;
    MDType * type;
    
}

- (instancetype)init;
- (instancetype)initWithType:(MDType *)initType
             andSourceItemId:(NSString*)initSourceItemId;
- (instancetype)initWithType:(MDType *)initType
                sourceItemId:(NSString*)initSourceItemId
             andTargetItemId:(NSString*)initTargetItemId;
- (void)setSourceItemId:(NSString *)givenId;
- (NSString *)getSourceItemId;
- (void)setTargetItemId:(NSString *)givenId;
- (NSString *)getTargetItemId;
- (void)setType:(MDType *)givenType;
- (MDType *)getType;
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToMDReference:(MDReference *)reference;
- (NSString *)description;

@end
