//
//  PGObservationInfo.h
//  ToolBox
//
//  Created by Hy on 2018/7/6.
//  Copyright © 2018年 NotHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGObservationInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) PGObservingBlock block;

@end
