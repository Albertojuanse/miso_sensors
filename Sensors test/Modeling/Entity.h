//
//  Entity.h
//  Sensors test
//
//  Created by MISO on 25/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>

/*!
 @protocol Entity
 @discussion Abstract definition of any entity that can be used for modeling
 */
@protocol Entity

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
 @class Entity
 @discussion Definition of any entity that can be used for modeling
 */
@interface Entity: NSObject <Entity> {
    
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
