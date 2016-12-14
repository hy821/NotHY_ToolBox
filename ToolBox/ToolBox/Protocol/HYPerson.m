//
//  HYPerson.m
//  ToolBox
//
//  Created by ZRBhy on 16/12/14.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import "HYPerson.h"
#import "HYDog.h"

@interface HYPerson ()<HYDogDelegate>

@property (nonatomic, strong) HYDog *dog;

@end

@implementation HYPerson

- (instancetype)init {
    self = [super init];
    if (self) {
        // 实例化dog
        self.dog = [[HYDog alloc] init];
        // dog的delegate引用self,self的retainCount，取决于delegate修饰，weak：retainCount不变，strong：retainCount + 1
        self.dog.delegate = self;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"HYPerson----销毁");
}


@end
