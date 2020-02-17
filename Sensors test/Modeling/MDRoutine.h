//
//  MDRoutine.h
//  Sensors test
//
//  Created by Alberto J. on 22/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "MDType.h"
#import "MDMetamodel.h"

/*!
 @class MDRoutine
 @discussion A set of working modes and the metamodels used.
 */
@interface MDRoutine: NSObject <NSCoding> {
    NSString * name;
    NSString * description;
    NSMutableArray * modes;
    NSMutableArray * metamodels;
    
}

- (instancetype)init;
- (instancetype)initWithName:(NSString *)initName
              andDescription:(NSString *)initDescription;
- (instancetype)initWithName:(NSString *)initName
                 description:(NSString *)initDescription
                       modes:(NSMutableArray *)initModes
               andMetamodels:(NSMutableArray *)initMetamodels;
- (void)setName:(NSString *)givenName;
- (void)setDescription:(NSString *)givenDescription;
- (void)setModes:(NSMutableArray *)givenModes;
- (void)setMetamodels:(NSMutableArray *)givenMetamodels;
- (NSString *)getName;
- (NSString *)getDescription;
- (NSMutableArray *)getModes;
- (NSMutableArray *)getMetamodels;
- (BOOL)addMetamodel:(MDMetamodel *)givenMetamodel;
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToMDRoutine:(MDRoutine *)type;
- (NSString *)description;

@end
