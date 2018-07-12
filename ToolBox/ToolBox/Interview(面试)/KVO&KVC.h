//
//  KVO&KVC.h
//  ToolBox
//
//  Created by Hy on 2018/7/6.
//  Copyright © 2018年 NotHY. All rights reserved.
//

 KVO  (观察者模式) : 观察某个对象的某个属性
/*

属性：是一种封装,包括: _name成员变量 + getter方法 + setter方法
KVO底层原理：观察的不是成员变量_name,观察的是setter方法，

第一步：
利用runtime动态创建一个类NSKVONotifying_Person 继承于要观察的类，重写set方法；
(重写的setter方法里执行的代码，会触发外面KVO的监听代码)

 - (void)setName:(NSString *)name {
        [self willChangeValueForKey:@"name"];   // (重写的setter方法里执行的代码，会触发外面KVO的监听代码)
        [super setName:name];
        [self didChangeValueForKey:@"name"];   // (重写的setter方法里执行的代码，会触发外面KVO的监听代码)
 }
 
第二步：
改变观察对象的类为子类类型(NSKVONotifyin_Person),这样才可以调用子类重写的setter方法。
把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就变成新创建的子类的实例了。
 */


进阶：系统的KVO不好用，自定义一个

KVO 缺陷：
比如，你只能通过重写 -observeValueForKeyPath:ofObject:change:context: 方法来获得通知。
想要提供自定义的 selector ，不行；想要传一个 block ，门都没有。
而且你还要处理父类的情况 - 父类同样监听同一个对象的同一个属性。但有时候，你不知道父类是不是对这个消息有兴趣。
虽然 context 这个参数就是干这个的，也可以解决这个问题 - 在 -addObserver:forKeyPath:options:context: 传进去一个父类不知道的context。
但总觉得框在这个 API 的设计下，代码写的很别扭。至少至少，也应该支持 block 吧。

有不少人都觉得官方 KVO 不好使的。
Mike Ash 的 Key-Value Observing Done Right，以及获得不少分享讨论的 KVO Considered Harmful 都把 KVO 拿出来吊打了一番。
所以在实际开发中 KVO 使用的情景并不多，更多时候还是用 Delegate 或 NotificationCenter。"

//  http://tech.glowing.com/cn/implement-kvo/
//  作为 demo 演示如何利用 Runtime 动态创建类、如何实现 KVO，足已。




KVC : Key Value Coding(键值编码)
间接修改/获取对象的属性, 降低类与类之间的耦合度.
1,   [p1 setValue:@"xxxx" forKeyPath:@"name"];

2,  [person1 setValue:@"iPhone" forKeyPath:@"book.bookName"];
    //person1的book也是一个类, book里的属性bookName， KVC可以直接修改。

3, //获取对象的属性值. 可批量获取(如果是数组的话).
- (void)kvcDemo4 {
    XNStudent *p1 = [[XNStudent alloc] init]; //学生1
    p1.name = @"student1 xuneng";
    p1.age = 24;
    XNBook *myBook1 = [[XNBook alloc] init];
    myBook1.bookName = @"iOS";
    p1.book = myBook1;
    
    XNStudent *p2 = [[XNStudent alloc] init]; //学生2
    p2.name = @"student2 xuneng";
    p2.age = 23;
    XNBook *myBook2 = [[XNBook alloc] init];
    myBook2.bookName = @"iPhone";
    p2.book = myBook2;
    
    NSArray *arr = @[p1, p2];
    
    //1.普通方法获取数组中对象的属性
    NSMutableArray *arrBook = [[NSMutableArray alloc] init];
    for (XNStudent *stu in arr) {
        [arrBook addObject:stu.book.bookName];
    }
    NSLog(@"KVC1 demo4--> %@", arrBook);
    
    //2.KVC方法来获取数组中对象
    NSLog(@"KVC2 demo4--> %@", [arr valueForKeyPath:@"book.bookName"]);
}



