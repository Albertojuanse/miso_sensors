//
//  Blackbox.m
//  Sensors test
//
//  Created by Alberto J. on 27/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

@interface Blackbox.m {
    
    @property input;
    @property output;
    
    - (void) queueInput;
    - (void) dequeueOutput;
}

@end
