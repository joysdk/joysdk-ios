//
//  JGStatusDefine.h
//  JoySDK
//
//  Created by apple on 2022/9/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 初始化接口返回的错误码
 */
typedef NS_ENUM(NSUInteger, JoyStateCode) {
    APP_KEY_WRONG = 310,                // AppKey错误
    APP_GAME_LIST_EMPTY = 311,          // 游戏列表为空
    APP_BALANCE_IS_NOT_ENOUGH = 312,    // 账号余额不足
    APP_KEY_INVALID = 313,              // AppKey无效
    
    NETWORK_ERROR = 10001,              //网络错误
    SERVER_ERROR = 10002,               //服务器错误
};

/*
 打开游戏，游戏内返回的事件码
 */
typedef NS_ENUM(NSUInteger, JoyGameEventCode) {
    Recharge, //点击充值
    Close, //点击关闭
};

@interface JGStatusDefine : NSObject

@end

NS_ASSUME_NONNULL_END
