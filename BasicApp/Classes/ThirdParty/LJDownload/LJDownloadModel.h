//
//  LJDownloadModel.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/18.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LJDownloadManager.h"

@class LJCacheModel, FMResultSet;

@interface LJDownloadModel : NSObject

@property (nonatomic, copy) NSString *localPath;            // 下载完成路径
@property (nonatomic, copy) NSString *vid;                  // 唯一id标识
@property (nonatomic, copy) NSString *fileName;             // 文件名
@property (nonatomic, copy) NSString *url;                  // url
@property (nonatomic, strong) NSData *resumeData;           // 下载的数据
@property (nonatomic, assign) CGFloat progress;             // 下载进度
@property (nonatomic, assign) LJDownloadState state;        // 下载状态
@property (nonatomic, assign) NSUInteger totalFileSize;     // 文件总大小
@property (nonatomic, assign) NSUInteger tmpFileSize;       // 下载大小
@property (nonatomic, assign) NSUInteger speed;             // 下载速度
@property (nonatomic, assign) NSUInteger lastSpeedTime;     // 上次计算速度时的时间戳
@property (nonatomic, assign) NSUInteger intervalFileSize;  // 计算速度时间内下载文件的大小
@property (nonatomic, assign) NSUInteger lastStateTime;     // 记录任务加入准备下载的时间（点击默认、暂停、失败状态），用于计算开始、停止任务的先后顺序

- (void)conversionCacheModel:(LJCacheModel *)model;

- (instancetype)initWithCacheModel:(LJCacheModel *)model;

- (instancetype)initWithDict:(NSDictionary *)dict;

// 根据数据库查询结果初始化
- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet;


//Add----
- (instancetype)initWithModel:(VDCommonModel*)model;
@property (nonatomic,copy) NSString *pi;
@property (nonatomic,copy) NSString *pt;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,assign) BOOL m3u8;
@property (nonatomic,assign) BOOL isEncrypted;
@property (nonatomic,copy) NSString *albumId;  //相册id, 多集数对应同一个    pi
@property (nonatomic,copy) NSString *mediaId;  //唯一标识, 每个电影,每一集对应唯一  idForModel
@property (nonatomic,assign) VideoType videoType;
@property (nonatomic,copy) NSString *detailUrl; // analysis/url/1  掉接口 取最新下载地址
@property (nonatomic,copy) NSString *analyseUrl; // analysis/url/1 接口获取的下载地址. 可能会失效
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *cover;  //封面图的Url
//@property (nonatomic,assign) CacheStatusType status;
@property (nonatomic,copy) NSString *secretInfo;  //秘钥信息, 下载时, 解析视频时用到  暂时用不到
@property (nonatomic,copy) NSString *source;  //siCurrent  来源id
@property (nonatomic,copy) NSString *labelIds;   //categoryResults   用 , 拼接id
@property (nonatomic,copy) NSString *engine;   //MediaSource.ParseEngine engine;
@property (nonatomic,copy) NSString *indexForEpisode;  //如果是多集的, index是当前集数,第几集

@end
