//
//  Networker.h
//  ToolBox
//
//  Created by ZRBhy on 16/12/13.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Networker : NSObject

+ (RACSignal *)loginWithUserName:(NSString *)name password:(NSString *)password;

@end
