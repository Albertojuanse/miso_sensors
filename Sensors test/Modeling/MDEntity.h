//
//  MDEntity.h
//  Sensors test
//
//  Created by MISO on 25/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>

/*!
 @protocol MDEntity
 @discussion Abstract definition of any entity that can be used for modeling
 */
@protocol MDEntity

@required
- (instancetype)init;
- (void)setName:(NSString*)newName;
- (NSString*)getName;
- (void)setAttributes:(NSMutableArray*)newAttributes;
- (NSMutableArray*)getAttributes;

@optional
- (BOOL)isEqual:(id)object;
- (NSString *)description;

@end

/*!
 @class MDEntity
 @discussion Definition of any entity that can be used for modeling
 */
@interface MDEntity: NSObject <MDEntity> {
    
    NSString * name;
    NSMutableArray * attributes;
    
}

- (instancetype)init;
- (void)setName:(NSString*)newName;
- (NSString*)getName;
- (void)setAttributes:(NSMutableArray*)newAttributes;
- (NSMutableArray*)getAttributes;
- (BOOL)isEqual:(id)object;
- (NSString *)description;

@end
