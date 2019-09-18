//
//  LJNetworkManager.m
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/18.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import "LJNetworkManager.h"
#import <MOBFoundation/MOBFDevice.h>
#import "LJConst.h"

@interface LJNetworkManager ()

@property (nonatomic, assign) MOBFNetworkType networkStatus;

@end

@implementation LJNetworkManager

+ (instancetype)shareInstance
{
    static LJNetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.networkStatus = [MOBFDevice currentNetworkType];
    });
    return instance;
}

- (void)networkChange
{
    MOBFNetworkType status = [MOBFDevice currentNetworkType];
    if (_networkStatus != status)
    {
        _networkStatus = status;
        // 网络改变通知
        [[NSNotificationCenter defaultCenter] postNotificationName:LJNetworkingReachabilityDidChangeNotification object:[NSNumber numberWithInteger:status]];
    }
}

// 监听网络状态
- (void)monitorNetworkStatus
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChange)
                                                 name:kMOBFReachabilityChangedNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
