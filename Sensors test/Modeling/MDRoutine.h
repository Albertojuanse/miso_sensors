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
    NSMutableDictionary * modes;
    NSMutableDictionary * metamodels;
    
}

- (instancetype)init;
- (instancetype)initWithName:(NSString *)initName
              andDescription:(NSString *)initDescription;
- (instancetype)initWithName:(NSString *)initName
                 description:(NSString *)initDescription
                       modes:(NSMutableDictionary *)initModes
               andMetamodels:(NSMutableDictionary *)initMetamodels;
- (void)setName:(NSString *)givenName;
- (void)setDescription:(NSString *)givenDescription;
- (void)setModes:(NSMutableDictionary *)givenModes;
- (void)setMetamodels:(NSMutableDictionary *)givenMetamodels;
- (NSString *)getName;
- (NSString *)getDescription;
- (NSMutableDictionary *)getModes;
- (NSMutableDictionary *)getMetamodels;
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToMDRoutine:(MDRoutine *)type;
- (NSString *)description;

@end
