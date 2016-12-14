//
//  HYDog.h
//  ToolBox
//
//  Created by ZRBhy on 16/12/14.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HYDogDelegate <NSObject>

@end

@interface HYDog : NSObject

@property (nonatomic, weak) id<HYDogDelegate> delegate;

@end
