//
//  LJDownloadModel.m
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/18.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import "LJDownloadModel.h"
#import "LJCacheModel+CoreDataClass.h"
#import "FMDB.h"

@implementation LJDownloadModel

- (NSString *)localPath {
    if (!_localPath) {
        NSString *fileName = [_url substringFromIndex:[_url rangeOfString:@"/" options:NSBackwardsSearch].location + 1];
        
        /*
         _url = http://movies.ks.51tv.com/slc89at47o00.mp4?sign=11db9d0a6a61963c01dea4b3a3e68a80&t=5c1ca027
         要去掉防盗链
         */
        //Add---
        NSArray *arr = [fileName componentsSeparatedByString:@"?"];
        if (arr.count>0) {
            fileName = arr.firstObject;
        }
        //-----
        
//        NSString *str = [NSString stringWithFormat:@"DownloadVideo/%@_%@", _vid, fileName];
        NSString *str = [NSString stringWithFormat:@"%@_%@", _vid, fileName];
//        _localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:str];
        _localPath = str;
    }
    return _localPath;
}

- (void)conversionCacheModel:(LJCacheModel *)model
{
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
    
    //Add---
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
    
}

- (instancetype)initWithCacheModel:(LJCacheModel *)model
{
    self = [super init];
    if (self)
    {
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
    
        //Add----------------------------------
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
//        self.status = model.status;
        self.secretInfo = model.secretInfo;
        self.source = model.source;
        self.labelIds = model.labelIds;
        self.engine = model.engine;
        self.indexForEpisode = model.indexForEpisode;
        
    }
    return self;
}

- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet
{
    if (!resultSet) return nil;
    
    _vid = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"vid"]];
    _url = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"url"]];
    _fileName = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"fileName"]];
    _totalFileSize = [[resultSet objectForColumn:@"totalFileSize"] integerValue];
    _tmpFileSize = [[resultSet objectForColumn:@"tmpFileSize"] integerValue];
    _progress = [[resultSet objectForColumn:@"progress"] floatValue];
    _state = [[resultSet objectForColumn:@"state"] integerValue];
    _lastSpeedTime = [[resultSet objectForColumn:@"lastSpeedTime"] integerValue];
    _intervalFileSize = [[resultSet objectForColumn:@"intervalFileSize"] integerValue];
    _lastStateTime = [[resultSet objectForColumn:@"lastStateTime"] integerValue];
    _resumeData = [resultSet dataForColumn:@"resumeData"];
    
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.url = dict[@"url"];
        self.vid = dict[@"vid"];
        self.fileName = dict[@"fileName"];
    }
    return self;
}

//Add----
- (instancetype)initWithModel:(VDCommonModel*)model {
    if (self = [self init]) {
        NSString *filePath = nil;
        _fileName = filePath.lastPathComponent;
        self.fileName = filePath.stringByDeletingLastPathComponent;
      
        _mediaId = @"";
        _indexForEpisode = @"";
        if (model.videoType == VideoType_Movie) {
            if (model.episodeDataArray.count>0) {
                _mediaId = model.episodeDataArray.firstObject.mediaId;
            }
        }else {
            _mediaId = model.episodeDataArray[model.indexCacheForEpisode].mediaId;
            _indexForEpisode = String_Integer(model.indexCacheForEpisode + 1);
        }
        
        _vid = _mediaId;
        
        _pi = model.programId;
        _pt = model.type;
        _albumId = model.programId;
        _videoType = model.videoType;
        _name = model.name;
        _cover = model.poster.url;
//        _status = CacheStatusType_Wait;
        _source = model.siCurrent;
        
        MediaSourceResultModel *mSource = model.mediaSourceResultList[model.indexSelectForSource];
        MediaTipResultModel *mTip = model.episodeDataArray[model.indexCacheForEpisode];
        
        _engine = mSource.engine;
        
        if([mSource.idForModel integerValue] == -1) {  //自有源
            _detailUrl = mTip.originLink;
        }else {  //非自有源: 一部分可直接播 一部分要跳转
            
            if ([mSource.engine isEqualToString:@"RE002"] && [mTip.analysisPolicy integerValue] == 1) {   //后台解析:
                //                WS()
                [USER_MANAGER analyseVideoUrlWithModel:model success:^(id response) {
                    if (response[@"data"]) {  //解析成功, 返回不同分辨率的播放Url, 直接播放
                        model.analyseUrlModel = [AnalyseUrlBackModel mj_objectWithKeyValues:response[@"data"]];
                        if (model.analyseUrlModel.data.filterStream) {
                            NSString *url = model.analyseUrlModel.data.filterStream.segs.firstObject.url;
                            if (url.length>0) {
                                _detailUrl =  url;
                            }else {
                                _detailUrl =  mTip.originLink;
                            }
                        }else {
                            _detailUrl =  mTip.originLink;
                        }
                    }else {  //用点量解析,  目前不下载
                        _detailUrl = mTip.originLink;
                    }
                    
                } failure:^(NSString *errMsg) {
                    _detailUrl = mTip.originLink;
                }];
            }else {
                _detailUrl = mTip.originLink;
            }
        }
    }
    return self;
}

- (void)setAnalyseUrl:(NSString *)analyseUrl {
    _analyseUrl = analyseUrl;
    _url = analyseUrl;
}

@end
