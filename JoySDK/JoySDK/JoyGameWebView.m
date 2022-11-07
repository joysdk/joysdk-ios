//
//  ASGameWebView.m
//  anchorlive
//
//  Created by apple on 2022/8/17.
//

#import "JoyGameWebView.h"
#import "Header.h"
#import <WebKit/WebKit.h>

static NSString * const GameRechargeIAP = @"recharge";
static NSString * const RechargeSource = @"rechargeSource";
static NSString * const NewTppClose = @"newTppClose";
static NSString * const NewTppLogEvent = @"newTppLogEvent";
static NSString * const OpenGameSucc = @"OpenGameSucc";
static NSString * const OpenGameBegin = @"OpenGameBegin";
static NSString * const Log = @"Log";

@interface JoyGameWebView()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) NSArray *jsMessageNameArray;
@property (nonatomic, strong) UIView *safeAreaBottomBlackView;
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation JoyGameWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.jsMessageNameArray = @[NewTppClose, NewTppLogEvent, GameRechargeIAP, RechargeSource, OpenGameSucc, OpenGameBegin, Log];
        
        //空白区域点击事件添加
        UITapGestureRecognizer *whiteSpaceClickTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whiteSpaceClick)];
        [self addGestureRecognizer:whiteSpaceClickTapGestureRecognizer];
        
        [self initView];
    }
    return self;
}

#pragma mark - 空白区域相关

-(void)whiteSpaceClick{
    NSLog(@"点击上部分空白区域");
    if (self.block) {
        self.block(Close);
    }
    [self noticeExitGameToJs];
}

#pragma mark - webView高度，位置相关

- (float)getWebViewHeight{
    return self.webView.frame.size.height;
}

- (void)setWebViewHeight:(float)height{
    [self resetHeight:self.webView finalHeight:height];
}

- (void)setWebViewHeightToBottom:(float)height{
    [self resetHeight:self.webView finalHeight:height];
    [self resetY:self.webView finalY:GetHeight(self)];
    [self resetY:self.safeAreaBottomBlackView finalY:MaxY(self.webView)];
}

-(void)setWebViewOriginY{
    [self resetY:self.webView finalY:GetHeight(self) -SafeAreaBottom -GetHeight(self.webView)];
    [self resetY:self.safeAreaBottomBlackView finalY:MaxY(self.webView)];
}

-(void)removeScriptMessage{
    for (NSString *name in self.jsMessageNameArray) {
        [[self.webView configuration].userContentController removeScriptMessageHandlerForName:name];
    }
}

-(void)loadUrl:(NSString *)url{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    NSLog(@"h5链接：\n%@", url);
}

-(void)initView{
    //    self.backgroundColor = KGreenColor;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = false;
    
    for (NSString *name in self.jsMessageNameArray) {
        [config.userContentController addScriptMessageHandler:self name:name];
    }
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, GetWidth(self), GetHeight(self) -SafeAreaBottom) configuration:config];
    webView.navigationDelegate = self;// 导航代理
    webView.UIDelegate = self;// 与webview UI交互代理
    
    //webView透明
    webView.backgroundColor = UIColor.clearColor;
    webView.scrollView.backgroundColor = UIColor.clearColor;
    webView.opaque = NO;
    
    //scrollView默认会自动避开安全距离；这里直接关掉，实现绝对布局
    webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self addSubview:webView];
    self.webView = webView;
    
    //底部黑色的view，否则webview透明，会露出父view的颜色
    UIView *safeAreaBottomBlackView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, GetHeight(self) -SafeAreaBottom, GetWidth(self), SafeAreaBottom)];
        view.backgroundColor = KBlackColor;
        view;
    });
    [self addSubview:safeAreaBottomBlackView];
    self.safeAreaBottomBlackView = safeAreaBottomBlackView;
    
    //大鱼要求的
    NSString *supportApiStr = @"[\"newTppClose\", \"newTppLogEvent\", \"recharge\", \"rechargeSource\"]";
    [webView evaluateJavaScript:Format(@"getSupportApi(%@)", supportApiStr) completionHandler:^(id response, NSError *error) {}];
}

#pragma mark - webView回调方法

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //    NSLog(@"WKWebView加载进程   完成");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}

//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //    NSLog(@"\n name:%@\n body:%@\n frameInfo:%@\n",message.name,message.body,message.frameInfo);
    
    //调用原生充值
    if ([message.name isEqualToString:GameRechargeIAP]) {
        if (self.block) {
            self.block(Recharge);
        }
    }
    
    if ([message.name isEqualToString:Log]) {
        NSString * parameter = message.body;
        //        NSLog(@"收到  Log %@", parameter);
    }
    
    //通知原生 游戏加载完毕
    if ([message.name isEqualToString:OpenGameSucc]) {
        NSDictionary * parameter = message.body;
        NSInteger gameId = [[parameter objectForKey:@"gameId"] integerValue];
        
        NSLog(@"收到  OpenGameSucc gameId---%ld", (long)gameId);
        if (self.hasOpenGameIdblock) {
            self.hasOpenGameIdblock(gameId);
        }
    }
    
    //通知原生 游戏开始加载
    if ([message.name isEqualToString:OpenGameBegin]) {
        NSDictionary * parameter = message.body;
        NSInteger gameId = [[parameter objectForKey:@"gameId"] integerValue];
        
        NSLog(@"收到  OpenGameBegin gameId---%ld", (long)gameId);
        if (self.beginOpenGameIdblock) {
            self.beginOpenGameIdblock(gameId);
        }
    }
    
    //充值来源
    if ([message.name isEqualToString:RechargeSource]) {
        NSDictionary * parameter = message.body;
        NSString *rechargeSource = [parameter objectForKey:@"data"];
        //        [KLIAPManager shared].rechargeReason = rechargeSource;
    }
    
    //h5充值回调
    //JS调用OC
    //    if([message.name isEqualToString:NewTppLogEvent]){
    //        //用message.body获得JS传出的参数体
    //        NSDictionary * parameter = message.body;
    //        NSString *event = [parameter objectForKey:@"event"];
    //
    //        if ([event isEqualToString:@"success"]) {
    //
    //            //我们服务器打点
    //            [self rechargeUpload:parameter];
    //
    //            //刷新金币
    //            [[KLPublicMethod sharedPublicMethod] getUserInfo:@"" userInfoModelBlock:^(VideoStreamPageModel * _Nonnull model) {
    //
    //            }];
    //        }
    //
    //    }
    
    //关闭webview
    if ([message.name isEqualToString:NewTppClose]) {
        NSLog(@"收到--NewTppClose");
        if (self.block) {
            self.block(Close);
        }
    }
    
}

#pragma mark - 原生通知js

//刷新金币
- (void)refreshGameBalance{
    [self.webView evaluateJavaScript:@"window.HttpTool?.NativeToJs('recharge')" completionHandler:^(id response, NSError *error) {
        
        if (error) {
            NSLog(@"原生通知JS--失败");
            
        } else {
            NSLog(@"原生通知JS--成功");
        }
        
    }];
}

//加载过的游戏，直接通知js切换；不用重新load
- (void)openGame:(NSInteger)gameId token:(NSString *)token roomId:(nullable NSString * )roomId ext:(nullable NSString *)ext{
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@(gameId) forKey:@"gameId"];
    [dic setValue:token forKey:@"token"];
    [dic setValue:roomId forKey:@"roomId"];
    [dic setValue:ext forKey:@"ext"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dic options:0 error:&err];
    NSString * str = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    
    NSLog(@"原生通知JS  openGame--%@", str);
    
    [self.webView evaluateJavaScript:Format(@"window.HttpTool?.NativeToJs('openGame', '%@')", str) completionHandler:^(id response, NSError *error) {
        
        if (error) {
            NSLog(@"原生通知JS  openGame--失败");
            
        } else {
            NSLog(@"原生通知JS  openGame--成功");
        }
        
    }];
}

//通知js适应webview新的高度
-(void)noticeResizeToJs:(ASGameWebViewBoolBlock)block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.07*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
        [self.webView evaluateJavaScript:@"window.dispatchEvent(new Event('resize'))" completionHandler:^(id response, NSError *error) {
            
            if (error) {
                NSLog(@"原生通知JS  resize--失败");
                
            } else {
                NSLog(@"原生通知JS  resize--成功");
                block(YES);
            }
            
        }];
    });
}

-(void)noticeExitGameToJs{
    [self.webView evaluateJavaScript:@"window.HttpTool?.NativeToJs('ExitGame')" completionHandler:^(id response, NSError *error) {
        
        if (error) {
            NSLog(@"原生通知JS  ExitGame--失败");
            
        } else {
            NSLog(@"原生通知JS  ExitGame--成功");
        }
        
    }];
}

-(void)resetHeight:(UIView *)view finalHeight:(float)finalHeight{
    CGRect frame = view.frame;
    frame.size.height = finalHeight;
    view.frame = frame;
}

-(void)resetY:(UIView *)view finalY:(float)finalY{
    CGRect frame = view.frame;
    frame.origin.y = finalY;
    view.frame = frame;
}

@end
