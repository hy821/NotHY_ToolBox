//
//  ReactiveCocoaViewController.m
//  ToolBox
//
//  Created by 何阳 on 2016/12/12.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import "ReactiveCocoaViewController.h"

@interface ReactiveCocoaViewController ()

@end

@implementation ReactiveCocoaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

 /** RACCommand的创建有两种形式 */
//1       - (id)initWithSignalBlock:(RACSignal * (^)(id input))signalBlock;
//2       - (id)initWithEnabled:(RACSignal *)enabledSignal signalBlock:(RACSignal * (^)(id input))signalBlock;

/*
 第一种就是直接通过传进一个用于构建RACSignal的block参数来初始化RACCommand，而block中的参数input为执行command时传入的数据，另外，创建出的signal可在里面完成一些数据操作，如网络请求，本地数据库读写等等，
 
 第二种则另外还需要传进一个能传递BOOL事件的RACSignal，这个signal的作用相当于过滤，当传递的布尔事件为真值时，command能够执行，反之则不行。

 注意: 伴随着command一起构建的signal，记得要在操作完成后发送完成消息以表示其执行完了：
 [subscriber sendCompleted];
 否则不能再执行此command。
 
 */

- (RACCommand *)oneCommand {
    if(!_oneCommand) {
//        @weakify(self);
       /*第一种
        _oneCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            
        }];
       */
        
        //第二种
//        _oneCommand= [[RACCommand alloc] initWithEnabled:self.emailValidSignal signalBlock:^RACSignal *(id input) {
//            @strongify(self);
//            return[SubscribeViewModel postEmail:self.email];
//        }];
    }
    return _oneCommand;
}











@end
