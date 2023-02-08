//
//  FloatView.h
//  live
//
//  Created by apple on 2021/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JoyFloatBaseView : UIView

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

@property (nonatomic, nullable, copy) void(^floatViewDidClickBlock)(JoyFloatBaseView *floatView);

@end

NS_ASSUME_NONNULL_END
