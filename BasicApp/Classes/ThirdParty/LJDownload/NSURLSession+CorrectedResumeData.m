//
//  NSURLSession+CorrectedResumeData.m
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/18.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import "NSURLSession+CorrectedResumeData.h"

static NSString *const resumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
static NSString *const resumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";

@implementation NSURLSession (CorrectedResumeData)

- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData
{
    NSData *data = [self getCorrectResumeDataWithData:resumeData];
    data = data ? data : resumeData;
    NSURLSessionDownloadTask *task = [self downloadTaskWithResumeData:data];
    NSMutableDictionary *resumeDic = [[self getResumeDictionaryWithData:data] mutableCopy];
    
    if (resumeDic)
    {
        if (!task.originalRequest)
        {
            NSData *originalReqData = resumeDic[resumeOriginalRequest];
            NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalReqData];
            if (originalRequest) [task setValue:originalRequest forKey:@"originalRequest"];
        }
        
        if (!task.currentRequest)
        {
            NSData *currentReqData = resumeDic[resumeCurrentRequest];
            NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentReqData];
            if (currentRequest) [task setValue:currentRequest forKey:@"currentRequest"];
        }
    }
    
    return task;
}


- (NSData *)getCorrectResumeDataWithData:(NSData *)data
{
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 10.0 && version < 10.2) {
        
        if (!data) return nil;
        
        NSMutableDictionary *resumeDictionary = [[self getResumeDictionaryWithData:data] mutableCopy];
        if (!resumeDictionary) return nil;
        
        //HyAdd----iOS11.3 Bug
        if ([resumeDictionary.allKeys containsObject:@"NSURLSessionResumeByteRange"]) {
            [resumeDictionary removeObjectForKey:@"NSURLSessionResumeByteRange"];
        }
        
        resumeDictionary[resumeCurrentRequest] = [self getCorrectRequestDataWithData:resumeDictionary[resumeCurrentRequest]];
        resumeDictionary[resumeOriginalRequest] = [self getCorrectRequestDataWithData:resumeDictionary[resumeOriginalRequest]];
        
        return [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    
    }else {
        NSMutableDictionary *resumeDictionary = [[self readResumeData:data] mutableCopy];
        if (resumeDictionary == nil) {
            return data;
        }
        if ([resumeDictionary.allKeys containsObject:@"NSURLSessionResumeByteRange"]) {
            [resumeDictionary removeObjectForKey:@"NSURLSessionResumeByteRange"];
        }
        
        if ([[resumeDictionary valueForKey:@"NSURLSessionResumeInfoVersion"] integerValue] == 1) {
            // !!!: NSURLSessionResumeInfoLocalPath 字段会因为沙盒目录不断更新而失效, 需要更新路径
            NSURL *fileURL = [NSURL fileURLWithPath:[resumeDictionary valueForKey:@"NSURLSessionResumeInfoLocalPath"]];
            NSString *updateTempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileURL.lastPathComponent];
            [resumeDictionary setObject:updateTempFilePath forKey:@"NSURLSessionResumeInfoLocalPath"];
        }
        
        NSData *result = [self packetResumeData:[NSDictionary dictionaryWithDictionary:resumeDictionary]];
        return result;
        
    }
}

- (NSData *)packetResumeData:(NSDictionary *)packet {
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 12) {
        return [NSPropertyListSerialization dataWithPropertyList:packet
                                                          format:NSPropertyListXMLFormat_v1_0
                                                         options:0
                                                           error:nil];
    } else {
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:packet forKey:@"NSKeyedArchiveRootObjectKey"];
        [archiver finishEncoding];
        return [data copy];
    }
}

- (NSDictionary *)readResumeData:(NSData *)resumeData {
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];

    if (version < 12) {
        NSDictionary *dic = [NSPropertyListSerialization propertyListWithData:resumeData
                                                                      options:0
                                                                       format:NULL
                                                                        error:nil];
        return dic;
    } else {
        return [self getResumeDictionaryWithData:resumeData];
    }
}

- (NSDictionary *)getResumeDictionaryWithData:(NSData *)data
{
    NSDictionary *iresumeDictionary = nil;
    id root = nil;
    id keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    @try {
        if (@available(iOS 9.0, *)) {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil];
        }
        if (root == nil) {
            if (@available(iOS 9.0, *)) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        }
    } @catch(NSException *exception) { }
    [keyedUnarchiver finishDecoding];
    iresumeDictionary = [NSDictionary dictionaryWithDictionary:root];
    
    if (iresumeDictionary == nil) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data
                                                                      options:NSPropertyListMutableContainersAndLeaves
                                                                       format:nil
                                                                        error:nil];
    }
    return iresumeDictionary;
}

- (NSData *)getCorrectRequestDataWithData:(NSData *)data
{
    if (!data) return nil;
    
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data]) return data;
    
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    if (!archive) return nil;
    
    NSInteger i = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld", i]]) {
        i++;
    }
    
    NSInteger j = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]]) {
        NSMutableArray *array = archive[@"$objects"];
        NSMutableDictionary *dic = array[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld", i + j]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]];
            [array replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = array;
        }
        j++;
    }
    
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"]) {
        NSMutableArray *array = archive[@"$objects"];
        NSMutableDictionary *dic = array[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld", i + j]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [array replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = array;
        }
    }
    
    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"]) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    
    return [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
}

@end
