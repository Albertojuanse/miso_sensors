//
//  MDAttribute.h
//  Sensors test
//
//  Created by MISO on 4/2/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>

/*!
 @class MDAttribute
 @discussion Definition of any attribute that a type can need.
 */
@interface MDAttribute: NSObject <NSCoding>  {
    
    NSString * name;
    id attribute;
    
}

- (instancetype)init;
- (instancetype)initWithName:(NSString *)givenName;
- (instancetype)initWithName:(NSString *)givenName
                andAttribute:(id)givenAttribute;
- (void)setName:(NSString *)givenName;
- (NSString *)getName;
- (void)setAttribute:(id)givenAttribute;
- (id)getAttribute;
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToMDAttribute:(MDAttribute *)type;
- (NSString *)description;

@end

