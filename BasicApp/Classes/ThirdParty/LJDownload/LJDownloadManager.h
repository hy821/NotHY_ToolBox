//
//  LJDownloadManager.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJDownloadModel;

typedef NS_ENUM(NSInteger, LJDownloadState) {
    LJDownloadStateDefault = 0,  // 默认
    LJDownloadStateDownloading,  // 正在下载
    LJDownloadStateWaiting,      // 等待
    LJDownloadStatePaused,       // 暂停
    LJDownloadStateFinish,       // 完成
    LJDownloadStateError,        // 错误
};

@interface LJDownloadManager : NSObject

// 获取单例
+ (instancetype)shareInstance;

// 开始下载
- (void)startDownloadTask:(LJDownloadModel *)model;

// 暂停下载
- (void)pauseDownloadTask:(LJDownloadModel *)model;

// 删除下载任务及本地缓存
- (void)deleteTaskAndCache:(LJDownloadModel *)model;

// 下载时，杀死进程，更新所有正在下载的任务为等待
- (void)updateDownloadingTaskState;

// 重启时开启等待下载的任务
- (void)openDownloadTask;

// 是否允许下载任务    无网络 或 （当前为蜂窝网络，且不允许蜂窝网络下载）
- (BOOL)networkingAllowsDownloadTask;

@end
