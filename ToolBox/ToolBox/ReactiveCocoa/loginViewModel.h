//
//  loginViewModel.h
//  ToolBox
//
//  Created by ZRBhy on 16/12/13.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface loginViewModel : NSObject

@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, strong, readonly) RACCommand *loginCommand;

@end
