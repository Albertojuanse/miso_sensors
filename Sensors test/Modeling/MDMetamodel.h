//
//  MDMetamodel.h
//  Sensors test
//
//  Created by Alberto J. on 22/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#include "MDType.h"
#include "MDMode.h"

/*!
 @class MDMetamodel
 @discussion Definition of any type that can be used for modeling
 */
@interface MDMetamodel: NSObject <NSCoding> {
    
    NSString * name;
    NSString * description;
    NSMutableArray * types;
    NSMutableArray * modes;  // modes that use this metamodel
    
}

- (instancetype)init;
- (instancetype)initWithName:(NSString *)initName
              andDescription:(NSString *)initDescription;
- (instancetype)initWithName:(NSString *)initName
                 description:(NSString *)initDescription
                    andTypes:(NSMutableArray*)initTypes;
- (void)setName:(NSString *)givenName;
- (void)setDescription:(NSString *)givenDescription;
- (void)setTypes:(NSMutableArray *)givenTypes;
- (BOOL)addType:(MDType *)givenType;
- (void)setModes:(NSMutableArray *)givenModes;
- (BOOL)addModeKey:(MDModes)givenModeKey;
- (NSInteger)removeType:(MDType *)givenType;
- (NSInteger)removeTypeWithName:(NSString *)givenName;
- (NSInteger)removeModeKey:(MDModes)givenModeKey;
- (NSString *)getName;
- (NSString *)getDescription;
- (NSMutableArray *)getTypes;
- (NSMutableArray *)getModes;
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToMDMetamodel:(MDMetamodel *)type;
- (NSString *)description;

@end
