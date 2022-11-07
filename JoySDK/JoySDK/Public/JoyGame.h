//
//  JoyGame.h
//  JoySDK
//
//  Created by apple on 2022/9/30.
//

#import <Foundation/Foundation.h>
#import <JoySDK/JGStatusDefine.h>
#import <JoySDK/JoyGameInfoModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface JoyGame : NSObject

+ (instancetype)sharedInstance;

/*
 初始化接口，传入AppKey；
 返回游戏信息数组或者错误码
 */
- (void)initWithAppKey:(NSString *)appKey
         gameListBlock:(void (^)(NSArray<JoyGameInfoModel *> * _Nullable gameList))gameListBlock
                 error:(void (^)(JoyStateCode errorCode))errorBlock;

/*
 打开单个游戏界面
 开发者选择自定义游戏列表的时候使用，用户点击游戏，传入相关参数打开对应游戏
 */
- (void)openGameWithGameId:(NSInteger)gameId token:(NSString *)token roomId:(nullable NSString * )roomId ext:(nullable NSString *)ext rootViewController:(UIViewController *)rootViewController eventCode:(void (^)(JoyGameEventCode eventCode))eventCodeBlock;

/*
 打开游戏大厅
 开发者选择使用JoySDK自带的游戏大厅的时候使用；无需自定义游戏列表
 */
- (void)openHallWithToken:(NSString *)token roomId:(nullable NSString *)roomId ext:(nullable NSString *)ext rootViewController:(UIViewController *)rootViewController eventCode:(void (^)(JoyGameEventCode eventCode))eventCodeBlock;

/*
 刷新游戏内的用户余额
 除游戏的因素，用户的余额发生变化时调用，使用户在游戏内的余额与APP内的余额马上同步
 */
- (void)refreshGameBalance;

/*
 隐藏游戏画面
 */
- (void)hideGameView;

/*
 自定义悬浮球初始位置
 */
- (void)setFloatingButtonFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
