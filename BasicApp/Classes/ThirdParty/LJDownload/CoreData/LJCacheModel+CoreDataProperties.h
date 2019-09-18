//
//  LJCacheModel+CoreDataProperties.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//
//

#import "LJCacheModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface LJCacheModel (CoreDataProperties)

+ (NSFetchRequest<LJCacheModel *> *)fetchRequest;

/**
 下载完成路径
 */
@property (nullable, nonatomic, copy) NSString *localPath;

/**
 唯一id标识
 */
@property (nullable, nonatomic, copy) NSString *vid;

/**
 文件名
 */
@property (nullable, nonatomic, copy) NSString *fileName;

/**
 url
 */
@property (nullable, nonatomic, copy) NSString *url;

/**
 下载的数据
 */
@property (nullable, nonatomic, retain) NSData *resumeData;

/**
 下载进度
 */
@property (nonatomic) float progress;

/**
 下载状态
 */
@property (nonatomic) NSInteger state;

/**
 文件总大小
 */
@property (nonatomic) NSUInteger totalFileSize;

/**
 下载大小
 */
@property (nonatomic) NSUInteger tmpFileSize;

/**
 下载速度
 */
@property (nonatomic) NSUInteger speed;

/**
 上次计算速度时的时间戳
 */
@property (nonatomic) NSUInteger lastSpeedTime;

/**
 计算速度时间内下载文件的大小
 */
@property (nonatomic) NSUInteger intervalFileSize;

/**
 记录任务加入准备下载的时间（点击默认、暂停、失败状态），用于计算开始、停止任务的先后顺序
 */
@property (nonatomic) NSUInteger lastStateTime;


//Add---
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

NS_ASSUME_NONNULL_END
