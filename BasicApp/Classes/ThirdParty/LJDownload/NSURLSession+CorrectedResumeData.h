//
//  NSURLSession+CorrectedResumeData.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/18.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (CorrectedResumeData)

// https://stackoverflow.com/questions/39346231/resume-nsurlsession-on-ios10
- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData;

@end
