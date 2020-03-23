//
//  VCModesTable.m
//  Sensors test
//
//  Created by Alberto J. on 19/2/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCModesTable.h"

@implementation VCModesTable

#pragma mark - UIScrollView delegated methods



#pragma mark - Instance methods
/*!
 @method prepareModesTableWithSharedData:userDic:andCredentialsUserDic:
 @discussion This method initializes some properties of the m odestable; is called when the main view is loaded by its controller.
 */
- (void)prepareModesTableWithSharedData:(SharedData *)givenSharedData
                                userDic:(NSMutableDictionary *)givenUserDic
                  andCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    // Initialize components and variables
    sharedData = givenSharedData;
    credentialsUserDic = givenCredentialsUserDic;
    userDic = givenUserDic;
    self.delegate = self;
}

/*!
 @method setSharedData
 @discussion Setter of the 'shared Data' attribute.
 */
- (void)setSharedData:(SharedData *)givenSahredData
{
    sharedData = givenSahredData;
}

/*!
 @method setCredentialsUserDic:
 @discussion This method sets the NSMutableDictionary with the security purposes user credentials.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    credentialsUserDic = givenCredentialsUserDic;
}

/*!
 @method setUserDic:
 @discussion This method sets the NSMutableDictionary with the identifying purposes user credentials.
 */
- (void) setUserDic:(NSMutableDictionary *)givenUserDic
{
    userDic = givenUserDic;
}

@end
