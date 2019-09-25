//
//  MDType.h
//  Sensors test
//
//  Created by MISO on 25/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>

/*!
 @protocol MDType
 @discussion Abstract definition of any type that can be used for modeling
 */
@protocol MDType

@required
- (instancetype)init;
- (void)setName:(NSString *)givenName;
- (NSString *)getName;
- (void)setAttributes:(NSMutableArray *)givenAttributes;
- (NSMutableArray *)getAttributes;

@optional
- (BOOL)isEqual:(id)object;
- (NSString *)description;
- (NSString *)stringValue;

@end

/*!
 @class MDType
 @discussion Definition of any type that can be used for modeling
 */
@interface MDType: NSObject <MDType> {
    
    NSString * name;
    NSMutableArray * attributes;
    
}

- (instancetype)init;
- (instancetype)initWithName:(NSString *)givenName;
- (instancetype)initWithName:(NSString *)givenName
               andAttributes:(NSMutableArray *)givenAttributes;
- (void)setName:(NSString *)givenName;
- (NSString *)getName;
- (void)setAttributes:(NSMutableArray *)givenAttributes;
- (NSMutableArray *)getAttributes;
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToMDType:(MDType *)type;
- (NSString *)description;

@end
