//
//  ViewController.m
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvas];
    self.text.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    // Variables
    displayedUUID = [[NSMutableArray alloc] init];
    self.text.text = @"";
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
}

/*!
 @method didReceiveMemoryWarning
 @discussion This method dispose of any resources that can be recreated id a memory warning is recived.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 @method refreshCanvas:
 @discussion This method gets the beacons that must be represented in canvas and ask it to upload; this method is called when someone submits the 'refreshCanvas' notification.
 */
- (void) refreshCanvas:(NSNotification *) notification
{
    // [notification name] should always be @"refreshCanvas"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"refreshCanvas"]){
        NSLog(@"[NOTI][VC] Notification \"refreshCanvas\" recived");
        
        // Save beacons
        NSDictionary *data = notification.userInfo;
        rangedBeaconsDic = [data valueForKey:@"rangedBeaconsDic"];
        self.text.text =  [[NSString alloc] init];
        self.canvas.rangedBeaconsDic = rangedBeaconsDic;
        
        
        // Inspect dictionary for UUID names
        // Declare the inner dictionaries.
        NSMutableDictionary * measureDicDic;
        NSMutableDictionary * uuidDic;
        NSMutableDictionary * uuidDicDic;
        NSMutableDictionary * positionDic;
        
        // For every position where measures were taken
        NSArray *positionKeys = [rangedBeaconsDic allKeys];
        for (id positionKey in positionKeys) {
            // ...get the dictionary for this position.
            positionDic = [rangedBeaconsDic objectForKey:positionKey];
            
            // Get the the dictionary with the UUID's dictionaries...
            uuidDicDic = positionDic[@"positionMeasures"];
            // ...and for every UUID...
            NSArray *uuidKeys = [uuidDicDic allKeys];
            BOOL found = NO;
            for (id uuidKey in uuidKeys) {
                // ...get the dictionary...
                uuidDic = [uuidDicDic objectForKey:uuidKey];
                // ...and get the uuid.
                NSString * uuidNew = uuidDic[@"uuid"];
                
                // Check if it is already displayed
                if (displayedUUID.count == 0) {
                    // Later will be added the new item
                } else {
                    for (NSString * displayed in displayedUUID) {
                        if ([displayed isEqualToString:uuidNew]) {
                            found = YES;
                            NSLog(@"[INFO][VC] Found.");
                        } else {
                            // Later will be added the new item
                        }
                    }
                }
                if (found == NO) {
                    [displayedUUID addObject:uuidNew];
                    NSLog(@"[INFO][VC] Added.");
                    NSLog(@"[INFO][VC] -> %@", uuidNew);
                    self.text.text = [@"\n" stringByAppendingString:uuidNew] ;
                    //self.text.text = [self.text.text stringByAppendingString:[uuidNew stringByAppendingString:@"\n"]];
                    NSLog(@"[INFO][VC] Displayed new UUID.");
                }
            }
        }
    }

    [self.canvas setNeedsDisplay];
}

@end
