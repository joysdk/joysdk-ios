//
//  ASGameWebView.h
//  anchorlive
//
//  Created by apple on 2022/8/17.
//

#import <UIKit/UIKit.h>
#import "JGStatusDefine.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ASGameWebViewBlock)(JoyGameEventCode block);
typedef void(^ASGameWebViewBoolBlock)(BOOL isSuccess);

@interface JoyGameWebView : UIView

@property (copy, nonatomic) ASGameWebViewBlock block; //事件点击回调

@property (copy, nonatomic) ASGameWebViewBlock beginOpenGameIdblock;  //大厅点击游戏回调
@property (copy, nonatomic) ASGameWebViewBlock hasOpenGameIdblock;  //游戏加载成功回调

-(void)loadUrl:(NSString *)url;

- (float)getWebViewHeight;
- (void)setWebViewHeight:(float)height;
- (void)setWebViewHeightToBottom:(float)height;
-(void)setWebViewOriginY;

- (void)refreshGameBalance;
-(void)noticeResizeToJs:(ASGameWebViewBoolBlock)block;
- (void)openGame:(NSInteger)gameId token:(NSString *)token roomId:(nullable NSString * )roomId ext:(nullable NSString *)ext;
-(void)noticeExitGameToJs;

@end

NS_ASSUME_NONNULL_END
