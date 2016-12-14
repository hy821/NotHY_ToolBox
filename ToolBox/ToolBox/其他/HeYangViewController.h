//
//  HeYangViewController.h
//  ToolBox
//
//  Created by ZRBhy on 16/12/14.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import <UIKit/UIKit.h>

//关于Block------block具有一个函数的外观，又被当作一个变量。
//那么Block就具备两个功能，第一：可以作为类的属性被'点'出来。第二：可以当作函数直接调用.

//returnType  (^name)  (val1, val2, ...)
//返回类型     变量名        参数列表

//无返回值Block
typedef void (^MyBlock)(NSString *);
//有返回值Block
typedef NSString* (^MyBlockk)(NSString *);

//可以使用block来实现链式编程.

//--------------------------------------------------------------

@interface HeYangViewController : UIViewController

//Block 使用Copy修饰,
//　这里解释一下为什么用copy，block这种类型本来是值类型的，他本来是在栈上的，在ARC环境下如果被任何强指针过了一次，编译器就会把他进行一次copy，放到堆内存中。block的retain行为默认是用copy的行为实现的，因为block变量默认是声明为栈变量的，为了能够在block的声明域外使用应该使用copy。
@property (nonatomic, copy) MyBlock myblock;

@end
