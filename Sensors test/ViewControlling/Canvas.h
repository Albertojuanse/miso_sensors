//
//  Canvas.h
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Canvas: UIView

@property NSMutableArray * rangedBeacons;
@property NSMutableArray * currentLayers;

- (void) prepareCanvas;

@end
