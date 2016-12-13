//
//  MultiThreadViewController.m
//  ToolBox
//
//  Created by ZRBhy on 16/12/13.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import "MultiThreadViewController.h"

#define ROW_COUNT 3   //行数
#define COLUMN_COUNT 3  //列数

@interface MultiThreadViewController ()

@end

@implementation MultiThreadViewController

/**
 常用的多线程开发有三种方式：(使用GCD多一些)
 1.NSThread
 2.NSOperation
 3.GCD
 */

#pragma mark - NSThread   轻量级, 需要自己管理线程生命周期,
-(void)loadImageWithMultiThread{
    //方法1：使用对象方法
    //创建一个线程，第一个参数是请求的操作，第二个参数是操作方法的参数
    //    NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(loadImage) object:nil];
    //    //启动一个线程，注意启动一个线程并非就一定立即执行，而是处于就绪状态，当系统调度时才真正执行
    //    [thread start];
    //SWIFT
    // //创建
    //let thread = NSThread(target: self, selector: "loadImage", object: nil)
    //启动
    // thread.start()
    
    
    //方法2：使用类方法  创建并自动启动
    [NSThread detachNewThreadSelector:@selector(loadImage) toTarget:self withObject:nil];
    //SWIFT
    // NSThread.detachNewThreadSelector("loadImage", toTarget: self, withObject: nil)
}

/*    NSThread 方法
 //取消线程
 - (void)cancel;
 
 //启动线程
 - (void)start;
 
 //判断某个线程的状态的属性
 @property (readonly, getter=isExecuting) BOOL executing;
 @property (readonly, getter=isFinished) BOOL finished;
 @property (readonly, getter=isCancelled) BOOL cancelled;
 
 //设置和获取线程名字
 -(void)setName:(NSString *)n;
 -(NSString *)name;
 
 //获取当前线程信息
 + (NSThread *)currentThread;
 
 //获取主线程信息
 + (NSThread *)mainThread;
 
 //使当前线程暂停一段时间，或者暂停到某个时刻
 + (void)sleepForTimeInterval:(NSTimeInterval)time;
 + (void)sleepUntilDate:(NSDate *)date;
 */

- (void)loadImage{
    //请求数据
    NSData *data= [self requestData];
    /*将数据显示到UI控件,注意只能在主线程中更新UI,
     另外performSelectorOnMainThread方法是NSObject的分类方法，每个NSObject对象都有此方法，
     它调用的selector方法是当前调用控件的方法，例如使用UIImageView调用的时候selector就是UIImageView的方法
     Object：代表调用方法的参数,不过只能传递一个参数(如果有多个参数请使用对象进行封装)
     waitUntilDone:是否线程任务完成执行
     */
    [self performSelectorOnMainThread:@selector(updateImage:) withObject:data waitUntilDone:YES];
}

#pragma mark 请求图片数据
-(NSData *)requestData{
    //对于多线程操作建议把线程操作放到@autoreleasepool中
    @autoreleasepool {
        NSURL *url=[NSURL URLWithString:@"http://images.apple.com/iphone-6/overview/images/biggest_right_large.png"];
        NSData *data=[NSData dataWithContentsOfURL:url];
        return data;
    }
}

#pragma mark 将图片显示到界面
-(void)updateImage:(NSData *)imageData{
//    UIImage *image=[UIImage imageWithData:imageData];
//    _imageView.image=image;
}


#pragma mark - 扩展--NSObject分类扩展方法 (本质还是创建NSThread)
//为了简化多线程开发过程，苹果官方对NSObject进行分类扩展(本质还是创建NSThread)，对于简单的多线程操作可以直接使用这些扩展方法。

//在后台执行一个操作，本质就是重新创建一个线程执行当前方法。
//-(void)performSelectorInBackground:(SEL)aSelector withObject:(id)arg;

//在指定的线程上执行一个方法，需要用户创建一个线程对象。
//-(void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)wait;

//在主线程上执行一个方法。
//-(void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait;


#pragma mark - NSOperation
/*将一个NSOperation（实际开发中需要使用其子类NSInvocationOperation、NSBlockOperation）放到NSOperationQueue这个队列中线程就会依次启动。
    NSOperationQueue负责管理、执行所有的NSOperation，
    更加容易管理线程总数和控制线程之间的依赖关系。
    
    NSOperation有两个常用子类用于创建线程操作：NSInvocationOperation和NSBlockOperation，
    两种方式本质没有区别，但是是后者使用Block形式进行代码组织，使用相对方便。
*/
//---NSInvocationOperation
-(void)loadImageWithNSInvocationOperation{
    /*创建一个调用操作
     object:调用方法参数
     */
    NSInvocationOperation *invocationOperation=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadImage) object:nil];
    //创建完NSInvocationOperation对象并不会调用，它由一个start方法启动操作，但是注意如果直接调用start方法，则此操作会在主线程中调用，一般不会这么操作,而是添加到NSOperationQueue中
    //    [invocationOperation start];
    
    //创建操作队列
    NSOperationQueue *operationQueue=[[NSOperationQueue alloc]init];
    //注意添加到操作队后，队列会开启一个线程执行此操作
    [operationQueue addOperation:invocationOperation];
}

//---NSBlockOperation
//使用NSBlockOperation方法，所有的操作不必单独定义方法，同时解决了只能传递一个参数的问题。
-(void)loadImageWithNSBlockOperation{
    int count=ROW_COUNT*COLUMN_COUNT;
    //创建操作队列
    NSOperationQueue *operationQueue=[[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount=5;//设置最大并发线程数
    //创建多个线程用于填充图片
    for (int i=0; i<count; ++i){
        //方法1：创建操作块添加到队列
        //        //创建多线程操作
        //        NSBlockOperation *blockOperation=[NSBlockOperation blockOperationWithBlock:^{
        //            [self loadImage:[NSNumber numberWithInt:i]];
        //        }];
        //        //创建操作队列
        //
        //        [operationQueue addOperation:blockOperation];
        
        //方法2：直接使用操队列添加操作
        [operationQueue addOperationWithBlock:^{
            [self loadImage:[NSNumber numberWithInt:i]];
        }];
    }
}

//NSOperation-----控制线程执行顺序
//使用NSThread很难控制线程的执行顺序，但是使用NSOperation就容易多了，每个NSOperation可以设置依赖线程。
//优先加载最后一张图的需求，只要设置前面的线程操作的依赖线程为最后一个操作即可
-(void)loadImageWithNSOperation{
    int count=ROW_COUNT*COLUMN_COUNT;
    //创建操作队列
    NSOperationQueue *operationQueue=[[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount=5;//设置最大并发线程数
    
    NSBlockOperation *lastBlockOperation=[NSBlockOperation blockOperationWithBlock:^{
        [self loadImage:[NSNumber numberWithInt:(count-1)]];
    }];
    //创建多个线程用于填充图片
    for (int i=0; i<count-1; ++i) {  //最后一张已被拿到外面.
        //方法1：创建操作块添加到队列
        //创建多线程操作
        NSBlockOperation *blockOperation=[NSBlockOperation blockOperationWithBlock:^{
            [self loadImage:[NSNumber numberWithInt:i]];
        }];
        //设置依赖操作为最后一张图片加载操作
        [blockOperation addDependency:lastBlockOperation];
        
        [operationQueue addOperation:blockOperation];
        
    }
    //将最后一个图片的加载操作加入线程队列
    [operationQueue addOperation:lastBlockOperation];
}


#pragma mark - GCD  (完全面向过程) (对于多核运算更加有效)
//GCD中的队列分为并行队列和串行队列两类.
/**
 多线程下载图片-----串行队列 : 只有一个线程，加入到队列中的操作按添加顺序依次执行。
 使用串行队列时首先要创建一个串行队列，然后调用异步调用方法，在此方法中传入串行队列和线程操作即可自动执行。下面使用线程队列演示图片的加载过程，你会发现多张图片会按顺序加载，因为当前队列中只有一个线程。
 */
-(void)loadImageWithGCDSerialQueue {
    int count = ROW_COUNT * COLUMN_COUNT;
    
    /*创建一个串行队列
     第一个参数：队列名称
     第二个参数：队列类型
     */
    dispatch_queue_t serialQueue = dispatch_queue_create("myThreadQueue1", DISPATCH_QUEUE_SERIAL);  //注意queue对象不是指针类型
    //创建多个线程用于填充图片
    for (int i=0; i<count; ++i) {
        //异步执行队列任务  (asynchronous---异步   synchro---同步)
        dispatch_async(serialQueue, ^{
            [self loadImage:[NSNumber numberWithInt:i]];
        });
    }
    //非ARC环境请释放
    //    dispatch_release(seriQueue);
    
}

/**
 多线程下载图片-----并发队列 : 有多个线程，操作进来之后它会将这些队列安排在可用的处理器上，同时保证先进来的任务优先处理。
    并发队列同样是使用dispatch_queue_create()方法创建，只是最后一个参数指定为DISPATCH_QUEUE_CONCURRENT进行创建，但是在实际开发中我们通常不会重新创建一个并发队列而是使用dispatch_get_global_queue()方法取得一个全局的并发队列（当然如果有多个并发队列可以使用前者创建）。
 */
-(void)loadImageWithGCDConcurrentQueue {
    int count=ROW_COUNT*COLUMN_COUNT;
    /*取得全局队列
     第一个参数：线程优先级
     第二个参数：标记参数，目前没有用，一般传入0
     */
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //创建多个线程用于填充图片
    for (int i=0; i<count; ++i) {
        //异步执行队列任务
        dispatch_async(globalQueue, ^{
            [self loadImage:[NSNumber numberWithInt:i]];
        });
    }

}


/**
 区分 同步 异步 : 这两个函数都需要传递一个队列,和一个block参数.
 dispatch_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
 
 dispatch_sync(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
 
 */
//看下实际的代码:
//to show the difference of dispatch_async and dispatch_sync
- (void)showTheDiffereceOfasyncAndSync {
    //串行队列
    dispatch_queue_t _serialQueue = dispatch_queue_create("com.example.name", DISPATCH_QUEUE_SERIAL);
    
    //异步立刻返回.放打印放入到后台执行
    dispatch_async(_serialQueue, ^{ NSLog(@"1");});
    
    NSLog(@"2");
    
    dispatch_async(_serialQueue, ^{ NSLog(@"3");});
    NSLog(@"4");
    
    //同步等待block的代码执行完.放打印放入到后台执行
    dispatch_sync(_serialQueue, ^{ NSLog(@"1");});
    
    NSLog(@"2");
    
    dispatch_sync(_serialQueue, ^{ NSLog(@"3");});
    NSLog(@"4");
    
    //对于`dispatch_async`来说,把block提交到队列,立刻返回执行下一步.不等待block执行完毕.所以它的打印结果有很多中,譬如说`2413 或者 2143或者 1234`,但是1总在3前面.因为提交到的队列是`串行队列`,打印3总在打印1后执行.
    
    //对于`dispatch_sync`来说,把block提交到队列,不立刻返回,它等待提交到队列的block执行完毕才继续向下执行.所以其执行结果只有一种: 1234.无论你运行多少次都会是这一种结果.
}


- (void)loadImage:(NSNumber *)num {
}

@end
