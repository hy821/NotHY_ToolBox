//
//  LJDataBaseManager.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJDownloadModel;

typedef NS_OPTIONS(NSUInteger, LJDBUpdateOption) {
    LJDBUpdateOptionState         = 1 << 0,  // 更新状态
    LJDBUpdateOptionLastStateTime = 1 << 1,  // 更新状态最后改变的时间
    LJDBUpdateOptionResumeData    = 1 << 2,  // 更新下载的数据
    LJDBUpdateOptionProgressData  = 1 << 3,  // 更新进度数据（包含tmpFileSize、totalFileSize、progress、intervalFileSize、lastSpeedTime）
    LJDBUpdateOptionAllParam      = 1 << 4   // 更新全部数据
};

@interface LJDataBaseManager : NSObject

// 获取单例
+ (instancetype)shareInstance;

// 插入数据
- (void)insertModel:(LJDownloadModel *)model;

// 获取单条数据
- (LJDownloadModel *)getModelWithUrl:(NSString *)url;    // 根据url获取数据
- (LJDownloadModel *)getWaitingModel;                    // 获取第一条等待的数据
- (LJDownloadModel *)getLastDownloadingModel;            // 获取最后一条正在下载的数据

// 获取多条数据
- (NSArray<LJDownloadModel *> *)getAllCacheData;         // 获取所有数据
- (NSArray<LJDownloadModel *> *)getAllDownloadingData;   // 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<LJDownloadModel *> *)getAllDownloadedData;    // 获取所有下载完成的数据
- (NSArray<LJDownloadModel *> *)getAllUnDownloadedData;  // 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）
- (NSArray<LJDownloadModel *> *)getAllWaitingData;       // 获取所有等待下载的数据

// 更新数据
- (void)updateWithModel:(LJDownloadModel *)model option:(LJDBUpdateOption)option;

// 删除数据
- (void)deleteModelWithUrl:(NSString *)url;

@end
