//
//  KVO&KVC.h
//  ToolBox
//
//  Created by Hy on 2018/7/6.
//  Copyright © 2018年 NotHY. All rights reserved.
//

// KVO  (观察者模式) : 观察某个对象的某个属性

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

 */





