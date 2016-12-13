//
//  Networker.m
//  ToolBox
//
//  Created by ZRBhy on 16/12/13.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import "Networker.h"

@implementation Networker

+ (RACSignal *)loginWithUserName:(NSString *)name password:(NSString *)password {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:[NSString stringWithFormat:@"User %@, password %@, login!",name, password]];
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

@end
