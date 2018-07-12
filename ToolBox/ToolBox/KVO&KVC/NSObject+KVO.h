//
//  NSObject+KVO.h
//  ToolBox
//
//  Created by Hy on 2018/7/6.
//  Copyright © 2018年 NotHY. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 .h文件中暴露两个API，用于 添加 和 删除 KVO
  */

// 宏定义
NSString *const kPGKVOClassPrefix = @"PGKVOClassPrefix_";
NSString *const kPGKVOAssociatedObservers = @"PGKVOAssociatedObservers";
/** 监听回调用block */
typedef void(^PGObservingBlock)(id observedObject,
                                NSString *observedKey,
                                id oldValue, id newValue);

@interface NSObject (KVO)

/** 添加观察者 */
- (void)PG_addObserver:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(PGObservingBlock)block;

/** 移除观察者 */
- (void)PG_removeObserver:(NSObject *)observer
                   forKey:(NSString *)key;

@end
