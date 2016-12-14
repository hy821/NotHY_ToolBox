//
//  BaseProtocol.h
//  
//
//  Created by ZRBhy on 16/12/14.
//
//

#import <Foundation/Foundation.h>

@protocol BaseProtocol <NSObject>

@end


/*
 //------------->Protocol(协议)

 创建Protocol: command + N ---> Objective-C File --->选择protocol  (Category也是在这里创建)  Protocol名字一般写AbcProtocol
 文章推荐: http://blog.csdn.net/aas319/article/details/53205026   
 深入学习:   http://rypress.com/tutorials/objective-c/protocols
 
 Protocol 仅仅是一种声明，它可以声明方法、属性，然后在需要的类中遵循它。
 protocol 是可以继承的
 先有 Protocol 再有 Delegate.   大部分人是通过 Delegate 接触的Protocol
 protocol 如果声明了属性，在使用这个协议的时候，类的实现里面需要自己去实现 setter getter 方法，当然也可以 @synthesize 来自动生成。(参考基类的Protocol)
 
 @required; 是必须实现的，如果遵循了这个协议，就必须实现其下方的方法和 属性(.m里用@synthesize 来自动生成) !  不然会在调用的时候导致 Crash。
 @optional 非必须实现。
 默认不写 required 和 optional 的情况下,都是required.
 
 
 在使用的时候，需要注意这个类是否实现了对应的属性或者方法。
    Person *person = [[Person alloc] init];
    if ([person respondsToSelector:@selector(setName:)]) {
        person.name = @"Kral";
    }
 
 
  //------------->Delegate (代理)
     在使用的时候，需要注意这个类是否实现了对应的属性或者方法。
 
     if ([self.delegate respondsToSelector:@selector(student:didFinishHomework:)]) {
        [self.delegate student:self didFinishHomework:homeWork];
     }
 
 
 代理为啥要用weak修饰? (刨根问底一)
    答案:  避免循环引用,
  
 怎么循环引用了, 到底怎么回事!!!
    答案:  http://www.jianshu.com/p/398472616435
 
 何时用assin何时用weak?
 答案:
    1.weak 此特质表明该属性定义了一种“非拥有关系” (nonowning relationship)。为这种属性设置新值时，设置方法既不保留新值，也不释放旧值。此特质同assign类似， 然而在属性所指的对象遭到摧毁时，属性值也会清空(nil out)。 而 assign 的“设置方法”只会执行针对“纯量类型” (scalar type，例如 CGFloat 或 NSlnteger 等)的简单赋值操作。
 
    2.assigin 可以用非 OC 对象,而 weak 必须用于 OC 对象
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 //--------->补充 爱看不看
 在很多三方库里面，为了不暴露使用的类，会建议使用者这样创建对象：
 id <Person> person = [[Person alloc] init];
 这样创建出来的 person 可以直接使用 <Person> 协议中的属性和方法。
 
 */












