//
//  ViewControllerConfigurationMetamodels.m
//  Sensors test
//
//  Created by Alberto J. on 24/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerConfigurationMetamodels.h"
#import "MDMetamodel.h"
#import "MDType.h"

@implementation ViewControllerConfigurationMetamodels

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.5
                                    ];
    
    // Load existing metamodels in the device
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * areMetamodelData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    NSString * areMetamodel;
    if (areMetamodelData) {
        areMetamodel = [NSKeyedUnarchiver unarchiveObjectWithData:areMetamodelData];
    }
    
    
    if (areMetamodelData && areMetamodel && [areMetamodel isEqualToString:@"YES"]) {
        // TO DO: Save the types using its name and no in an array. Alberto J. 15/11/2019.
        // TO DO: Save several metamodels and no only one. Alberto J. 15/11/2019.
        // Existing saved data
        
        // Retrieve the metamodel array
        NSData * metamodelData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/metamodel"];
        NSMutableArray * types = [NSKeyedUnarchiver unarchiveObjectWithData:metamodelData];
        
        NSLog(@"[INFO][VCCM] %tu metamodel types found in device.", types.count);
    } else {
        // No saved data
        
        // Create the types
        MDType * noType = [[MDType alloc] initWithName:@"<No type>"];
        MDType * cornerType = [[MDType alloc] initWithName:@"Corner"];
        MDType * deviceType = [[MDType alloc] initWithName:@"Device"];
        MDType * wallType = [[MDType alloc] initWithName:@"Wall"];
        
        // Save them in persistent memory
        areMetamodelData = nil; // ARC disposing
        areMetamodelData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areMetamodelData forKey:@"es.uam.miso/data/metamodels/areMetamodels"];
        
        NSMutableArray * types = [[NSMutableArray alloc] init];
        [types addObject:noType];
        [types addObject:cornerType];
        [types addObject:deviceType];
        [types addObject:wallType];
        NSData * metamodelData = [NSKeyedArchiver archivedDataWithRootObject:types];
        [userDefaults setObject:metamodelData forKey:@"es.uam.miso/data/metamodels/metamodel"];
        
        NSLog(@"[INFO][VCCM] No metamodel found in device; demo metamodel saved.");
    }
    
}

/*!
 @method viewDidAppear:
 @discussion This method notifies the view controller that its view was added to a view hierarchy.
 */
- (void)viewDidAppear:(BOOL)animated
{
    
}

/*!
 @method didReceiveMemoryWarning
 @discussion This method dispose of any resources that can be recreated id a memory warning is recived.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance methods

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

#pragma mark - UItableView delegate methods

/*!
 @method numberOfSectionsInTableView:
 @discussion Handles the upload of tables; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
}

/*!
 @method tableView:numberOfRowsInSection:
 @discussion Handles the upload of tables; returns the number of items in them.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/*!
 @method tableView:didSelectRowAtIndexPath:
 @discussion Handles the upload of tables; handles the 'select a cell' action.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end