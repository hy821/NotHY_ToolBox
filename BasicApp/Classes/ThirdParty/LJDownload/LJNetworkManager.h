//
//  LJNetworkManager.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/18.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MOBFoundation/MOBFoundation.h>

@interface LJNetworkManager : NSObject

// 当前网络状态
@property (nonatomic, assign, readonly) MOBFNetworkType networkStatus;

// 获取单例
+ (instancetype)shareInstance;

// 监听网络状态
- (void)monitorNetworkStatus;

@end
