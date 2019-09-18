//
//  LJDownloadManager.m
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import "LJDownloadManager.h"
#import "LJDownloadModel.h"
#import "LJDataBaseManager.h"
#import "AppDelegate.h"
#import "NSURLSession+CorrectedResumeData.h"
#import "LJTool.h"
#import "LJConst.h"
#import <MOBFoundation/MOBFDevice.h>
#import "LJNetworkManager.h"
#import "Reachability.h"

@interface LJDownloadManager () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;             // NSURLSession
@property (nonatomic, strong) NSMutableDictionary *dataTaskDic;  // 同时下载多个文件，需要创建多个NSURLSessionDownloadTask，用该字典来存储
@property (nonatomic, assign) NSInteger currentCount;            // 当前正在下载的个数
@property (nonatomic, assign) NSInteger maxConcurrentCount;      // 最大同时下载数量
@property (nonatomic, assign) BOOL allowsCellularAccess;         // 是否允许蜂窝网络下载

@end

@implementation LJDownloadManager

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        // 初始化
        _currentCount = 0;
        //        _maxConcurrentCount = [[NSUserDefaults standardUserDefaults] integerForKey:LJDownloadMaxConcurrentCountKey];
        _maxConcurrentCount = [USER_MANAGER getMaxDownloadCount];
        _allowsCellularAccess = [[NSUserDefaults standardUserDefaults] boolForKey:LJDownloadAllowsCellularAccessKey];
        _dataTaskDic = [NSMutableDictionary dictionary];
        
        // 单线程代理队列
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        
        // 后台下载标识
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"LJDownloadBackgroundSessionIdentifier"];
        
        // 允许蜂窝网络下载，默认为YES，这里开启，我们添加了一个变量去控制用户切换选择
        configuration.allowsCellularAccess = YES;
        
        // 创建NSURLSession，配置信息、代理、代理线程
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
        
        // 最大下载并发数变更通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadMaxConcurrentCountChange:) name:LJDownloadMaxConcurrentCountChangeNotification
                                                   object:nil];
        // 是否允许蜂窝网络下载改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadAllowsCellularAccessChange:) name:LJDownloadAllowsCellularAccessChangeNotification
                                                   object:nil];
        // 网络改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkingReachabilityDidChange:) name:kReachabilityChangedNotification
                                                   object:nil];
    }
    
    return self;
}

// 加入准备下载任务
- (void)startDownloadTask:(LJDownloadModel *)model
{
    // 取出数据库中模型数据，如果不存在，添加到数据库中
    LJDownloadModel *downloadModel = [[LJDataBaseManager shareInstance] getModelWithUrl:model.url];
    if (!downloadModel)
    {
        downloadModel = model;
        [[LJDataBaseManager shareInstance] insertModel:downloadModel];
    }
    
    // 更新状态为等待下载
    downloadModel.state = LJDownloadStateWaiting;
    [[LJDataBaseManager shareInstance] updateWithModel:downloadModel option:LJDBUpdateOptionState | LJDBUpdateOptionLastStateTime];
    
    // 下载
    if (_currentCount < _maxConcurrentCount && [self networkingAllowsDownloadTask])
    {
        [self downloadWithModel:downloadModel];
    }
}

// 开始下载
- (void)downloadWithModel:(LJDownloadModel *)model
{
    // 更新状态为开始
    model.state = LJDownloadStateDownloading;
    [[LJDataBaseManager shareInstance] updateWithModel:model option:LJDBUpdateOptionState];
    _currentCount++;
    
    // 创建NSURLSessionDownloadTask
    NSURLSessionDownloadTask *downloadTask;
    
    if (model.resumeData)
    {
        //Old
        //        CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
        //        if (version >= 10.0 && version < 10.2)
        //        {
        //            downloadTask = [_session downloadTaskWithCorrectResumeData:model.resumeData];
        //        }
        //        else
        //        {
        //            downloadTask = [_session downloadTaskWithResumeData:model.resumeData];
        //        }
        //New  --- 去里面判断
        downloadTask = [_session downloadTaskWithCorrectResumeData:model.resumeData];
    }
    else
    {
        downloadTask = [_session downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:model.url]]];
    }
    
    // 添加描述标签
    downloadTask.taskDescription = model.url;
    
    // 更新存储的NSURLSessionDownloadTask对象
    [_dataTaskDic setValue:downloadTask forKey:model.url];
    
    // 启动（继续下载）
    [downloadTask resume];
}

// 暂停下载
- (void)pauseDownloadTask:(LJDownloadModel *)model
{
    // 取最新数据
    LJDownloadModel *downloadModel = [[LJDataBaseManager shareInstance] getModelWithUrl:model.url];
    
    // 取消任务
    [self cancelTaskWithModel:downloadModel delete:NO];
    
    // 更新数据库状态为暂停
    downloadModel.state = LJDownloadStatePaused;
    [[LJDataBaseManager shareInstance] updateWithModel:downloadModel option:LJDBUpdateOptionState];
}

// 删除下载任务及本地缓存
- (void)deleteTaskAndCache:(LJDownloadModel *)model
{
    // 如果正在下载，取消任务
    [self cancelTaskWithModel:model delete:YES];
    
    // 删除本地缓存、数据库数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //Add---
        NSString *okPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:model.localPath];
        //New
        [[NSFileManager defaultManager] removeItemAtPath:okPath error:nil];
        
        //Old
        //        [[NSFileManager defaultManager] removeItemAtPath:model.localPath error:nil];
        
        [[LJDataBaseManager shareInstance] deleteModelWithUrl:model.url];
    });
}

// 取消任务
- (void)cancelTaskWithModel:(LJDownloadModel *)model delete:(BOOL)delete
{
    if (model.state == LJDownloadStateDownloading)
    {
        // 获取NSURLSessionDownloadTask
        NSURLSessionDownloadTask *downloadTask = [_dataTaskDic valueForKey:model.url];
        
        // 取消任务
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            // 更新下载数据
            model.resumeData = resumeData;
            [[LJDataBaseManager shareInstance] updateWithModel:model option:LJDBUpdateOptionResumeData];
            
            // 更新当前正在下载的个数
            if (self.currentCount > 0)
            {
                self.currentCount--;
            }
            
            // 开启等待下载任务
            [self startDownloadWaitingTask];
        }];
        
        // 移除字典存储的对象
        if (delete)
        {
            [_dataTaskDic removeObjectForKey:model.url];
        }
    }
}

// 开启等待下载任务
- (void)startDownloadWaitingTask
{
    if (_currentCount < _maxConcurrentCount && [self networkingAllowsDownloadTask])
    {
        // 获取下一条等待的数据
        LJDownloadModel *model = [[LJDataBaseManager shareInstance] getWaitingModel];
        
        if (model)
        {
            // 下载
            [self downloadWithModel:model];
            
            // 递归，开启下一个等待任务
            [self startDownloadWaitingTask];
        }
    }
}

// 下载时，杀死进程，更新所有正在下载的任务为等待
- (void)updateDownloadingTaskState
{
    NSArray *downloadingData = [[LJDataBaseManager shareInstance] getAllDownloadingData];
    for (LJDownloadModel *model in downloadingData)
    {
        model.state = LJDownloadStateWaiting;
        [[LJDataBaseManager shareInstance] updateWithModel:model option:LJDBUpdateOptionState];
    }
}

// 重启时开启等待下载的任务
- (void)openDownloadTask
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startDownloadWaitingTask];
    });
}

// 停止正在下载任务为等待状态
- (void)pauseDownloadingTaskWithAll:(BOOL)all
{
    // 获取正在下载的数据
    NSArray *downloadingData = [[LJDataBaseManager shareInstance] getAllDownloadingData];
    NSInteger count = all ? downloadingData.count : downloadingData.count - _maxConcurrentCount;
    for (NSInteger i = 0; i < count; i++)
    {
        // 取消任务
        LJDownloadModel *model = downloadingData[i];
        [self cancelTaskWithModel:model delete:YES];
        
        // 更新状态为等待
        model.state = LJDownloadStateWaiting;
        [[LJDataBaseManager shareInstance] updateWithModel:model option:LJDBUpdateOptionState];
    }
}

#pragma mark - NSURLSessionDownloadDelegate
// 接收到服务器返回数据，会被调用多次
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // 获取模型
    LJDownloadModel *model = [[LJDataBaseManager shareInstance] getModelWithUrl:downloadTask.taskDescription];
    
    // 更新当前下载大小
    model.tmpFileSize = totalBytesWritten;
    model.totalFileSize = totalBytesExpectedToWrite;
    
    // 计算速度时间内下载文件的大小
    model.intervalFileSize += bytesWritten;
    
    // 获取上次计算时间与当前时间间隔
    NSInteger intervals = [LJTool getIntervalsWithTimeStamp:model.lastSpeedTime];
    if (intervals >= 1)
    {
        // 计算速度
        model.speed = model.intervalFileSize / intervals;
        
        // 重置变量
        model.intervalFileSize = 0;
        model.lastSpeedTime = [LJTool getTimeStampWithDate:[NSDate date]];
    }
    
    // 计算进度
    model.progress = 1.0 * model.tmpFileSize / model.totalFileSize;
    
    // 更新数据库中数据
    [[LJDataBaseManager shareInstance] updateWithModel:model option:LJDBUpdateOptionProgressData];
    
    // 进度通知
    [[NSNotificationCenter defaultCenter] postNotificationName:LJDownloadProgressNotification object:model];
}

// 下载完成
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // 获取模型
    LJDownloadModel *model = [[LJDataBaseManager shareInstance] getModelWithUrl:downloadTask.taskDescription];
    
    NSLog(@"%@", [location path]);
    
    // 移动文件，原路径文件由系统自动删除
    NSError *error = nil;
    
    //Add---
    NSString *okPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:model.localPath];
    //New
    [[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:okPath error:&error];
    
    //Old
    //    [[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:model.localPath error:&error];
    
    
    if (error) NSLog(@"下载完成，移动文件发生错误：%@", error);
}

#pragma mark - NSURLSessionTaskDelegate
// 请求完成
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    // 调用cancel方法直接返回，在相应操作是直接进行处理
    if (error && [error.localizedDescription isEqualToString:@"cancelled"])
    {
        return;
    }
    
    // 获取模型
    LJDownloadModel *model = [[LJDataBaseManager shareInstance] getModelWithUrl:task.taskDescription];
    
    // 下载时，进程杀死，重新启动，回调错误
    if (error && [error.userInfo objectForKey:NSURLErrorBackgroundTaskCancelledReasonKey])
    {
        model.state = LJDownloadStateWaiting;
        model.resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        [[LJDataBaseManager shareInstance] updateWithModel:model option:LJDBUpdateOptionState | LJDBUpdateOptionResumeData];
        return;
    }
    
    // 更新下载数据、任务状态
    if (error)
    {
        model.state = LJDownloadStateError;
        model.resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        [[LJDataBaseManager shareInstance] updateWithModel:model option:LJDBUpdateOptionResumeData];
    }
    else
    {
        model.state = LJDownloadStateFinish;
    }
    
    // 更新数据
    if (_currentCount > 0)
    {
        _currentCount--;
    }
    [_dataTaskDic removeObjectForKey:model.url];
    
    // 更新数据库状态
    [[LJDataBaseManager shareInstance] updateWithModel:model option:LJDBUpdateOptionState];
    
    // 开启等待下载任务
    [self startDownloadWaitingTask];
    NSLog(@"\n    文件：%@，下载完成 \n    本地路径：%@ \n    错误：%@ \n", model.fileName, model.localPath, error);
}

#pragma mark - NSURLSessionDelegate
// 应用处于后台，所有下载任务完成及NSURLSession协议调用之后调用
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundSessionCompletionHandler) {
            void (^completionHandler)(void) = appDelegate.backgroundSessionCompletionHandler;
            appDelegate.backgroundSessionCompletionHandler = nil;
            
            // 执行block，系统后台生成快照，释放阻止应用挂起的断言
            completionHandler();
        }
    });
}

#pragma mark - LJDownloadMaxConcurrentCountChangeNotification
- (void)downloadMaxConcurrentCountChange:(NSNotification *)notification
{
    _maxConcurrentCount = [notification.object integerValue];
    
    if (_currentCount < _maxConcurrentCount)
    {
        // 当前下载数小于并发数，开启等待下载任务
        [self startDownloadWaitingTask];
    }
    else if (_currentCount > _maxConcurrentCount)
    {
        // 变更正在下载任务为等待下载
        [self pauseDownloadingTaskWithAll:NO];
    }
}

#pragma mark - LJDownloadAllowsCellularAccessChangeNotification
- (void)downloadAllowsCellularAccessChange:(NSNotification *)notification
{
    _allowsCellularAccess = [notification.object boolValue];
    
    [self allowsCellularAccessOrNetworkingReachabilityDidChangeActionWithTip:NO];
}

#pragma mark - kReachabilityChangedNotification
- (void)networkingReachabilityDidChange:(NSNotification *)notification
{
    [self allowsCellularAccessOrNetworkingReachabilityDidChangeActionWithTip:YES];
}

// 是否允许蜂窝网络下载或网络状态变更事件
- (void)allowsCellularAccessOrNetworkingReachabilityDidChangeActionWithTip:(BOOL)isTip
{
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable)
    {
        //Add---如果有正在下载，显示Tip
        if ([[LJDataBaseManager shareInstance] getLastDownloadingModel] && isTip)
        {
            SSMBToast(@"网络异常,暂停下载", MainWindow);
        }
        
        // 无网络，暂停正在下载任务
        [self pauseDownloadingTaskWithAll:YES];
        
    }
    else
    {
        if ([self networkingAllowsDownloadTask])
        {
            // 开启等待任务
            [self startDownloadWaitingTask];
        }
        else
        {
            // 蜂窝网络情况下如果有正在下载, 加Tip
            if ([[LJDataBaseManager shareInstance] getLastDownloadingModel])
            {
                if (isTip) {
                    SSMBToast(@"移动网络环境, 暂停下载, 可在设置页开启", MainWindow);
                }
            }
            
            // 当前为蜂窝网络，不允许下载，暂停正在下载任务
            [self pauseDownloadingTaskWithAll:YES];
            
        }
    }
}

// 是否允许下载任务 
- (BOOL)networkingAllowsDownloadTask
{
    // 当前网络状态
    NetworkStatus status = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
    
    // 无网络 或 （当前为蜂窝网络，且不允许蜂窝网络下载）
    if (status == NotReachable || (status == ReachableViaWWAN && !_allowsCellularAccess))
    {
        return NO;
    }
    
    return YES;
}

- (void)dealloc
{
    [_session invalidateAndCancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
