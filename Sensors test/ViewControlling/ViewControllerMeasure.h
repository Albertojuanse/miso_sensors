//
//  ViewControllerMeasure.h
//  Sensors test
//
//  Created by Alberto J. on 23/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VCDrawings.h"
#import "VCModeDelegate.h"

/*!
 @class ViewControllerMeasure
 @discussion This class extends UIViewController and helps user to measure the items.
 */
@interface ViewControllerMeasure : UIViewController <UIPopoverPresentationControllerDelegate> {
    
    // Components
    id<VCModeDelegate> delegate;
    
    // Variables
    NSMutableDictionary * itemDic;
    
}

@property (weak, nonatomic) IBOutlet UIImageView * tutorialImageView;
@property (weak, nonatomic) IBOutlet UIButton * measureButton;

- (void) setItemDicToMeasure:(NSMutableDictionary *)givenItemDic;
- (void) setDelegate:(id<VCModeDelegate>)givenDelegate;

@end
