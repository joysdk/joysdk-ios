//
//  JoySdkModel.h
//  JoySDK
//
//  Created by apple on 2022/10/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JoyGameInfoModel :NSObject
@property (nonatomic, copy) NSString *iconUrl;  //游戏图标链接
@property (nonatomic, copy) NSString *gameName; //游戏名
@property (nonatomic, assign) NSInteger gameId; //游戏Id
@end

NS_ASSUME_NONNULL_END
