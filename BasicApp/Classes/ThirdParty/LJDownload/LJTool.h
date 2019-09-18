//
//  LJTool.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/18.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJTool : NSObject

// 根据字节大小返回文件大小字符KB、MB
+ (NSString *)stringFromByteCount:(long long)byteCount;

// 时间转换为时间戳
+ (NSInteger)getTimeStampWithDate:(NSDate *)date;

// 时间戳转换为时间
+ (NSDate *)getDateWithTimeStamp:(NSInteger)timeStamp;

// 一个时间戳与当前时间的间隔（s）
+ (NSInteger)getIntervalsWithTimeStamp:(NSInteger)timeStamp;

@end
