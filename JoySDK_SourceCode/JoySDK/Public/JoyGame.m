//
//  JoyGame.m
//  JoySDK
//
//  Created by apple on 2022/9/30.
//

#import "JoyGame.h"
#import "Header.h"
#import "JoyGameWebView.h"
#import "JoyFloatBaseView.h"

static NSString *const HasOpenGameArrayKey = @"HasOpenGameArrayKey";

typedef void(^JoyGameBoolBlock)(BOOL isSuccess);

typedef void(^EventCodeBlock)(JoyGameEventCode eventCode);

@interface JoyGame()

@property (strong, nonatomic) NSMutableArray *gameDataArray;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *lobby;
@property (nonatomic, strong) JoyGameWebView *gameWebView;
@property (nonatomic , assign) NSInteger lobbyHeightScale;
@property (nonatomic , assign) NSInteger lobbyWidthScale;
@property (nonatomic, strong) NSMutableArray *hasOpenGameArray; //游戏列表模式  打开过的游戏
@property (nonatomic, assign) BOOL isHallHasPreloaded;  //当前webview是否处于大厅状态；否则opengame可能出问题

/*
 因为第一次load游戏的时候，即使点击空白区域关闭webview之后，h5还是返回了opengamesuccess；所以要一个标志位标记用户已经主动关闭webview，即使opengamesuccess也不要处理
 */
@property (nonatomic, assign) BOOL isShowGameAble;
@property (nonatomic, strong) UIImageView *floatGameImageView;
@property (nonatomic, strong) JoyFloatBaseView *floatView;
@property (nonatomic, assign) BOOL isHasLoadingview;
@property (nonatomic, assign) CGRect floatViewFrame;
@property (nonatomic, strong) UIButton *closeFloatGameBtn;

@property (nonatomic, assign) NSInteger gameId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *ext;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, copy) EventCodeBlock eventCodeBlock;
@end

@interface JoyGameHoleInfoModel :NSObject
@property (nonatomic , copy) NSString *iconUrl;
@property (nonatomic , copy) NSString *gameName;
@property (nonatomic , assign) NSInteger gameId;
@property (nonatomic , assign) NSInteger heightScale;
@property (nonatomic , assign) NSInteger widthScale;
@property (nonatomic , assign) BOOL isCPGame;
@property (nonatomic , copy) NSString *gameUrl;
@end

@implementation JoyGame

+(instancetype)sharedInstance{
    static JoyGame *joyGame = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        joyGame = [[self alloc]init];
    });
    return joyGame;
}

#pragma mark - 初始化

- (void)initWithAppKey:(NSString *)appKey
         gameListBlock:(void (^)(NSArray<JoyGameInfoModel *> * _Nullable gameList))gameListBlock
                 error:(void (^)(JoyStateCode errorCode))errorBlock{
    
    [self initWithAppKey:appKey gameListBlock:^(NSArray<JoyGameInfoModel *> * _Nullable gameList) {
        gameListBlock(gameList);
        
    } error:^(JoyStateCode errorCode) {
        errorBlock(errorCode);
        
    } preloadHallDone:^(BOOL isSuccess) {
        
    }];
    
}

//点击游戏或大厅，判断Webview存不存在
- (void)checkWebviewExists:(JoyGameBoolBlock)isWebviewReady{
    if (self.gameWebView) {
        isWebviewReady(YES);
        
    }else{
        NSLog(@"gameWebView不存在  重新初始化");
        
        [self initWithAppKey:self.appKey gameListBlock:^(NSArray<JoyGameInfoModel *> * _Nullable gameList) {
            
        } error:^(JoyStateCode errorCode) {
            
        } preloadHallDone:^(BOOL isSuccess) {
            isWebviewReady(isSuccess);
        }];
    }
}

- (void)initWithAppKey:(NSString *)appKey
         gameListBlock:(void (^)(NSArray<JoyGameInfoModel *> * _Nullable gameList))gameListBlock
                 error:(void (^)(JoyStateCode errorCode))errorBlock
       preloadHallDone:(JoyGameBoolBlock)preloadHallDoneBlock{
    
    self.appKey = appKey;
    self.hasOpenGameArray = [[NSMutableArray alloc] initWithArray:[NSUserDefaults.standardUserDefaults arrayForKey:HasOpenGameArrayKey]];
    
    //网络请求
    NSString *urlString;
    if (self.isDebug == YES) {
        urlString = @"https://joysdk.com/game/game/initSDK";
        
    } else {
        urlString = @"https://joysdk.com/game/game/initSDK";
    }
    
    //拼接包名用于控制游戏列表的显示
    NSString *pkgName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *holeStr = Format(@"%@?appKey=%@&pkgName=%@", urlString, appKey, pkgName);
    
    NSURLSession * session= [NSURLSession sharedSession];
    NSURLSessionDataTask * dataTask= [session dataTaskWithURL:[NSURL URLWithString:holeStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        self.gameDataArray = [NSMutableArray new];
        NSMutableArray *gameListArray = [NSMutableArray new];
        
        if (error) {
            errorBlock(NETWORK_ERROR);
            
        }else if (data == NULL || data.length == 0){
            errorBlock(SERVER_ERROR);
            
        }else {
            NSError *jsonError;
            NSDictionary *jsonobject=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            NSInteger status = [[jsonobject objectForKey:@"status"] integerValue];
            
            if (status != 200) {
                errorBlock(status);
                
            } else {
                
                NSDictionary *data = [jsonobject objectForKey:@"data"];
                self.lobby = [data objectForKey:@"lobby"];
                self.lobbyHeightScale = [[data objectForKey:@"height"] integerValue];
                self.lobbyWidthScale = [[data objectForKey:@"width"] integerValue];
                
                // 回到主线程，预加载大厅
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self preloadHall:^(BOOL isSuccess) {
                        preloadHallDoneBlock(isSuccess);
                    }];
                });
                
                for (NSDictionary *dic in [data objectForKey:@"gameList"]) {
                    
                    JoyGameInfoModel *model = [JoyGameInfoModel new];
                    model.iconUrl = [dic objectForKey:@"iconUrl"];
                    model.gameName = [dic objectForKey:@"gameName"];
                    model.gameId = [[dic objectForKey:@"gameId"] integerValue];
                    [gameListArray addObject:model];
                    
                    id heightId = [dic objectForKey:@"height"];
                    id widthId = [dic objectForKey:@"width"];
                    
                    NSInteger height = [[heightId isKindOfClass:[NSNull class]] ?@(1) :heightId integerValue];
                    NSInteger width = [[widthId isKindOfClass:[NSNull class]] ?@(1) :widthId integerValue];
                    
                    JoyGameHoleInfoModel *holeModel = [JoyGameHoleInfoModel new];
                    holeModel.iconUrl = [dic objectForKey:@"iconUrl"];
                    holeModel.gameName = [dic objectForKey:@"gameName"];
                    holeModel.gameId = [[dic objectForKey:@"gameId"] integerValue];
                    holeModel.heightScale = height;
                    holeModel.widthScale = width;
                    holeModel.gameUrl = [dic objectForKey:@"gameUrl"];
                    holeModel.isCPGame = [[dic objectForKey:@"isCPGame"] boolValue];
                    [self.gameDataArray addObject:holeModel];
                }
                
            }
        }
        
        gameListBlock(gameListArray);
        
    }];
    [dataTask resume];
    
}

#pragma mark - 预加载大厅

-(void)preloadHall:(JoyGameBoolBlock)preloadHallDoneBlock{
    
    NSString *holeGameUrl = Format(@"%@&gameId=%d", [self baseUrl], 0);
    
    //WebView额外增加50高度，因为加在keyWindow上，WebView莫名倒转
    JoyGameWebView *gameWebView = [[JoyGameWebView alloc] initWithFrame:UIApplication.sharedApplication.keyWindow.bounds];
    [gameWebView loadUrl:holeGameUrl];
    self.gameWebView = gameWebView;
    
    gameWebView.hidden = YES;
    [UIApplication.sharedApplication.keyWindow addSubview:gameWebView];
    
    //游戏加载完毕回调，持久化数组
    __weak typeof(self) weakSelf = self;
    gameWebView.hasOpenGameIdblock = ^(JoyGameEventCode block) {
        __strong typeof(weakSelf) self = weakSelf;
        
        //gameId不是0，即不是大厅
        if (block != 0) {
            
            //判断用户是否已经主动关闭webview，没有的话才显示webview
            if (self.isShowGameAble) {
                
                for (JoyGameHoleInfoModel *joyGameHoleInfoModel in self.gameDataArray) {
                    if (joyGameHoleInfoModel.gameId == block) {
                        
                        //                    NSLog(@"OpenGameSucc  改变webview尺寸");
                        
                        //先改变webview高度，之后通知js撑满
                        float targetHeight = K_Width *joyGameHoleInfoModel.heightScale /joyGameHoleInfoModel.widthScale;
                        
                        //load-url，有loading动画，在原基础上直接升起
                        if (self.isHasLoadingview) {
                            [self.gameWebView setWebViewHeight: targetHeight];
                            
                            //opengame，没有loading动画，把webview重置到底部，再升起
                        } else {
                            [self.gameWebView setWebViewHeightToBottom: targetHeight];
                        }
                        
                        //让js撑满webview
                        [self.gameWebView noticeResizeToJs:^(BOOL isSuccess) {
                            
                            //撑满成功，动画使webview上移；这样不会露出父视图
                            [UIView animateWithDuration:0.6 animations:^{
                                [self.gameWebView setWebViewOriginY];
                                
                            }completion:^(BOOL finished) {
                                
                            }];
                        }];
                        break;
                    }
                }
                
                self.gameWebView.hidden = NO;
                
            } else {
                NSLog(@"用户已经主动关闭webview  收到OpenGameSucc不处理");
                [self.gameWebView noticeExitGameToJs];
            }
            
            self.isHallHasPreloaded = NO;
            
        }else{
            self.isHallHasPreloaded = YES;
        }
        
        //持久化数组，应付游戏列表模式；第二次点击的游戏，通知js-opengame，而不是load-url，这样快一点
        if (![self.hasOpenGameArray containsObject:@(block)]) {
            [self.hasOpenGameArray addObject:@(block)];
            [NSUserDefaults.standardUserDefaults setObject:self.hasOpenGameArray forKey:HasOpenGameArrayKey];
        }
        
    };
    
    preloadHallDoneBlock(YES);
    
}

-(NSString *)baseUrl{
    NSString *pkgName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    return Format(@"%@?mini=1&appKey=%@&pkgName=%@",
                  self.lobby,
                  self.appKey,
                  pkgName);
}

#pragma mark - 使用游戏列表

-(void)openGameWithGameId:(NSInteger)gameId token:(NSString *)token roomId:(nullable NSString * )roomId ext:(nullable NSString *)ext rootViewController:(UIViewController *)rootViewController eventCode:(EventCodeBlock)eventCodeBlock{
    
    [self openGameWithGameId:gameId token:token roomId:roomId ext:ext rootViewController:rootViewController eventCode:^(JoyGameEventCode eventCode) {
        
        eventCodeBlock(eventCode);
        
    } isFloatViewClick:NO];
}

-(void)openGameWithGameId:(NSInteger)gameId token:(NSString *)token roomId:(nullable NSString * )roomId ext:(nullable NSString *)ext rootViewController:(UIViewController *)rootViewController eventCode:(EventCodeBlock)eventCodeBlock isFloatViewClick:(BOOL)isFloatViewClick{
    self.isShowGameAble = YES;
    self.floatView.hidden = YES;
    
    //存起来是为了在点击悬浮球按钮时，调用openGameWithGameId
    self.gameId = gameId;
    self.token = token;
    self.roomId = roomId;
    self.ext = ext;
    self.rootViewController = rootViewController;
    if (!isFloatViewClick) {
        self.eventCodeBlock = eventCodeBlock;
    }
    [self floatGameViewBuild];
    
    if (rootViewController == nil){
        NSLog(@"根控制器为空");
        return;
    }
    
    if (self.gameDataArray.count < 1) {
        NSLog(@"游戏列表为空，请重新初始化");
        return;
    }
    
    [self checkWebviewExists:^(BOOL isSuccess) {
        
        JoyGameHoleInfoModel *currentJoyGameHoleInfoModel;
        for (JoyGameHoleInfoModel *joyGameHoleInfoModel in self.gameDataArray) {
            if (joyGameHoleInfoModel.gameId == gameId) {
                currentJoyGameHoleInfoModel = joyGameHoleInfoModel;
                
                //                NSLog(@"改变webview尺寸");
                [self.gameWebView setWebViewHeightToBottom: K_Width *joyGameHoleInfoModel.heightScale /joyGameHoleInfoModel.widthScale];
                [UIView animateWithDuration:0.6 animations:^{
                    
                    [self.gameWebView setWebViewOriginY];
                    
                }completion:^(BOOL finished) {
                    
                }];
                [self.gameWebView removeFromSuperview];
                [rootViewController.view addSubview:self.gameWebView];
                
                //让js刷新尺寸
                [self.gameWebView noticeResizeToJs:^(BOOL isSuccess) {
                    
                }];
                
                break;
            }
        }
        
        //之前缓存过的游戏，直接通知js刷新
        if ([self.hasOpenGameArray containsObject:@(gameId)] && self.isHallHasPreloaded && currentJoyGameHoleInfoModel.isCPGame == 0) {
            self.isHasLoadingview = NO;
            
            [self.gameWebView openGame:gameId token:token roomId:roomId ext:ext];
            
            //没有缓存过的游戏，load
        } else {
            //A游戏load的过程中，大厅不响应js通知；若此时点击缓存过的B游戏，最好重新load；否则还是会打开A游戏
            self.isHallHasPreloaded = NO;
            self.isHasLoadingview = YES;
            
            NSLog(@"没有缓存过的游戏 或者大厅预加载没完成，直接load");
            
            NSString *holeGameUrl;
            if (currentJoyGameHoleInfoModel.isCPGame == 0) {
                holeGameUrl = Format(@"%@&gameId=%ld&token=%@&roomId=%@&ext=%@",
                                     [self baseUrl],
                                     (long)gameId,
                                     token,
                                     roomId,
                                     ext);
                
            } else {
                holeGameUrl = currentJoyGameHoleInfoModel.gameUrl;
            }
            
            [self.gameWebView loadUrl:holeGameUrl];
            
            //延时0.3秒的原因：大厅预加载成功，游戏没有缓存过，loadUrl之后马上显示gameWebView的话，会看到游戏大厅
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.3*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
                self.gameWebView.hidden = NO;
            });
        }
        
        //游戏点击事件回调和处理
        __weak typeof(self) weakSelf = self;
        self.gameWebView.block = ^(JoyGameEventCode block) {
            __strong typeof(weakSelf) self = weakSelf;
            
            if (block == Close) {
                
                //判断isShowGameAble，防止回调两次关闭事件给客户端
                if (self.isShowGameAble) {
                    self.isShowGameAble = NO;
                    
                    self.eventCodeBlock(block);
                    [self hideGameView];
                }
                
            }else{
                self.eventCodeBlock(block);
            }
        };
        
    }];
    
}

#pragma mark - 使用游戏大厅

-(void)openHallWithToken:(NSString *)token roomId:(nullable NSString * )roomId ext:(nullable NSString *)ext rootViewController:(UIViewController *)rootViewController eventCode:(void (^)(JoyGameEventCode eventCode))eventCodeBlock{
    self.isShowGameAble = YES;
    self.floatView.hidden = YES;
    
    //存起来是为了在点击悬浮球按钮时，调用openGameWithGameId
    self.token = token;
    self.roomId = roomId;
    self.ext = ext;
    self.rootViewController = rootViewController;
    self.eventCodeBlock = eventCodeBlock;
    if (rootViewController == nil){
        NSLog(@"根控制器为空");
        return;
    }
    
    [self checkWebviewExists:^(BOOL isSuccess) {
        
        [self.gameWebView setWebViewHeightToBottom: K_Width *self.lobbyHeightScale /self.lobbyWidthScale];
        [UIView animateWithDuration:0.6 animations:^{
            
            [self.gameWebView setWebViewOriginY];
            
        }completion:^(BOOL finished) {
            
        }];
        [self.gameWebView removeFromSuperview];
        [rootViewController.view addSubview:self.gameWebView];
        
        //大厅预加载未完成，调用openGame会报错
        if (!self.isHallHasPreloaded) {
            self.isHasLoadingview = YES;
            
            NSLog(@"大厅预加载未完成  直接重新load大厅");
            NSString *holeGameUrl = Format(@"%@&gameId=%d&token=%@&roomId=%@&ext=%@",
                                           [self baseUrl],
                                           0,
                                           token,
                                           roomId,
                                           ext);
            [self.gameWebView loadUrl:holeGameUrl];
            
        }else{
            self.isHasLoadingview = NO;
            [self.gameWebView openGame:0 token:token roomId:roomId ext:ext];
        }
        self.gameWebView.hidden = NO;
        
        //大厅点击游戏
        __weak typeof(self) weakSelf = self;
        self.gameWebView.beginOpenGameIdblock = ^(JoyGameEventCode block) {
            __strong typeof(weakSelf) self = weakSelf;
            
            //A游戏load的过程中，关闭大厅再打开，最好重新load大厅；否则点击B游戏，打开的还是A游戏
            self.isHallHasPreloaded = NO;
            self.isHasLoadingview = YES;
            
            self.gameId = block;
            [self floatGameViewBuild];
        };
        
        //游戏点击事件回调和处理
        self.gameWebView.block = ^(JoyGameEventCode block) {
            __strong typeof(weakSelf) self = weakSelf;
            
            if (block == Close) {
                
                //判断isShowGameAble，防止回调两次关闭事件给客户端
                if (self.isShowGameAble) {
                    self.isShowGameAble = NO;
                    
                    self.eventCodeBlock(block);
                    [self hideGameView];
                }
                
            }else{
                self.eventCodeBlock(block);
            }
        };
        
    }];
    
}

#pragma mark - 悬浮按钮

- (void)setFloatingButtonFrame:(CGRect)frame{
    if (!self.showFloatingButton) {
        return;
    }
    
    self.floatViewFrame = frame;
    [self floatViewFrameSet];
}

- (void)floatGameViewBuild{
    if (!self.showFloatingButton) {
        return;
    }
    
    if (!self.floatView) {
        
        //悬浮父view
        JoyFloatBaseView *floatView = [[JoyFloatBaseView alloc] initWithRootViewController:self.rootViewController];
        
        //悬浮按钮点击，打开游戏
        floatView.floatViewDidClickBlock = ^(JoyFloatBaseView * _Nonnull floatView) {
            [self openGameWithGameId:self.gameId token:self.token roomId:self.roomId ext:self.ext rootViewController:self.rootViewController eventCode:^(JoyGameEventCode eventCode) {
                
            } isFloatViewClick:YES];
            
        };
        
        //        floatView.backgroundColor = KRedColor;
        floatView.hidden = YES;
        [self.rootViewController.view addSubview:floatView];
        self.floatView = floatView;
        
        //悬浮图片
        UIImageView *floatGameImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            
            imageView;
        });
        [floatView addSubview:floatGameImageView];
        self.floatGameImageView = floatGameImageView;
        
        //bundle文件放在demo工程，不是放在SDK
        //UIImage *img = [UIImage imageNamed:@"JoySDKResources.bundle/close@2x.png" inBundle: [NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        
        //关闭按钮
        UIButton *closeFloatGameBtn =({
            UIButton *btn = [[UIButton alloc] init];
            btn.backgroundColor = [self colorWithHexValue:0x000000 alpha:0.5];
            
            [btn setTitle:@"X" forState:UIControlStateNormal];
            btn.titleLabel.font = BOLDSYSTEMFONT(12);
            
            //[btn setImage:img forState:UIControlStateNormal];
            //btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
            
            [btn addTarget: self action: @selector(closeFloatGameBtnClick) forControlEvents: UIControlEventTouchUpInside];
            btn;
        });
        [floatView addSubview:closeFloatGameBtn];
        self.closeFloatGameBtn = closeFloatGameBtn;
        
        [self floatViewFrameSet];
    }
    
    //设置最新的游戏图片
    for (JoyGameHoleInfoModel *joyGameHoleInfoModel in self.gameDataArray) {
        if (joyGameHoleInfoModel.gameId == self.gameId) {
            
            if ([joyGameHoleInfoModel.iconUrl isKindOfClass:[NSNull class]]) {
                return;
            }
            
            //dataWithContentsOfURL卡顿，在子线程解决
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                UIImage *iconImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:joyGameHoleInfoModel.iconUrl]]];
                // 设置图片，要回到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.floatGameImageView.image = iconImage;
                    
                });
            });
            break;
        }
    }
    
}

//设置悬浮球坐标
- (void)floatViewFrameSet{
    self.floatView.frame = !CGRectEqualToRect(self.floatViewFrame, CGRectZero) ?self.floatViewFrame :CGRectMake(K_Width -60 -7, SCREEN_HEIGHT *2/3, 60, 60);
    self.floatGameImageView.frame = CGRectMake(0, 5, GetWidth(self.floatView) -5, GetHeight(self.floatView) -5);
    radiusCorner(self.floatGameImageView, 7);
    
    NSInteger closeFloatGameBtnSize = 15;
    self.closeFloatGameBtn.frame = CGRectMake(GetWidth(self.floatView) -closeFloatGameBtnSize, 0, closeFloatGameBtnSize, closeFloatGameBtnSize);
    radius(self.closeFloatGameBtn);
}

- (void)closeFloatGameBtnClick{
    self.floatView.hidden = YES;
}

#pragma mark - 刷新金币

-(void)refreshGameBalance{
    [self.gameWebView refreshGameBalance];
}

- (void)hideGameView{
    //客户端主动调用该接口，要noticeExitGameToJs，让游戏返回大厅
    if (self.isShowGameAble) {
        self.isShowGameAble = NO;
        [self.gameWebView noticeExitGameToJs];
    }
    
    //    NSLog(@"隐藏webview");
    self.gameWebView.hidden = YES;
    
    if (self.showFloatingButton){
        [self.floatView removeFromSuperview];
        [self.rootViewController.view addSubview:self.floatView];
        self.floatView.hidden = NO;
    }
    
}

- (UIColor*)colorWithHexValue:(NSInteger)aHexValue
                        alpha:(CGFloat)aAlpha {
    
    return [UIColor colorWithRed:((CGFloat)((aHexValue&0xFF0000)>>16))/255.0
                           green:((CGFloat)((aHexValue&0xFF00)>>8))/255.0
                            blue:((CGFloat)(aHexValue&0xFF))/255.0
                           alpha:aAlpha];
    
}

@end

@implementation JoyGameHoleInfoModel
@end
