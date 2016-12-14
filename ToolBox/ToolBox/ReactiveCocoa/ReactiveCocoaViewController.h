//
//  ReactiveCocoaViewController.h
//  ToolBox
//
//  Created by 何阳 on 2016/12/12.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReactiveCocoaViewController : UIViewController

@property (nonatomic, strong) RACCommand *oneCommand;

@end

/* 面试RAC
 RAC的信号机制很容易将某一个Model变量的变化与界面关联，所以非常容易应用Model-View-ViewModel 框架。通过引入ViewModel层，然后用RAC将ViewModel与View关联，View层的变化可以直接响应ViewModel层的变化，这使得Controller变得更加简单，由于View不再与Model绑定，也增加了View的可重用性。
 
 RAC主要解决了三个问题：
 传统iOS开发过程中，状态以及状态之间依赖过多的问题
 传统MVC架构的问题：Controller比较复杂，可测试性差
 提供统一的消息传递机制。
 
 举例:
 聊天页面那个键盘弹出时 input bar 跟随滚动的功能，原来写需要接通知、写回调，现在在一个函数里面用 RAC 就比较方便。
 UI 交互上的点确实好多，比如下拉刷新、上拉导航条变透明。
 实时响应用户的输入，控制按钮的可用性，这点用 RAC 来实现非常简单。
 
 我们主要用来处理界面上的数据显示，以及 UI 的交互操作上，不会用来写代理。

 
 */

/*

 Reactive Cocoa :函数响应式编程     http://limboy.me/tech/2013/06/19/frp-reactivecocoa.html
 
 ReactiveCocoa是github一个开源的项目，是在iOS平台上对FRP(响应式编程)的实现。
 FRP的核心是信号，信号在ReactiveCocoa(以下简称RAC)中是通过RACSignal来表示的，信号是数据流，可以被绑定和传递。
 
 非常棒的形容!!!
 
 可以把信号想象成水龙头，只不过里面不是水，而是玻璃球(value)，直径跟水管的内径一样，这样就能保证玻璃球是依次排列，不会出现并排的情况(数据都是线性处理的，不会出现并发情况)。
 水龙头的开关默认是关的，除非有了接收方(subscriber)，才会打开。这样只要有新的玻璃球进来，就会自动传送给接收方。
 可以在水龙头上加一个过滤嘴(filter)，不符合的不让通过，
 可以加一个改动装置，把球改变成符合自己的需求(map)。
 可以把多个水龙头合并成一个新的水龙头(combineLatest:reduce:)，这样只要其中的一个水龙头有玻璃球出来，这个新合并的水龙头就会得到这个球。

 ReactiveCocoa由两大主要部分组成：signals (RACSignal) 和 sequences (RACSequence)(序列的意思)。
 
 signal 和 sequence 都是streams，他们共享很多相同的方法。
 signal是push驱动的stream，sequence是pull驱动的stream。
 
 
 RACSignal
 
 异步控制或事件驱动的数据源：Cocoa编程中大多数时候会关注用户事件或应用状态改变产生的响应。
 
 链式以来操作：网络请求是最常见的依赖性样例，前一个对server的请求完成后，下一个请求才能构建。
 
 并行独立动作：独立的数据集要并行处理，随后还要把他们合并成一个最终结果。这在Cocoa中很常见，特别是涉及到同步动作时。
 
 Signal会触发它们的subscriber三种不同类型的事件：
 
 下一个事件从stream中提供一个新值。不像Cocoa集合，它是完全可用的，甚至一个signal可以包含 nil。
 
 错误事件会在一个signal结束之前被标示出来这里有一个错误。这种事件可能包含一个 NSError 对象来标示什么发生了错误。错误必须被特殊处理——错误不会被包含在stream的值里面。
 
 完成事件标示signal成功结束，不会再有新的值会被加入到stream当中。完成事件也必须被单独控制——它不会出现在stream的值里面。
 一个signal的生命由很多下一个(next)事件和一个错误(error)或完成(completed)事件组成（后两者不同时出现）。
 
 
 
 使用时需要注意循环引用，@weakify(self) / @strongify(self) 组合解除循环引用；
 
 
//多个TextField 判断全部达到一定条件 才可以点击按钮
 //-----------RAC做法:   每次不论哪个输入框被修改了，用户的输入都会被reduce成一个布尔值，然后就可以自动来控制注册按钮的可用状态了。
 RACSignal *formValid = [RACSignal
     combineLatest:@[
         self.username.rac_textSignal,
         self.emailField.rac_textSignal,
         self.passwordField.rac_textSignal,
         self.passwordVerificationField.rac_textSignal
 ]
 reduce:^(NSString *username, NSString *email, NSString *password, NSString *passwordVerification) {
    return @([username length] > 0 && [email length] > 0 && [password length] > 8 && [password isEqual:passwordVerification]);
 }];
 
 RAC(self.createButton.enabled) = formValid;
 
 
 
 //-----------传统做法
 - (BOOL)isFormValid {
     return [self.usernameField.text length] > 0 &&
     [self.emailField.text length] > 0 &&
     [self.passwordField.text length] > 0 &&
     [self.passwordField.text isEqual:self.passwordVerificationField.text];
 }
 
 #pragma mark - UITextFieldDelegate
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

     self.createButton.enabled = [self isFormValid];
     return YES;
 }
 
 */
