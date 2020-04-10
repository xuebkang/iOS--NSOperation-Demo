//
//  CustomOperation1.m
//  多线程——NSOperation
//
//  Created by 薛 on 2020/4/10.
//  Copyright © 2020 CJW. All rights reserved.
//

#import "CustomOperation1.h"

@implementation CustomOperation1

- (void)main{
    
    if (!self.isCancelled) {
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@",[NSThread currentThread]);
        }
    }
}
@end
