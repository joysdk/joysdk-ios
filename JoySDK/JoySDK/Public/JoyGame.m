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

@interface JoyGame()

@property (strong, nonatomic) NSMutableArray *gameDataArray;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *lobby;
@property (nonatomic, strong) JoyGameWebView *gameWebView;
@property (nonatomic , assign) NSInteger lobbyHeightScale;
@property (nonatomic , assign) NSInteger lobbyWidthScale;
@property (nonatomic, strong) NSMutableArray *hasOpenGameArray; //游戏列表模式  打开过的游戏
@property (nonatomic, assign) BOOL isHallHasPreloaded;  //当前webview是否处于大厅状态；否则opengame可能出问题
@property (nonatomic, assign) BOOL isShowGameAble;  //用户主动关闭游戏，收到opengame成功也不处理
@property (nonatomic, strong) UIImageView *floatGameImageView;
@property (nonatomic, strong) JoyFloatBaseView *floatView;
@property (nonatomic, assign) BOOL isHallMode;
@property (nonatomic, assign) CGRect floatViewFrame;
@property (nonatomic, strong) UIButton *closeFloatGameBtn;

@property (nonatomic, assign) NSInteger gameId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *ext;
@property (nonatomic, strong) UIViewController *rootViewController;
@end

@interface JoyGameHoleInfoModel :NSObject
@property (nonatomic , copy) NSString *iconUrl;
@property (nonatomic , copy) NSString *gameName;
@property (nonatomic , assign) NSInteger gameId;
@property (nonatomic , assign) NSInteger heightScale;
@property (nonatomic , assign) NSInteger widthScale;
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
    NSString *urlString = @"https://joysdk.com/game/game/initSDK";
    NSString *holeStr = Format(@"%@?appKey=%@", urlString, appKey);
    NSURL *listURL = [NSURL URLWithString:holeStr];
    NSURLSession * session= [NSURLSession sharedSession];
    NSURLSessionDataTask * dataTask= [session dataTaskWithURL:listURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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
            
            for (JoyGameHoleInfoModel *joyGameHoleInfoModel in self.gameDataArray) {
                if (joyGameHoleInfoModel.gameId == block) {
                    
                    NSLog(@"OpenGameSucc  改变webview尺寸");
                    
                    //先改变webview高度，之后通知js撑满
                    float targetHeight = K_Width *joyGameHoleInfoModel.heightScale /joyGameHoleInfoModel.widthScale;
                    
                    //大厅模式，在大厅的高度上直接升起
                    if (self.isHallMode) {
                        [self.gameWebView setWebViewHeight: targetHeight];
                        
                        //游戏列表模式，把webview重置到底部，再升起
                    } else {
                        if ([self.gameWebView getWebViewHeight] != targetHeight) {
                            [self.gameWebView setWebViewHeightToBottom: targetHeight];
                        }
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
            
            if (self.isShowGameAble) {
                self.gameWebView.hidden = NO;
                
            } else {
                NSLog(@"用户主动点击关闭之后  收到OpenGameSucc不处理");
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
    return Format(@"%@?mini=1&appKey=%@",
                  self.lobby,
                  self.appKey);
}

#pragma mark - 使用游戏列表

-(void)openGameWithGameId:(NSInteger)gameId token:(NSString *)token roomId:(nullable NSString * )roomId ext:(nullable NSString *)ext rootViewController:(UIViewController *)rootViewController eventCode:(void (^)(JoyGameEventCode eventCode))eventCodeBlock{
    self.isShowGameAble = YES;
    self.floatView.hidden = YES;
    self.isHallMode = NO;
    
    self.gameId = gameId;
    self.token = token;
    self.roomId = roomId;
    self.ext = ext;
    self.rootViewController = rootViewController;
    [self floatGameViewBuild];
    
    if (rootViewController == nil){
        NSLog(@"根控制器为空");
        return;
    }
    
    [self checkWebviewExists:^(BOOL isSuccess) {
        
        if (self.gameDataArray.count < 1) {
            return;
        }
        
        for (JoyGameHoleInfoModel *joyGameHoleInfoModel in self.gameDataArray) {
            if (joyGameHoleInfoModel.gameId == gameId) {
                
                NSLog(@"改变webview尺寸");
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
        if ([self.hasOpenGameArray containsObject:@(gameId)] && self.isHallHasPreloaded) {
            [self.gameWebView openGame:gameId token:token roomId:roomId ext:ext];
            
            //没有缓存过的游戏，load
        } else {
            NSLog(@"没有缓存过的游戏 或者大厅预加载没完成，直接load");
            NSString *holeGameUrl = Format(@"%@&gameId=%ld&token=%@&roomId=%@&ext=%@",
                                           [self baseUrl],
                                           (long)gameId,
                                           token,
                                           roomId,
                                           ext);
            
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
                if (self.isShowGameAble) {
                    eventCodeBlock(block);
                    [self hideGameView];
                }
                
            }else{
                eventCodeBlock(block);
            }
        };
        
    }];
    
}

#pragma mark - 使用游戏大厅

-(void)openHallWithToken:(NSString *)token roomId:(nullable NSString * )roomId ext:(nullable NSString *)ext rootViewController:(UIViewController *)rootViewController eventCode:(void (^)(JoyGameEventCode eventCode))eventCodeBlock{
    self.isShowGameAble = YES;
    self.floatView.hidden = YES;
    self.isHallMode = YES;
    
    self.token = token;
    self.roomId = roomId;
    self.ext = ext;
    self.rootViewController = rootViewController;
    
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
            NSLog(@"大厅预加载未完成  直接重新load大厅");
            NSString *holeGameUrl = Format(@"%@&gameId=%d&token=%@&roomId=%@&ext=%@",
                                           [self baseUrl],
                                           0,
                                           token,
                                           roomId,
                                           ext);
            [self.gameWebView loadUrl:holeGameUrl];
            
        }else{
            [self.gameWebView openGame:0 token:token roomId:roomId ext:ext];
        }
        self.gameWebView.hidden = NO;
        
        //大厅点击游戏
        __weak typeof(self) weakSelf = self;
        self.gameWebView.beginOpenGameIdblock = ^(JoyGameEventCode block) {
            __strong typeof(weakSelf) self = weakSelf;
            
            self.gameId = block;
            [self floatGameViewBuild];
        };
        
        //游戏点击事件回调和处理
        self.gameWebView.block = ^(JoyGameEventCode block) {
            __strong typeof(weakSelf) self = weakSelf;
            
            if (block == Close) {
                if (self.isShowGameAble) {
                    eventCodeBlock(block);
                    [self hideGameView];
                }
                
            }else{
                eventCodeBlock(block);
            }
        };
        
    }];
    
}

#pragma mark - 悬浮按钮

- (void)setFloatingButtonFrame:(CGRect)frame{
    self.floatViewFrame = frame;
    [self floatViewFrameSet];
}

- (void)floatGameViewBuild{
    if (!self.floatView) {
        
        //悬浮父view
        JoyFloatBaseView *floatView = [[JoyFloatBaseView alloc] initWithRootViewController:self.rootViewController];
        
        //悬浮按钮点击，打开游戏
        floatView.floatViewDidClickBlock = ^(JoyFloatBaseView * _Nonnull floatView) {
            
            [self openGameWithGameId:self.gameId token:self.token roomId:self.roomId ext:self.ext rootViewController:self.rootViewController eventCode:^(JoyGameEventCode eventCode) {
                
            }];
            
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
    self.floatView.frame = !CGRectEqualToRect(self.floatViewFrame, CGRectZero) ?self.floatViewFrame :CGRectMake(K_Width -60 -10, SCREEN_HEIGHT *2/3, 60, 60);
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
    NSLog(@"隐藏webview");
    self.gameWebView.hidden = YES;
    self.isShowGameAble = NO;
    
    self.floatView.hidden = NO;
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
