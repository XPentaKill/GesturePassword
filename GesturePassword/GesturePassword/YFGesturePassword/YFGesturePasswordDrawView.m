//
//  YFGesturePasswordView.m
//  GesturePassword
//
//  Created by 莘英发 on 2018/4/16.
//  Copyright © 2018年 莘英发. All rights reserved.
//

#import "YFGesturePasswordDrawView.h"
#import "YFGesturePasswordController.h"

@interface YFGesturePasswordDrawView()

// 9个按钮所在的数组(使用按钮是因为按钮自身有三种状态方便设置不同状态的图片变换)
@property (nonatomic, strong) NSMutableArray *allBtnArr;
// 将选中的按钮顺序添加到数组中
@property (nonatomic, strong) NSMutableArray *selectedBtnArrM;

// 手指触摸的点
@property (nonatomic, assign) CGPoint currentPoint;
// 线条的颜色
@property (nonatomic, strong) UIColor *lineColor;
@end

// 存放第一次画的密码
static NSString *firstPassword = nil;

@implementation YFGesturePasswordDrawView

- (NSMutableArray *)selectedBtnArrM{
    if (!_selectedBtnArrM) {
        _selectedBtnArrM = [NSMutableArray array];
    }
    return _selectedBtnArrM;
}

- (NSMutableArray *)allBtnArr{
    if (!_allBtnArr) {
        _allBtnArr = [NSMutableArray array];
        
        // 创建9个按钮
        for (int i = 0; i < 9; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            btn.tag = i ;
            // 阻断事件响应链，这样就可以让父类self接收触摸事件
            btn.userInteractionEnabled = NO;
            
            [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
             [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
             [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_error"] forState:UIControlStateDisabled];
            [self addSubview:btn];
            [self.allBtnArr addObject:btn];
        }
    }
    return _allBtnArr;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat marginX = 30;
    CGFloat btnW = 74;
    CGFloat margin = (self.bounds.size.width - marginX * 2 - btnW * 3) * 0.5;
    CGFloat marginY = 20;
    
    for (int i = 0; i < 9; i++){
        NSInteger row = i / 3;
        NSInteger column = i % 3;
        CGFloat btnX = marginX + (margin + btnW) * column;
        CGFloat btnY = marginY + (margin + btnW) * row;
        UIButton *btn = self.allBtnArr[i];
        btn.frame = CGRectMake(btnX, btnY, btnW, btnW);
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 设置线条颜色
    self.lineColor = [UIColor whiteColor];
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:touch.view];
    // 便利所有按钮，如果触摸点在按钮的范围内就设置按钮的状态为选中状态
    for (UIButton *btn in self.allBtnArr) {
        if (CGRectContainsPoint(btn.frame, point)) {
        
            btn.selected = YES;
            // 将选中的按钮添加到数组中
            [self.selectedBtnArrM addObject:btn];
        }
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:touch.view];
    // 保存当前手指触摸的点为了划线
    self.currentPoint = point;
    
    for (UIButton *btn  in self.allBtnArr) {
        if (CGRectContainsPoint(btn.frame, point)) {
            btn.selected = YES;
            // 避免按钮重复添加
            if (![self.selectedBtnArrM containsObject:btn]) {
                [self.selectedBtnArrM addObject:btn];
            }
        }

    }
     [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 松手后就不能让用户再画了
    self.userInteractionEnabled = NO;
    // 去掉最后的一节线
    self.currentPoint = [[self.selectedBtnArrM lastObject] center];
    [self setNeedsDisplay];
    
    NSString *password = @"";
    NSMutableArray *selectedBtnArrM = [NSMutableArray array];
    for (UIButton *btn in self.selectedBtnArrM) {
       password = [NSString stringWithFormat:@"%@%ld", password, btn.tag];
        // 将密码打包传给控制器用来设置顶部区域的密码提示
        [selectedBtnArrM addObject:[NSNumber numberWithInteger:btn.tag]];
    }
//    NSLog(@"密码为：%@", password);
    
    BOOL iscorrect = self.currentVC.passwordAndCallBack(password, [selectedBtnArrM copy]);
    // 如果密码不正确
    if (!iscorrect) {
        for (UIButton *btn in self.selectedBtnArrM) {
            btn.selected = NO;
            btn.enabled = NO;
            self.lineColor = [UIColor redColor];
        }
        [self setNeedsDisplay];
    };
    [self resetAllBtnStatus];
    
}

// 将界面恢复到最初始的状态
- (void)resetAllBtnStatus{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        for (UIButton *btn in self.allBtnArr) {
            btn.selected = NO;
            btn.enabled = YES;
        }
        [self.selectedBtnArrM removeAllObjects];
        [self setNeedsDisplay];
        self.userInteractionEnabled = YES;
        
    });
    
   
}

- (void)drawRect:(CGRect)rect{
    
    if (!self.selectedBtnArrM.count) {
        return;
    }
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 10;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;
    [self.lineColor set];
    for (int i = 0; i < self.selectedBtnArrM.count; i ++){
        UIButton *btn = self.selectedBtnArrM[i];
        if (i == 0) {
            [path moveToPoint:btn.center];
        }else{
            [path addLineToPoint:btn.center];
        }
        
    }
    [path addLineToPoint:self.currentPoint];
    [path stroke];
    
    
    
}

@end
