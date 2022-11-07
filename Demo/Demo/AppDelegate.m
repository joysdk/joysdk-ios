//
//  AppDelegate.m
//  Demo
//
//  Created by apple on 2022/9/30.
//

#import "AppDelegate.h"
#import <JoySDK/JoyGame.h>
#import "GameInfo.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [JoyGame.sharedInstance initWithAppKey:@"0"
//                                      token:@""
//                             gameListBlock:^(NSArray<JoyGameInfoModel *> * _Nullable gameList) {
//        
//        if (gameList.count > 0) {
//            NSLog(@"客户端获取到游戏列表");
//            GameInfo.shared.gameList = gameList;
//            
//        } else {
//            NSLog(@"客户端获取到游戏列表为空");
//        }
//        
//    } error:^(JoyStateCode errorCode) {
//        NSLog(@"客户端获取游戏列表失败  %lu", (unsigned long)errorCode);
//    }];
    
    
    
    return YES;
}


@end
