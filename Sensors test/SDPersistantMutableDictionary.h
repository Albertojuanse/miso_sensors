//
//  SDPersistantMutableDictionary.h
//  Sensors test
//
//  Created by Alberto J. on 18/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDPersistantMutableDictionary : NSMutableDictionary <NSCoding> {
    NSString *title;
    NSString *author;
    BOOL published;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic) BOOL published;

@end
