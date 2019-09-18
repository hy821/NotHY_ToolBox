//
//  LJDataBaseManager.m
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import "LJDataBaseManager.h"
#import "MOBCoreDataHelper.h"
#import "LJCacheModel+CoreDataClass.h"
#import "LJDownloadManager.h"
#import "LJDownloadModel.h"
#import "LJTool.h"
#import "LJConst.h"
#import "FMDB.h"

static NSString *const CacheTableName = @"LJDownloadDemo";
static NSString *const CacheModelName = @"LJCacheModel";

typedef NS_ENUM(NSInteger, LJDBGetDateOption) {
    LJDBGetDateOptionAllCacheData = 0,      // 所有缓存数据
    LJDBGetDateOptionAllDownloadingData,    // 所有正在下载的数据
    LJDBGetDateOptionAllDownloadedData,     // 所有下载完成的数据
    LJDBGetDateOptionAllUnDownloadedData,   // 所有未下载完成的数据
    LJDBGetDateOptionAllWaitingData,        // 所有等待下载的数据
    LJDBGetDateOptionModelWithUrl,          // 通过url获取单条数据
    LJDBGetDateOptionWaitingModel,          // 第一条等待的数据
    LJDBGetDateOptionLastDownloadingModel,  // 最后一条正在下载的数据
};

@interface LJDataBaseManager ()

/**
 *  数据访问器，用于存取本地存储数据
 */
@property (nonatomic, strong) MOBCoreDataHelper *dataAccessor;

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation LJDataBaseManager

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
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("LJDatabaseQueue", DISPATCH_QUEUE_SERIAL);
        [self _setupDataStore];
    }
    return self;
}
 
// 初始化数据存储
- (void)_setupDataStore
{
    self.dataAccessor = [[MOBCoreDataHelper alloc] initWithDataModel:CacheTableName];
}

- (void)insertModel:(LJDownloadModel *)model
{
    dispatch_sync(_queue, ^{
        LJCacheModel *cacheModel = [self.dataAccessor createObjectWithName:CacheModelName];
        [cacheModel conversionDownloadModel:model];
        [self.dataAccessor flush:nil];
    });
}

// 获取单条数据
- (LJDownloadModel *)getModelWithUrl:(NSString *)url
{
    return [self getModelWithOption:LJDBGetDateOptionModelWithUrl url:url];
}

// 获取第一条等待的数据
- (LJDownloadModel *)getWaitingModel
{
    return [self getModelWithOption:LJDBGetDateOptionWaitingModel url:nil];
}

// 获取最后一条正在下载的数据
- (LJDownloadModel *)getLastDownloadingModel
{
    return [self getModelWithOption:LJDBGetDateOptionLastDownloadingModel url:nil];
}

// 获取所有数据
- (NSArray<LJDownloadModel *> *)getAllCacheData
{
    return [self getDataWithOption:LJDBGetDateOptionAllCacheData];
}

// 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<LJDownloadModel *> *)getAllDownloadingData
{
    return [self getDataWithOption:LJDBGetDateOptionAllDownloadingData];
}

// 获取所有下载完成的数据
- (NSArray<LJDownloadModel *> *)getAllDownloadedData
{
    return [self getDataWithOption:LJDBGetDateOptionAllDownloadedData];
}

// 获取所有未下载完成的数据
- (NSArray<LJDownloadModel *> *)getAllUnDownloadedData
{
    return [self getDataWithOption:LJDBGetDateOptionAllUnDownloadedData];
}

// 获取所有等待下载的数据
- (NSArray<LJDownloadModel *> *)getAllWaitingData
{
    return [self getDataWithOption:LJDBGetDateOptionAllWaitingData];
}

// 获取单条数据
- (LJDownloadModel *)getModelWithOption:(LJDBGetDateOption)option url:(NSString *)url
{
    __block LJDownloadModel *model = nil;
    dispatch_sync(_queue, ^{
    
        NSPredicate *condition = nil;
        NSDictionary *sort = nil;
        // 获取所有数据 condition 和 sort 都为 nil
        switch (option)
        {
            case LJDBGetDateOptionModelWithUrl: // 获取单条数据
                condition = [NSPredicate predicateWithFormat:@"url = %@", url];
                break;
                
            case LJDBGetDateOptionWaitingModel: // 获取第一条等待的数据
                condition = [NSPredicate predicateWithFormat:@"state = %@", [NSNumber numberWithInteger:LJDownloadStateWaiting]];
                sort = @{ @"lastStateTime": MOBSORT_ASC };
                break;
                
            case LJDBGetDateOptionLastDownloadingModel:// 获取最后一条正在下载的数据
                condition = [NSPredicate predicateWithFormat:@"state = %@", [NSNumber numberWithInteger:LJDownloadStateDownloading]];
                sort = @{ @"lastStateTime": MOBSORT_DESC };
                break;
                
            default:
                break;
        }
        NSArray *models = [self.dataAccessor selectObjectsWithEntityName:CacheModelName
                                                               condition:condition
                                                                    sort:sort
                                                                   error:nil];
        LJCacheModel *cModel = models.firstObject;
        if (cModel)
        {
            model = [[LJDownloadModel alloc] initWithCacheModel:cModel];
        }
    });
    return model;
}

// 获取数据集合
- (NSArray<LJDownloadModel *> *)getDataWithOption:(LJDBGetDateOption)option
{
    __block NSArray<LJDownloadModel *> *array = nil;
    
    dispatch_sync(_queue, ^{
    
        NSPredicate *condition = nil;
        NSDictionary *sort = nil;
        switch (option)
        {
            case LJDBGetDateOptionAllDownloadingData:// 根据lastStateTime倒叙获取所有正在下载的数据
            {
                condition = [NSPredicate predicateWithFormat:@"state = %@", [NSNumber numberWithInteger:LJDownloadStateDownloading]];
                sort = @{ @"lastStateTime": MOBSORT_DESC };
                break;
            }
                
            case LJDBGetDateOptionAllDownloadedData:// 获取所有下载完成的数据
            {
                condition = [NSPredicate predicateWithFormat:@"state = %@", [NSNumber numberWithInteger:LJDownloadStateFinish]];
                break;
            }
                
            case LJDBGetDateOptionAllUnDownloadedData:// 获取所有未下载完成的数据
            {
                condition = [NSPredicate predicateWithFormat:@"state != %@", [NSNumber numberWithInteger:LJDownloadStateFinish]];
                break;
            }
                
            case LJDBGetDateOptionAllWaitingData:// 获取所有等待下载的数据
            {
                condition = [NSPredicate predicateWithFormat:@"state = %@", [NSNumber numberWithInteger:LJDownloadStateWaiting]];
                break;
            }
                
            default:
                break;
        }
        
        NSArray *models = [self.dataAccessor selectObjectsWithEntityName:CacheModelName
                                                               condition:condition
                                                                    sort:sort
                                                                   error:nil];
        NSMutableArray *dModels = [NSMutableArray array];
        for (LJCacheModel *model in models)
        {
            [dModels addObject:[[LJDownloadModel alloc] initWithCacheModel:model]];
        }
       array = [dModels copy];
    });

    return array;
}

- (void)updateWithModel:(LJDownloadModel *)model option:(LJDBUpdateOption)option
{
    dispatch_sync(_queue, ^{
    
        if (option & LJDBUpdateOptionState)
        {
            [self postStateChangeNotificationWithModel:model];
            LJCacheModel *cModel = [self _getCacheModelWithUrl:model.url];
            cModel.state = model.state;
            [self.dataAccessor flush:nil];
        }
        
        if (option & LJDBUpdateOptionLastStateTime)
        {
            LJCacheModel *cModel = [self _getCacheModelWithUrl:model.url];
            cModel.lastStateTime = [LJTool getTimeStampWithDate:[NSDate date]];
            [self.dataAccessor flush:nil];
        }
        
        if (option & LJDBUpdateOptionResumeData)
        {
            LJCacheModel *cModel = [self _getCacheModelWithUrl:model.url];
            cModel.resumeData = model.resumeData;
            [self.dataAccessor flush:nil];
        }
        
        if (option & LJDBUpdateOptionProgressData)
        {
            LJCacheModel *cModel = [self _getCacheModelWithUrl:model.url];
            cModel.tmpFileSize = model.tmpFileSize;
            cModel.totalFileSize = model.totalFileSize;
            cModel.progress = model.progress;
            cModel.lastSpeedTime = model.lastSpeedTime;
            cModel.intervalFileSize = model.intervalFileSize;
            [self.dataAccessor flush:nil];
        }
        
        if (option & LJDBUpdateOptionAllParam)
        {
            [self postStateChangeNotificationWithModel:model];
            LJCacheModel *cModel = [self _getCacheModelWithUrl:model.url];
            cModel.resumeData = model.resumeData;
            cModel.totalFileSize = model.totalFileSize;
            cModel.tmpFileSize = model.tmpFileSize;
            cModel.progress = model.progress;
            cModel.state = model.state;
            cModel.lastSpeedTime = model.lastSpeedTime;
            cModel.intervalFileSize = model.intervalFileSize;
            cModel.lastStateTime = [LJTool getTimeStampWithDate:[NSDate date]];
            [self.dataAccessor flush:nil];
        }
    });
}

// 状态变更通知
- (void)postStateChangeNotificationWithModel:(LJDownloadModel *)model
{
    // 原状态
    LJCacheModel *cModel = [self _getCacheModelWithUrl:model.url];
    if (cModel.state != model.state)
    {
        // 状态变更通知
        [[NSNotificationCenter defaultCenter] postNotificationName:LJDownloadStateChangeNotification object:model];
    }
}

- (void)deleteModelWithUrl:(NSString *)url
{
    dispatch_sync(_queue, ^{
        LJCacheModel *model = [self _getCacheModelWithUrl:url];
        if (model)
        {
            [self.dataAccessor deleteObject:model];
            [self.dataAccessor flush:nil];
        }
    });
}

- (LJCacheModel *)_getCacheModelWithUrl:(NSString *)url
{
    __block LJCacheModel *model = nil;
    NSPredicate *condition = [NSPredicate predicateWithFormat:@"url = %@", url];
    NSArray *models = [self.dataAccessor selectObjectsWithEntityName:CacheModelName
                                                           condition:condition
                                                                sort:nil
                                                               error:nil];
    model = models.firstObject;
    return model;
}

@end
