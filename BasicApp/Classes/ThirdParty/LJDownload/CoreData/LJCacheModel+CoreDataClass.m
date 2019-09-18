//
//  LJCacheModel+CoreDataClass.m
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//
//

#import "LJCacheModel+CoreDataClass.h"
#import "LJDownloadModel.h"

@implementation LJCacheModel

- (void)conversionDownloadModel:(LJDownloadModel *)model
{
    //Add--------------------------------
    self.pi = model.pi;
    self.pt = model.pt;
    self.name = model.name;
    self.path = model.path;
    self.m3u8 = model.m3u8;
    self.isEncrypted = model.isEncrypted;
    self.albumId = model.albumId;
    self.mediaId = model.mediaId;
    self.videoType = model.videoType;
    self.detailUrl = model.detailUrl;
    self.analyseUrl = model.analyseUrl;
    self.cover = model.cover;
//    self.status = model.status;
    self.secretInfo = model.secretInfo;
    self.source = model.source;
    self.labelIds = model.labelIds;
    self.engine = model.engine;
    self.indexForEpisode = model.indexForEpisode;
    //------------------------------------
    
    self.localPath = model.localPath;
    self.vid = model.vid;
    self.fileName = model.fileName;
    self.url = model.url;
    self.resumeData = model.resumeData;
    self.progress = model.progress;
    self.state = model.state;
    self.totalFileSize = model.totalFileSize;
    self.tmpFileSize = model.tmpFileSize;
    self.speed = model.speed;
    self.lastSpeedTime = model.lastSpeedTime;
    self.intervalFileSize = model.intervalFileSize;
    self.lastStateTime = model.lastStateTime;
    
}

@end
