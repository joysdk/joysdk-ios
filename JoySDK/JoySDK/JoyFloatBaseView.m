//
//  FloatView.m
//  live
//
//  Created by apple on 2021/3/19.
//

#import "JoyFloatBaseView.h"
#import "Header.h"

static CGFloat kMargin = 10.f;

#define is_iPhoneXSerious @available(iOS 11.0, *) && UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0

@interface JoyFloatBaseView()

@property (strong, nonatomic) UIViewController *rootViewController;

@end

@implementation JoyFloatBaseView

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGesture];
        
        self.rootViewController = rootViewController;
    }
    return self;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.center = [touches.anyObject locationInView:self.rootViewController.view];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endTouch:[touches.anyObject locationInView:self.rootViewController.view]];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endTouch:[touches.anyObject locationInView:self.rootViewController.view]];
}

- (void)endTouch:(CGPoint)point {
    
    CGRect frame = self.frame;
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    
    //贴边
    if (point.x > screenWidth / 2.f) {
        frame.origin.x = screenWidth - frame.size.width - kMargin;
    } else {
        frame.origin.x = kMargin;
    }
    
    //横向边界
    CGFloat maxX = screenWidth - frame.size.width;
    CGFloat minX = 0;
    if (frame.origin.x > maxX) {
        frame.origin.x = maxX;
    } else if (frame.origin.x < minX) {
        frame.origin.x = minX;
    }
    
    //纵向边界
    CGFloat maxY = screenHeight-SafeAreaBottom-frame.size.height;//VideoCallViewController中messageAndChatRecordView的最小y值
    CGFloat minY = K_StatusNav_Height;
    if (frame.origin.y > maxY) {
        frame.origin.y = maxY;
    } else if (frame.origin.y < minY) {
        frame.origin.y = minY;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    }];
}

#pragma mark - tap gesture

- (void)tap:(UITapGestureRecognizer *)gesture {
    if (self.floatViewDidClickBlock) {
        self.floatViewDidClickBlock(self);
    }
}


@end
