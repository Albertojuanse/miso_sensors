//
//  VCVerticalTable.h
//  Sensors test
//
//  Created by Alberto J. on 19/2/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SharedData.h"
#import "MDMode.h"

/*!
 @class VCModesTable
 @discussion This class extends UIScrollView and creates a bar for title and option buttons.
 */
@interface VCModesTable: UIScrollView <UIScrollViewDelegate> {
    
    // Components
    SharedData * sharedData;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Modes
    NSMutableArray * modes;
    
}

- (void)prepareModesTableWithSharedData:(SharedData *)givenSharedData
                                userDic:(NSMutableDictionary *)givenUserDic
                  andCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setSharedData:(SharedData *)givenSahredData;

@end
