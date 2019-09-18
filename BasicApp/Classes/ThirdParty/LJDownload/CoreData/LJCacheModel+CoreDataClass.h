//
//  LJCacheModel+CoreDataClass.h
//  LJDownloadDemo
//
//  Created by LeeJay on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LJDownloadModel;

NS_ASSUME_NONNULL_BEGIN

@interface LJCacheModel : NSManagedObject

- (void)conversionDownloadModel:(LJDownloadModel *)dModel;

@end

NS_ASSUME_NONNULL_END

#import "LJCacheModel+CoreDataProperties.h"
