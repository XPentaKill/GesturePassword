//
//  ViewController.m
//  GesturePassword
//
//  Created by 莘英发 on 2018/4/16.
//  Copyright © 2018年 莘英发. All rights reserved.
//

#import "ViewController.h"
#import "YFGesturePasswordController.h"

@interface ViewController ()

@end



@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"第一个控制器";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    YFGesturePasswordController *vc = [[YFGesturePasswordController alloc] init];
    NSString *passtowd = [[NSUserDefaults standardUserDefaults] objectForKey:@"gesturePassword"];
    if (passtowd) {
        vc.isFirst = NO;
    }else{
        vc.isFirst = YES;
    }

    [self presentViewController:vc animated:YES completion:nil];
}

@end
