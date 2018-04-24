//
//  YFGesturePasswordController.m
//  GesturePassword
//
//  Created by 莘英发 on 2018/4/23.
//  Copyright © 2018年 莘英发. All rights reserved.
//

#import "YFGesturePasswordController.h"
#import "YFGesturePasswordDrawView.h"

@interface YFGesturePasswordController ()
// 顶部提示的view
@property (nonatomic, strong) UIView *topAlertView;

// 中间的提示语
@property (nonatomic, strong) UILabel *alertLable;
// 绘制的view
@property (nonatomic, strong) YFGesturePasswordDrawView *gesturePasswordView;
@end

// 密码错误次数上限
static int errorCount = 5;
// 第一绘制的有效密码 (长度 >= 3)
static NSString *validPassword = nil;

@implementation YFGesturePasswordController
- (YFGesturePasswordDrawView *)gesturePasswordView{
    if (!_gesturePasswordView) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = width;
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.alertLable.frame) + 20;
        _gesturePasswordView = [[YFGesturePasswordDrawView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _gesturePasswordView.backgroundColor = [UIColor clearColor];
        _gesturePasswordView.frame = CGRectMake(15, 200, self.view.bounds.size.width - 30, self.view.bounds.size.width - 30);
        [self.view addSubview:_gesturePasswordView];
    }
    return _gesturePasswordView;
}

- (UIView *)topAlertView{
    if (!_topAlertView) {
        CGFloat width = 80;
        CGFloat height = 80;
        CGFloat x = (self.view.frame.size.width - width) * 0.5;
        CGFloat y = 40;
        _topAlertView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _topAlertView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_topAlertView];
        
        CGFloat marginX = 5;
        CGFloat btnW = 20;
        CGFloat margin = (width - marginX * 2 - btnW * 3) * 0.5;
        CGFloat marginY = 5;
        for (int i = 0; i < 9; i++){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i ;
            // 禁止用户点击，因为这个只是展示的
            btn.userInteractionEnabled = NO;
            [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
            [_topAlertView addSubview:btn];
            
            NSInteger row = i / 3;
            NSInteger column = i % 3;
            CGFloat btnX = marginX + (margin + btnW) * column;
            CGFloat btnY = marginY + (margin + btnW) * row;
            btn.frame = CGRectMake(btnX, btnY, btnW, btnW);
        }
        
    }
    return _topAlertView;
}

- (UILabel *)alertLable{
    if (!_alertLable) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = 30;
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.topAlertView.frame) + 20;
        _alertLable = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _alertLable.textColor = [UIColor whiteColor];
        _alertLable.font = [UIFont systemFontOfSize:15];
        _alertLable.backgroundColor = [UIColor clearColor];
        _alertLable.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_alertLable];
    }
    return _alertLable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Home_refresh_bg"]];
    
    self.gesturePasswordView.currentVC = self;
    
    // 第一次设置密码
    if (self.isFirst) {
        validPassword = nil;
        errorCount = 5;
        
        self.topAlertView.hidden = NO;
        self.alertLable.text = @"为了您的安全，请设置手势密码";
        __weak typeof(self) bself = self;
        self.passwordAndCallBack = ^BOOL(NSString *passwordFromUser, NSArray *selectedBtnArr) {
            
            // 判断用户绘制的密码是否有效（长度 >= 3）
            if (passwordFromUser.length <= 2) {
                bself.alertLable.text = @"至少连接三个点";
                [bself.alertLable.layer addAnimation:[bself animationForLableWithTextColor: [UIColor redColor]] forKey:nil];
                return NO;
                
            }else{
                // 第一次绘制的密码如果有效
                if (!validPassword) {
                    validPassword = passwordFromUser;
                    
                    bself.alertLable.text = @"请再次绘制解锁密码";
                     [bself.alertLable.layer addAnimation:[bself animationForLableWithTextColor: [UIColor whiteColor]] forKey:nil];
                    
                    // 设置上面的提示图案
                    for (UIButton *subBtn in bself.topAlertView.subviews) {
                        if ([selectedBtnArr containsObject:[NSNumber numberWithInteger:subBtn.tag]]) {
                            subBtn.selected = YES;
                        }
                        
                    }
                    return YES;
                    
                }else{
                    if (![validPassword isEqualToString:passwordFromUser]) {
                        bself.alertLable.text = @"两次绘制的密码不一致";
                         [bself.alertLable.layer addAnimation:[bself animationForLableWithTextColor: [UIColor redColor]] forKey:nil];
                        return NO;
                        
                    }else{
                        bself.alertLable.text = @"手势密码设置成功";
                        [bself.alertLable.layer addAnimation:[bself animationForLableWithTextColor: [UIColor whiteColor]] forKey:nil];
                        [[NSUserDefaults standardUserDefaults] setObject:passwordFromUser forKey:@"gesturePassword"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [bself quitCurrentViewControllerAndLogin:NO];
                       
                        return YES;
                    }
                }
 
            }
        };
        
    }else{ // 绘制手势密码解锁

        self.topAlertView.hidden = YES;
        self.alertLable.text = @"连线解锁";
        
        __weak typeof(self) bself = self;
        self.passwordAndCallBack = ^BOOL(NSString *passwordFromUser, NSArray *selectedBtnArr) {
            // 判断用户绘制的密码是否有效（长度 >= 3）
            if (passwordFromUser.length <= 2) {
                bself.alertLable.text = @"至少连接三个点";
                [bself.alertLable.layer addAnimation:[bself animationForLableWithTextColor: [UIColor redColor]] forKey:nil];
                return NO;
                
            }else{
                if ([passwordFromUser isEqualToString:@"12345"]) {
                    bself.alertLable.text = @"登录成功";
                    [bself.alertLable.layer addAnimation:[bself animationForLableWithTextColor: [UIColor whiteColor]] forKey:nil];
                    return YES;
                }else{
                    
#warning 这里无需对errorCount做判断，因为次数用完之后会退出重新登录，登陆后需要重新设置手势密码，那时errorCount会被重制为5；
                    errorCount --;
                    bself.alertLable.text = [NSString stringWithFormat:@"密码错误，还可以尝试%d次", errorCount];
                    if (errorCount == 0) {
                        // 输入次数已用完，需要验证用户身份
                        bself.alertLable.text = @"为了您的账户安全，请重新登录";
                        #warning 这里要把当前用户强制下线
                        
                        [bself quitCurrentViewControllerAndLogin:YES];
                    }
                    [bself.alertLable.layer addAnimation:[bself animationForLableWithTextColor: [UIColor redColor]] forKey:nil];
                    
                    return NO;
                }
            }
        };
    }
}

- (CAKeyframeAnimation *)animationForLableWithTextColor:(UIColor *)textColor{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    CGFloat x = self.alertLable.center.x;
    animation.values = @[@(x - 15), @(x), @(x + 15), @(x)];
    animation.repeatCount = 3;
    animation.duration = 0.1;
    
    self.alertLable.textColor = textColor;
    return animation;
}

// 退出当前控制器，退出登录
- (void)quitCurrentViewControllerAndLogin:(BOOL)quitLogin{
    
    if (quitLogin) {
        // 退出登录
#warning  这里强制让用户退出
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 退出当前控制器
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
