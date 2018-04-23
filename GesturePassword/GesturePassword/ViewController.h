//
//  ViewController.h
//  GesturePassword
//
//  Created by 莘英发 on 2018/4/16.
//  Copyright © 2018年 莘英发. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
// 是不是设置密码 1- 是  0 - 否
@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, copy) BOOL (^passwordAndCallBack)(NSString*);

@end

