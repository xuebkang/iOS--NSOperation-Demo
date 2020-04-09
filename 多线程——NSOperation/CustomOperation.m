//
//  CustomOperation.m
//  多线程——NSOperation
//
//  Created by CJW on 2019/8/13.
//  Copyright © 2019 CJW. All rights reserved.
//

#import "CustomOperation.h"
@interface CustomOperation ()
@property (nonatomic,copy) NSString *operName;

@end

@implementation CustomOperation
- (instancetype)initWithName:(NSString *)name{
    self = [super init];
    if (self) {
        NSLog(@"------%@", NSStringFromClass([self class]));
        NSLog(@"+++%@", [super class]);
        self.operName = name;
    }
    
    return self;
}

- (void)main{
    for (int i =0; i < 3; i++) {
        NSLog(@"%@ %d",self.operName, i);
        [NSThread sleepForTimeInterval:1];
    }
}
@end
