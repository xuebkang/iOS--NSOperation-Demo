//
//  ViewController.m
//  多线程——NSOperation
//
//  Created by CJW on 2019/8/8.
//  Copyright © 2019 CJW. All rights reserved.
//

#import "ViewController.h"
#import "CustomOperation.h"
@interface ViewController ()
@property (nonatomic, strong) NSInvocationOperation *invocationO;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
/*******NSOperation的两种使用方式
 1:NSInvocationOperation   && NSBlockOperation
 2:自定义类继承 NSOperation
 ************************************/
    self.view.backgroundColor = [UIColor orangeColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"NSOperation操作" forState:UIControlStateNormal];
    button.frame = CGRectMake(50, 100, self.view.bounds.size.width -100, 40);
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(action1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button1 setTitle:@"NSBlockOperation操作" forState:UIControlStateNormal];
    button1.frame = CGRectMake(50, 200, self.view.bounds.size.width -100, 40);
    button1.backgroundColor = [UIColor whiteColor];
    [button1 addTarget:self action:@selector(action2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2 setTitle:@"NSOperationQueue操作" forState:UIControlStateNormal];
    button2.frame = CGRectMake(50, 300, self.view.bounds.size.width -100, 40);
    button2.backgroundColor = [UIColor whiteColor];
    [button2 addTarget:self action:@selector(action3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];


}
#pragma mark --第一种方式：NSInvocationOperation  ---同步执行
- (void)action1{
    _invocationO = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocaitonO) object:nil];
    [_invocationO start]; //启动
}
- (void)invocaitonO{
    for (int i = 0; i < 5; i++) {
        NSLog(@"当前I的值== %d", i);
        [NSThread sleepForTimeInterval:1];
//        if (i == 3) {
//            [_invocationO cancel];
//            NSLog(@"暂停执行");
//        }
//        if ([_invocationO isCancelled]) {
//            [_invocationO isFinished];
//            NSLog(@"退出执行");
//        }
    }
}
#pragma mark --第一种方式：NSBlockOperation  ---同步执行
- (void)action2{
      NSBlockOperation *blockO = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"当前I的值== %d", i);
            [NSThread sleepForTimeInterval:1];
        }
    }];
    //添加额外操作  开辟一个新线程
    [blockO addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"哈哈==%d", i);
            [NSThread sleepForTimeInterval:1];
        }
    }];
    
    [blockO start];
}

- (void)action3{
//    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
//        for (int i = 0; i < 5; i++) {
//            NSLog(@"当前I的值== %d", i);
//            [NSThread sleepForTimeInterval:1];
//        }
//    }];
    
    CustomOperation *operA = [[CustomOperation alloc] initWithName:@"operA"];
    CustomOperation *operB = [[CustomOperation alloc] initWithName:@"operB"];

    CustomOperation *operC = [[CustomOperation alloc] initWithName:@"operC"];

    CustomOperation *operD = [[CustomOperation alloc] initWithName:@"operD"];
    
    //阻塞当前线程，直到该操作结束。可用于线程执行顺序的同步。
    [operA waitUntilFinished];
//    [operB setCompletionBlock:^{
//
//    }];
    
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    //通过addOperationWithBlock 这种方式 可以开辟独立的线程
    [self.queue addOperationWithBlock:^{
        for (int i = 0; i <3; i++) {
            NSLog(@"queue添加 %d", i);
            [NSThread sleepForTimeInterval:1];
        }
    }];
    /***********
    maxConcurrentOperationCount 默认情况下为-1，表示不进行限制，可进行并发执行。
    maxConcurrentOperationCount 为1时，队列为串行队列。只能串行执行。
    maxConcurrentOperationCount 大于1时，队列为并发队列。
****///
     self.queue.maxConcurrentOperationCount = 4;  //设置最大线程数
     //添加线程依赖，顺序执行
//    [operD addDependency:operC];
//     [operC addDependency:operB];
//     [operB addDependency:operA];
//
//     //移除线程依赖
//     [operB removeDependency:operA];
//
     [self.queue addOperation:operA]; //添加到队列
     [self.queue addOperation:operB];
     [self.queue addOperation:operC];
     [self.queue addOperation:operD];
}

@end
