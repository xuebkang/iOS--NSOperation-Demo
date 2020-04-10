//
//  NSOperationQueueViewController.m
//  多线程——NSOperation
//
//  Created by 薛 on 2020/4/11.
//  Copyright © 2020 CJW. All rights reserved.
//

/**
 NSOperationQueue 一共有两种队列：主队列、自定义队列。
 其中自定义队列同时包含了串行、并发功能。
 下边是主队列、自定义队列的基本创建方法和特点。
 
 主队列
 凡是添加到主队列中的操作，都会放到主线程中执行。
 // 主队列获取方法
 NSOperationQueue *queue = [NSOperationQueue mainQueue];
 */

/**
 自定义队列（非主队列）

 1：添加到这种队列中的操作，就会自动放到子线程中执行。
 2：同时包含了：串行、并发功能。
 
 // 自定义队列创建方法
 NSOperationQueue *queue = [[NSOperationQueue alloc] init];

 */

#import "NSOperationQueueViewController.h"

@interface NSOperationQueueViewController ()
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UIButton *button3;
@property (nonatomic, strong) UIButton *button4;
@property (nonatomic, strong) UIButton *button5;
@property (nonatomic, strong) UIButton *button6;

@property (nonatomic, assign) NSInteger totalTicketCount;//总票数
@property (nonatomic, strong) NSLock *lock;
@end

@implementation NSOperationQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"NSOperationQueue操作";
    [self.view addSubview:self.button1];
    [self.view addSubview:self.button2];
    [self.view addSubview:self.button3];
    [self.view addSubview:self.button4];
    [self.view addSubview:self.button5];
    [self.view addSubview:self.button6];
}

- (UIButton *)button1{
    if (!_button1) {
        _button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button1 setTitle:@"addOperation操作加入队列" forState:UIControlStateNormal];
        _button1.frame = CGRectMake(50, 100, self.view.bounds.size.width -100, 40);
        _button1.backgroundColor = [UIColor orangeColor];
        [_button1 addTarget:self action:@selector(action1) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button1;
}
- (UIButton *)button2{
    if (!_button2) {
        _button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button2 setTitle:@"addOperationWithBlock操作" forState:UIControlStateNormal];
        _button2.frame = CGRectMake(50, 160, self.view.bounds.size.width -100, 40);
        _button2.backgroundColor = [UIColor orangeColor];
        [_button2 addTarget:self action:@selector(action2) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button2;
}
- (UIButton *)button3{
    if (!_button3) {
        _button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button3 setTitle:@"NSOperationQueue控制并发或者串行" forState:UIControlStateNormal];
        _button3.frame = CGRectMake(50, 220, self.view.bounds.size.width -100, 40);
        _button3.backgroundColor = [UIColor orangeColor];
        [_button3 addTarget:self action:@selector(action3) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button3;
}

- (UIButton *)button4{
    if (!_button4) {
        _button4 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button4 setTitle:@"NSOperation操作依赖" forState:UIControlStateNormal];
        _button4.frame = CGRectMake(50, 280, self.view.bounds.size.width -100, 40);
        _button4.backgroundColor = [UIColor orangeColor];
        [_button4 addTarget:self action:@selector(addDependency) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button4;
}

- (UIButton *)button5{
    if (!_button5) {
        _button5 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button5 setTitle:@"线程之间的通信" forState:UIControlStateNormal];
        _button5.frame = CGRectMake(50, 340, self.view.bounds.size.width -100, 40);
        _button5.backgroundColor = [UIColor orangeColor];
        [_button5 addTarget:self action:@selector(operationCommunicate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button5;
}

- (UIButton *)button6{
    if (!_button6) {
        _button6 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button6 setTitle:@"线程安全NSLock加锁" forState:UIControlStateNormal];
        _button6.frame = CGRectMake(50, 400, self.view.bounds.size.width -100, 40);
        _button6.backgroundColor = [UIColor orangeColor];
        [_button6 addTarget:self action:@selector(initTicketStatusSave) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button6;
}


// NSOperation 需要配合 NSOperationQueue 来实现多线程。
/*
 *需要先创建操作，再将创建好的操作加入到创建好的队列中去
   使用 addOperation: 将操作加入到操作队列中
 */

- (void)action1{
    //创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //创建操作
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
//    [op1 start]; //开启执行
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
//    [op2 start];
    
    //另一种方式创建操作
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
           for (int i = 0; i <3; i++) {
             //模拟耗时操作
             [NSThread sleepForTimeInterval:2];
             NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
         }
    }];
    
    [op3 addExecutionBlock:^{
           for (int i = 0; i <3; i++) {
             //模拟耗时操作
             [NSThread sleepForTimeInterval:2];
             NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
         }
    }];
    
    //把操作添加到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}
/*
 *无需先创建操作，在 block 中添加操作，直接将包含操作的 block 加入到队列中。
 */
- (void)action2{
    //使用 addOperationWithBlock: 将操作加入到操作队列中
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
                
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
                
        }
    }];

    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
                
        }
    }];

}
/*
 *NSOperationQueue 创建的自定义队列同时具有串行、并发功能，上边我们演示了并发功能，那么他的串行功能是如何实现的？
 这里有个关键属性 maxConcurrentOperationCount，叫做最大并发操作数。用来控制一个特定队列中可以有多少个操作同时参与并发执行。
 
 注意：这里 maxConcurrentOperationCount 控制的不是并发线程的数量，而是一个队列中同时能并发执行的最大操作数。而且一个操作也并非只能在一个线程中运行。
 
 最大并发操作数：maxConcurrentOperationCount

 maxConcurrentOperationCount 默认情况下为-1，表示不进行限制，可进行并发执行。
 maxConcurrentOperationCount 为1时，队列为串行队列。只能串行执行。
 maxConcurrentOperationCount 大于1时，队列为并发队列。操作并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整为 min{自己设定的值，系统设定的默认最大值}。

 */
- (void)action3{
    //创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
     // 2.设置最大并发操作数
//        queue.maxConcurrentOperationCount = 1; // 串行队列
    // queue.maxConcurrentOperationCount = 2; // 并发队列
     queue.maxConcurrentOperationCount = 8; // 并发队列
    [queue addOperationWithBlock:^{
         for (int i = 0; i < 2; i++) {
         [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
         NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
                
         }
    }];
    
    [queue addOperationWithBlock:^{
         for (int i = 0; i < 2; i++) {
         [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
         NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
                
         }
    }];

    [queue addOperationWithBlock:^{
         for (int i = 0; i < 2; i++) {
         [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
         NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
                
         }
    }];

    /*
     可以看出：当最大并发操作数为1时，操作是按顺序串行执行的，并且一个操作完成之后，下一个操作才开始执行。当最大操作并发数为2时，操作是并发执行的，可以同时执行两个操作。而开启线程数量是由系统决定的，不需要我们来管理。

     */
}

/*
 *NSOperation、NSOperationQueue 最吸引人的地方是它能添加操作之间的依赖关系。通过操作依赖，我们可以很方便的控制操作之间的执行先后顺序。NSOperation 提供了3个接口供我们管理和查看依赖。

 - (void)addDependency:(NSOperation *)op; 添加依赖，使当前操作依赖于操作 op 的完成。
 - (void)removeDependency:(NSOperation *)op; 移除依赖，取消当前操作对操作 op 的依赖。
 @property (readonly, copy) NSArray<NSOperation *> *dependencies; 在当前操作开始执行之前完成执行的所有操作对象数组。

 当然，我们经常用到的还是添加依赖操作。现在考虑这样的需求，比如说有 A、B 两个操作，其中 A 执行完操作，B 才能执行操作。
 如果使用依赖来处理的话，那么就需要让操作 B 依赖于操作 A。具体代码如下
 */
- (void)addDependency{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *opA = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    NSBlockOperation *opB = [NSBlockOperation blockOperationWithBlock:^{
           for (int i = 0; i < 3; i++) {
               [NSThread sleepForTimeInterval:2];
               NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
           }
       }];
    NSBlockOperation *opC = [NSBlockOperation blockOperationWithBlock:^{
           for (int i = 0; i < 3; i++) {
               [NSThread sleepForTimeInterval:2];
               NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
           }
       }];
    

    //添加依赖
    [opB addDependency:opA];// 让opB 依赖于 opA，则先执行opA，在执行opB
    [opC addDependency:opB];// opC 依赖于opB,则先执行B，再执行C
    
    //删除依赖
    [opC removeDependency:opB];//删除依赖后，A和C 是并发执行，然后再执行B
    
    //设置优先级
    [opA setQueuePriority:NSOperationQueuePriorityHigh];
    [opC setQueuePriority:(NSOperationQueuePriorityVeryHigh)];

    
    //阻塞当前线程，直到该操作结束。可用于线程执行顺序的同步。
//    [opC waitUntilFinished];
    
    //添加到队列
    [queue addOperation:opA];
    [queue addOperation:opB];
    [queue addOperation:opC];
}
 
/*
 *NSOperation、NSOperationQueue 线程间的通信
 开发过程中，我们一般在主线程里边进行 UI 刷新，例如：点击、滚动、拖拽等事件。我们通常把一些耗时的操作放在其他线程，比如说图片下载、文件上传等耗时操作。而当我们有时候在其他线程完成了耗时操作时，需要回到主线程，那么就用到了线程之间的通讯。
 */
- (void)operationCommunicate{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i <2; i++) {
               //模拟耗时操作
               [NSThread sleepForTimeInterval:2];
               NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
           }
    }];
    //回到主线程
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // 进行一些 UI 刷新等操作
        for (int i = 0; i <2; i++) {
               //模拟耗时操作
               [NSThread sleepForTimeInterval:2];
               NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
           }
    }];
    
}
-(void)task1{
    for (int i = 0; i <3; i++) {
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
    }
}
-(void)task2{
    for (int i = 0; i <3; i++) {
         //模拟耗时操作
         [NSThread sleepForTimeInterval:2];
         NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
     }
}

//初始化并创建队列和操作
- (void)initTicketStatusSave{
    NSLog(@"currentThread---%@",[NSThread currentThread]); // 打印当前线程
    self.totalTicketCount = 50;
    self.lock = [[NSLock alloc] init];// 初始化 NSLock 对象
    //创建一个线程队列 代表北京站
    NSOperationQueue *bjQueue = [[NSOperationQueue alloc] init];
    [bjQueue setName:@"北京站"];
    //设置最大并发数1----意味着串行队列
    bjQueue.maxConcurrentOperationCount = 1;
    
    //创建一个线程队列， 代表上海站
    NSOperationQueue *shQueue = [[NSOperationQueue alloc] init];
    shQueue.maxConcurrentOperationCount = 1;
    [shQueue setName:@"上海站"];
    //创建卖票操作
    __weak typeof(self) weakSelf = self;
    //北京站添加操作,并开始售卖
    [bjQueue addOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    //上海站添加操作，并开始售卖
    [shQueue addOperationWithBlock:^{
         [weakSelf saleTicketSafe];
    }];
    
}

/**
* 售卖火车票(线程安全)
*/
- (void)saleTicketSafe{
    while (1) {
        //加锁
        [self.lock lock];
        if (self.totalTicketCount > 0) {
            //如果还有票，继续售卖
            self.totalTicketCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", self.totalTicketCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];//延时0.5秒
        }
        [self.lock unlock]; //解锁
        if (self.totalTicketCount <= 0) {
            NSLog(@"火车票全部售出");
            break;
        }
    }
}
@end
