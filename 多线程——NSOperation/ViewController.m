//
//  ViewController.m
//  多线程——NSOperation
//
//  Created by CJW on 2019/8/8.
//  Copyright © 2019 CJW. All rights reserved.
//NSOperation、NSOperationQueue 是苹果提供给我们的一套多线程解决方案。实际上 NSOperation、NSOperationQueue 是基于 GCD 更高一层的封装，完全面向对象。但是比 GCD 更简单易用、代码可读性也更高。

/*
 为什么要使用 NSOperation、NSOperationQueue？

 可添加完成的代码块，在操作完成后执行。
 添加操作之间的依赖关系，方便的控制执行顺序。
 设定操作执行的优先级。
 可以很方便的取消一个操作的执行。
 使用 KVO 观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled。

 */

#import "ViewController.h"
#import "CustomOperation.h"
#import "CustomOperation1.h"
#import "NSOperationQueueViewController.h"
@interface ViewController ()
@property (nonatomic, strong) NSInvocationOperation *invocationO;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UIButton *button3;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
/*******NSOperation的两种使用方式
 1:NSInvocationOperation   && NSBlockOperation
 2:自定义类继承 NSOperation
 ************************************/
    self.view.backgroundColor = [UIColor orangeColor];
    self.title = @"NSOperation操作";
    [self.view addSubview:self.button];
    [self.view addSubview:self.button1];
    [self.view addSubview:self.button2];
    [self.view addSubview:self.button3];
}
- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button setTitle:@"NSOperation操作" forState:UIControlStateNormal];
        _button.frame = CGRectMake(50, 100, self.view.bounds.size.width -100, 40);
        _button.backgroundColor = [UIColor whiteColor];
        [_button addTarget:self action:@selector(action1) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
- (UIButton *)button1{
    if (!_button1) {
        _button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button1 setTitle:@"NSBlockOperation操作" forState:UIControlStateNormal];
        _button1.frame = CGRectMake(50, 160, self.view.bounds.size.width -100, 40);
        _button1.backgroundColor = [UIColor whiteColor];
        [_button1 addTarget:self action:@selector(action2) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button1;
}
- (UIButton *)button2{
    if (!_button2) {
        _button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button2 setTitle:@"NSOperationQueue操作" forState:UIControlStateNormal];
        _button2.frame = CGRectMake(50, 220, self.view.bounds.size.width -100, 40);
        _button2.backgroundColor = [UIColor whiteColor];
        [_button2 addTarget:self action:@selector(action5) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button2;
}
- (UIButton *)button3{
    if (!_button3) {
        _button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button3 setTitle:@"NSOperation自定义的子类" forState:UIControlStateNormal];
        _button3.frame = CGRectMake(50, 280, self.view.bounds.size.width -100, 40);
        _button3.backgroundColor = [UIColor whiteColor];
        [_button3 addTarget:self action:@selector(action4) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button3;
}

#pragma mark --第一种方式：NSInvocationOperation  ---同步执行
//在不使用 NSOperationQueue，单独使用 NSOperation 的情况下系统同步执行操作
- (void)action1{
    _invocationO = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocaitonOperation) object:nil];
    [_invocationO start]; //启动
}
- (void)invocaitonOperation{

    for (int i = 0; i < 5; i++) {
        NSLog(@"当前I的值== %d", i);
        [NSThread sleepForTimeInterval:2]; //模拟耗时操作
        NSLog(@"当前线程---%@", [NSThread currentThread]); // 打印当前线程
        if (i == 3) {
            [_invocationO cancel];
            NSLog(@"暂停执行");
        }
        if ([_invocationO isCancelled]) {
            [_invocationO isFinished];
            NSLog(@"退出执行");
        }
    }
}
//如果在其他线程中执行操作，则打印结果为其他线程。

//可以看到：在其他线程中单独使用子类 NSInvocationOperation，操作是在当前调用的其他线程执行的，并没有开启新线程。
- (void)invocaitonOperation2{
    [NSThread detachNewThreadSelector:@selector(action1) toTarget:self withObject:nil];
}
#pragma mark --第二种方式：NSBlockOperation  ---同步执行
/**
 在没有使用 NSOperationQueue、在主线程中单独使用 NSBlockOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。
 */
- (void)action2{
      
      NSBlockOperation *blockO = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"当前I的值== %d", i);
            [NSThread sleepForTimeInterval:1];
        }
    }];

    /**
     NSBlockOperation 还提供了一个方法 addExecutionBlock:，通过 addExecutionBlock: 就可以为 NSBlockOperation 添加额外的操作。这些操作（包括 blockOperationWithBlock 中的操作）可以在不同的线程中同时（并发）执行。只有当所有相关的操作已经完成执行时，才视为完成。
     */
    /**
     如果添加的操作多的话，blockOperationWithBlock: 中的操作也可能会在其他线程（非当前线程）中执行，这是由系统决定的，并不是说添加到 blockOperationWithBlock: 中的操作一定会在当前线程中执行。
     */
    [blockO addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"哈哈==%d", i);
            [NSThread sleepForTimeInterval:1];
        }
    }];
    
    [blockO addExecutionBlock:^{
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    [blockO addExecutionBlock:^{
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    [blockO addExecutionBlock:^{
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    [blockO addExecutionBlock:^{
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"5---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    [blockO start];
    
    /**
     一般情况下，如果一个 NSBlockOperation 对象封装了多个操作。NSBlockOperation 是否开启新线程，取决于操作的个数。如果添加的操作的个数多，就会自动开启新线程。当然开启的线程数是由系统来决定的。
     */
}

- (void)action5{
    NSOperationQueueViewController *vc = [[NSOperationQueueViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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

/**
如果使用子类 NSInvocationOperation、NSBlockOperation 不能满足日常需求，我们可以使用自定义继承自 NSOperation 的子类。可以通过重写 main 或者 start 方法 来定义自己的 NSOperation 对象。重写main方法比较简单，我们不需要管理操作的状态属性 isExecuting 和 isFinished。当 main 执行完返回的时候，这个操作就结束了。
*/
- (void)action4{
    CustomOperation1 *operation = [[CustomOperation1 alloc] init];
    // 调用 start 方法开始执行操作
    [operation start];
    /**
     可以看出：在没有使用 NSOperationQueue、在主线程单独使用自定义继承自 NSOperation 的子类的情况下，是在主线程执行操作，并没有开启新线程。
     */
}
@end
