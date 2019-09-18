//
//  LJCacheModel+CoreDataProperties.m
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//
//

#import "LJCacheModel+CoreDataProperties.h"

@implementation LJCacheModel (CoreDataProperties)

+ (NSFetchRequest<LJCacheModel *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"LJCacheModel"];
}

@dynamic localPath;
@dynamic vid;
@dynamic fileName;
@dynamic url;
@dynamic resumeData;
@dynamic progress;
@dynamic state;
@dynamic totalFileSize;
@dynamic tmpFileSize;
@dynamic speed;
@dynamic lastSpeedTime;
@dynamic intervalFileSize;
@dynamic lastStateTime;

//Add---
@dynamic pi;
@dynamic pt;
@dynamic path;
@dynamic m3u8;
@dynamic isEncrypted;

@dynamic albumId;  //相册id, 多集数对应同一个    pi
@dynamic mediaId;  //唯一标识, 每个电影,每一集对应唯一  idForModel
@dynamic videoType;
@dynamic detailUrl; // analysis/url/1  掉接口 取最新下载地址

@dynamic analyseUrl; // analysis/url/1 接口获取的下载地址. 可能会失效
@dynamic name;
@dynamic cover;  //封面图的Url
//@dynamic status;
@dynamic secretInfo;  //秘钥信息, 下载时, 解析视频时用到  暂时用不到
@dynamic source;  //siCurrent  来源id
@dynamic labelIds;   //categoryResults   用 , 拼接id
@dynamic engine;   //MediaSource.ParseEngine engine;
@dynamic indexForEpisode;  //如果是多集的, index是当前集数,第几集

@end
