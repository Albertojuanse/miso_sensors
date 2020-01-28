//
//  MDMetamodel.h
//  Sensors test
//
//  Created by Alberto J. on 22/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#include "MDType.h"

/*!
 @class MDMetamodel
 @discussion Definition of any type that can be used for modeling
 */
@interface MDMetamodel: NSObject <NSCoding> {
    
    NSString * name;
    NSString * description;
    NSMutableArray * types;
    
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
- (void)addType:(MDType *)givenType;
- (NSString *)getName;
- (NSString *)getDescription;
- (NSMutableArray *)getTypes;
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToMDMetamodel:(MDMetamodel *)type;
- (NSString *)description;

@end
