//
//  loginViewModel.m
//  ToolBox
//
//  Created by ZRBhy on 16/12/13.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import "loginViewModel.h"
#import "Networker.h"

@implementation loginViewModel

- (instancetype)init {
    if (self = [super init]) {
        RACSignal *userNameLengthSig = [RACObserve(self, userName)
                                        map:^id(NSString *value) {
                                            if (value.length > 6) return @(YES);
                                            return @(NO);
                                        }];
        RACSignal *passwordLengthSig = [RACObserve(self, password)
                                        map:^id(NSString *value) {
                                            if (value.length > 6) return @(YES);
                                            return @(NO);
                                        }];
        RACSignal *loginBtnEnable = [RACSignal combineLatest:@[userNameLengthSig, passwordLengthSig] reduce:^id(NSNumber *userName, NSNumber *password){
            return @([userName boolValue] && [password boolValue]);
        }];
        _loginCommand = [[RACCommand alloc]initWithEnabled:loginBtnEnable signalBlock:^RACSignal *(id input) {
            return [Networker loginWithUserName:self.userName password:self.password];
        }];
    }
    return self;
}

@end
