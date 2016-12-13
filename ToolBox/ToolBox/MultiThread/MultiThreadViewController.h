//
//  MultiThreadViewController.h
//  ToolBox
//
//  Created by ZRBhy on 16/12/13.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiThreadViewController : UIViewController

@end

/** 多线程使用场景 */
/*
 每隔1秒添加10个大头针
   [self performSelectorInBackground:@selector(addAnno:) withObject:arr];
 
 - (void)addAnno:(NSArray *)array {
     NSArray *arr = array;
     int countSend = 0;
     for (int i = 0; i < arr.count; i++) {
     NSArray *arrSend = arr[i];
     countSend += arrSend.count;
     dispatch_sync(dispatch_get_main_queue(), ^{
     [self.mapView addAnnotations:arrSend];
     self.labNotify.text = [NSString stringWithFormat:@"已通知%d人",countSend];
     });
     sleep(1);
     }
     [self.mapView showAnnotations:self.annotations edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
 }
 */
