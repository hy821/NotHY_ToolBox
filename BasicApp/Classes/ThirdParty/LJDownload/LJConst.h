//
//  LJConst.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/18.
//  Copyright © 2018年 YouZu. All rights reserved.
//

/************************* 下载 *************************/
UIKIT_EXTERN NSString *const LJDownloadProgressNotification;                   // 进度回调通知
UIKIT_EXTERN NSString *const LJDownloadStateChangeNotification;                // 状态改变通知
UIKIT_EXTERN NSString *const LJDownloadMaxConcurrentCountKey;                  // 最大同时下载数量key
UIKIT_EXTERN NSString *const LJDownloadMaxConcurrentCountChangeNotification;   // 最大同时下载数量改变通知
UIKIT_EXTERN NSString *const LJDownloadAllowsCellularAccessKey;                // 是否允许蜂窝网络下载key
UIKIT_EXTERN NSString *const LJDownloadAllowsCellularAccessChangeNotification; // 是否允许蜂窝网络下载改变通知

/************************* 网络 *************************/
UIKIT_EXTERN NSString *const LJNetworkingReachabilityDidChangeNotification;    // 网络改变改变通知
