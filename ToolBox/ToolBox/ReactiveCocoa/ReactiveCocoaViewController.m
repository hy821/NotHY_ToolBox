//
//  ReactiveCocoaViewController.m
//  ToolBox
//
//  Created by 何阳 on 2016/12/12.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import "ReactiveCocoaViewController.h"
#import "Person.h"

@interface ReactiveCocoaViewController ()

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong)  UILabel *nameLabel;

@property (nonatomic, strong) Person *person;

@property (nonatomic, strong) UITextField *nameText;

@property (nonatomic, strong) UITextField *passWordText;

@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) RACDelegateProxy *proxy;

@end

@implementation ReactiveCocoaViewController

/*RAC创建用法总结 */

//KVO 监听
//程序实现： 监控Person name的属性变化；在touchesBegan中改变name的值，并将变化体现在UILabel上，实现KVO的监控功能；
//注意，RAC 的信号一旦注册不会主动释放
//只要在 block 中包含有 self. 一定会出现强引用* 需要使用 @weakify(self) / @strongify(self) 组合使用解除强引用.

- (void)viewDidLoad {
    [super viewDidLoad];
    [self demoKVO];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.name = [NSString stringWithFormat:@"zhang %d",arc4random_uniform(100)];
}

/**
 * 1、为了测试此函数，增加了一个Person类 && 一个Label；点击屏幕则会等改Lable的值
 */
#pragma -mark KVO 监听
- (void)demoKVO {
    
    @weakify(self)
    [RACObserve(self.person, name)
     subscribeNext:^(id x) {
         @strongify(self)
         self.nameLabel.text = x;
     }];
}

- (Person *)person {
    if (!_person) {
        _person = [[Person alloc] init]; } return _person;
}

//文本框输入事件监听
/**
 * 2、为了测试此函数，增加了一个nameText；监听文本框的输入内容，并设置为self.person.name
 */
- (void)demoTextField {
    
    @weakify(self);
    [[self.nameText rac_textSignal] subscribeNext:^(id x) {
         @strongify(self);
         NSLog(@"%@",x);
         self.person.name = x;
     }];
}

//文本框组合信号
/**
 * 3、为了验证此函数，增加了一个passwordText和一个Button，监测nameText和passwordText
 * 根据状态是否enabled
 */
- (void)textFileCombination {
    
    id signals = @[[self.nameText rac_textSignal],[self.passWordText rac_textSignal]];
    
    @weakify(self);
    [[RACSignal combineLatest:signals] subscribeNext:^(RACTuple *x) {
         @strongify(self);
         NSString *name = [x first];
         NSString *password = [x second];
         
         if (name.length > 0 && password.length > 0) {

             self.loginButton.enabled = YES;
             self.person.name = name;
             self.person.password = password;
             
         } else  {
             self.loginButton.enabled = NO;
         }
     }];
}

//按钮监听
/**
 * 4、验证此函数：当loginButton可以点击时，点击button输出person的属性，实现监控的效果
 */
- (void)buttonDemo {
    @weakify(self);
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
         @strongify(self);
         NSLog(@"person.name:  %@    person.password:  %@",self.person.name,self.person.password);
    }];
}

//代理方法
/**
 * 5、验证此函数：nameText的输入字符时，输入回车或者点击键盘的回车键使passWordText变为第一响应者（即输入光标移动到passWordText处）
 */
- (void)delegateDemo {
    
    @weakify(self)
    // 1. 定义代理
    self.proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UITextFieldDelegate)];
    // 2. 代理去注册文本框的监听方法
    [[self.proxy rac_signalForSelector:@selector(textFieldShouldReturn:)]
     subscribeNext:^(id x) {
         @strongify(self)
         if (self.nameText.hasText) {
             [self.passWordText becomeFirstResponder];
         }
     }];
    self.nameText.delegate = (id<UITextFieldDelegate>)self.proxy;
}

//通知
/**
 * 验证此函数：点击textFile时，系统键盘会发送通知，打印出通知的内容
 */
- (void)notificationDemo {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil]
     subscribeNext:^(id x) {
         NSLog(@"notificationDemo : %@", x);
     }
     ];
}



/*
文／袁峥Seemygo（简书作者）
原文链接：http://www.jianshu.com/p/87ef6720a096
著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
*/

/*  ReactiveCocoa常见类
    学习框架首要之处:个人认为先要搞清楚框架中常用的类，
    在RAC中最核心的类RACSiganl,搞定这个类就能用ReactiveCocoa开发了。

    RACSiganl:信号类,一般表示将来有数据传递，只要有数据改变，信号内部接收到数据，就会马上发出数据。

注意：

    信号类(RACSiganl)，只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者去发出。

    默认一个信号都是冷信号，也就是值改变了，也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发。

    如何订阅信号：调用信号RACSignal的subscribeNext就能订阅。

*/

/*      RACSiganl简单使用:
 // RACSignal使用步骤：
 // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
 // 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 // 3.发送信号 - (void)sendNext:(id)value
 
 
 // RACSignal底层实现：
 // 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
 // 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
 // 2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
 // 2.1 subscribeNext内部会调用siganl的didSubscribe
 // 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
 // 3.1 sendNext底层其实就是执行subscriber的nextBlock
 
 // 1.创建信号
 RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
 
         // block调用时刻：每当有订阅者订阅信号，就会调用block。
         
         // 2.发送信号
         [subscriber sendNext:@1];
         
         // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
         [subscriber sendCompleted];
         
         return [RACDisposable disposableWithBlock:^{
         
             // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
             
             // 执行完Block后，当前信号就不在被订阅了。
             
             NSLog(@"信号被销毁");
         
         }];
 }];
 
 // 3.订阅信号,才会激活信号.
 [siganl subscribeNext:^(id x) {
     // block调用时刻：每当有信号发出数据，就会调用block.
     NSLog(@"接收到数据:%@",x);
 }];
 
 */

/*
 6.2 RACSubscriber:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
 
 6.3 RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
 
 使用场景:不想监听某个信号时，可以通过它主动取消订阅信号。
 6.4 RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号。
 
 使用场景:通常用来代替代理，有了它，就不必要定义代理了。
 RACReplaySubject:重复提供信号类，RACSubject的子类。
 
 RACReplaySubject与RACSubject区别:
 RACReplaySubject可以先发送信号，在订阅信号，RACSubject就不可以。
 使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类。
 使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值。
 
 RACSubject和RACReplaySubject简单使用:

 */


/*
 RACCommand:RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程。
 
 使用场景:监听按钮点击，网络请求
 
 RACCommand简单使用

 // 一、RACCommand使用步骤:
 // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
 // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
 // 3.执行命令 - (RACSignal *)execute:(id)input
 
 // 二、RACCommand使用注意:
 // 1.signalBlock必须要返回一个信号，不能传nil.
 // 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
 // 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
 // 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
 
 // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
 // 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
 // 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
 
 // 四、如何拿到RACCommand中返回信号发出的数据。
 // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
 // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
 
 // 五、监听当前命令是否正在执行executing
 
 // 六、使用场景:  监听按钮点击，网络请求
 
 
 // 1.创建命令
 RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
 
     NSLog(@"执行命令");
     
     // 创建空信号,必须返回信号
     //        return [RACSignal empty];
     
     // 2.创建信号,用来传递数据
     return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
     
         [subscriber sendNext:@"请求数据"];
         
         // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
         [subscriber sendCompleted];
         
         return nil;
     }];
     
 }];
 
 // 强引用命令，不要被销毁，否则接收不到数据
 _conmmand = command;
 
 
 
 // 3.订阅RACCommand中的信号
 [command.executionSignals subscribeNext:^(id x) {
 
 [x subscribeNext:^(id x) {
 
 NSLog(@"%@",x);
 }];
 
 }];
 
 // RAC高级用法
 // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
 [command.executionSignals.switchToLatest subscribeNext:^(id x) {
 
 NSLog(@"%@",x);
 }];
 
 // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
 [[command.executing skip:1] subscribeNext:^(id x) {
 
 if ([x boolValue] == YES) {
 // 正在执行
 NSLog(@"正在执行");
 
 }else{
 // 执行完成
 NSLog(@"执行完成");
 }
 
 }];
 // 5.执行命令
 [self.conmmand execute:@1];

 */









































































































































































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
