//
//  ViewController.m
//  Demo
//
//  Created by apple on 2022/9/30.
//

#import "ViewController.h"
#import <JoySDK/JoyGame.h>
#import "Header.h"

static NSString *AppKey = @"";
static NSString *token = @"";

@interface ViewController ()
@property (nonatomic, strong) UIView *gameBtnView;
@property (nonatomic, strong) UIButton *addGameHallBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.view.backgroundColor = KRedColor;
    // Do any additional setup after loading the view.
    UIButton *addGameHallBtn =({
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(100, SCREEN_HEIGHT*2/3, 200, 40);
        
        [btn setTitle:@"addGameHallBtn" forState:UIControlStateNormal];
        [btn setTitleColor:KBlackColor forState:UIControlStateNormal];
        
        btn.layer.borderColor = KGray2Color.CGColor;
        btn.layer.borderWidth = 1;
        
        [btn addTarget: self action: @selector(addGameHallBtnClick) forControlEvents: UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:addGameHallBtn];
    self.addGameHallBtn = addGameHallBtn;
    
    [JoyGame.sharedInstance initWithAppKey:AppKey
                             gameListBlock:^(NSArray<JoyGameInfoModel *> * _Nullable gameList) {
        
        if (gameList.count > 0) {
            NSLog(@"客户端获取到游戏列表");
            // 回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initView:gameList];
            });
            
        } else {
            NSLog(@"客户端获取到游戏列表为空");
        }
        
    } error:^(JoyStateCode errorCode) {
        NSLog(@"客户端获取游戏列表失败  %lu", (unsigned long)errorCode);
    }];
    
}

-(void)addGameHallBtnClick{
    NSLog(@"客户端  addGameHallBtnClick");
    
    [JoyGame.sharedInstance openHallWithToken:token roomId:nil ext:nil rootViewController:self eventCode:^(JoyGameEventCode eventCode) {
        if (eventCode == Recharge) {
            NSLog(@"客户端收到游戏  充值点击");
            
        } else if (eventCode == Close) {
            NSLog(@"客户端收到游戏  关闭点击");
        }
    }];
}

-(void)gameBtnClick:(UIButton *)btn{
    NSLog(@"客户端  gameBtnClick");
    
    [JoyGame.sharedInstance openGameWithGameId:btn.tag token:token roomId:nil ext:nil rootViewController:self eventCode:^(JoyGameEventCode eventCode) {
        if (eventCode == Recharge) {
            NSLog(@"客户端收到游戏  充值点击");
            
        } else if (eventCode == Close) {
            NSLog(@"客户端收到游戏  关闭点击");
        }
    }];
}

-(void)refreshGameBalanceClick{
    NSLog(@"客户端调用刷新");
    [JoyGame.sharedInstance refreshGameBalance];
}

-(void)initView:(NSArray *)gameList{
    UIButton *refreshGameBalanceBtn =({
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(100, 40, 200, 40);
        
        [btn setTitle:@"refreshGameBalance" forState:UIControlStateNormal];
        [btn setTitleColor:KBlackColor forState:UIControlStateNormal];
        
        btn.layer.borderColor = KGray2Color.CGColor;
        btn.layer.borderWidth = 1;
        
        [btn addTarget: self action: @selector(refreshGameBalanceClick) forControlEvents: UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:refreshGameBalanceBtn];
    
    UIButton *changeFloatingButtonSizeBtn =({
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(100, MaxY(refreshGameBalanceBtn) +20, 200, 40);
        
        [btn setTitle:@"changeSize" forState:UIControlStateNormal];
        [btn setTitleColor:KBlackColor forState:UIControlStateNormal];
        
        btn.layer.borderColor = KGray2Color.CGColor;
        btn.layer.borderWidth = 1;
        
        [btn addTarget: self action: @selector(changeFloatingButtonSizeBtnClick) forControlEvents: UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:changeFloatingButtonSizeBtn];
    
    UIButton *destroyeBtn =({
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(100, MaxY(changeFloatingButtonSizeBtn) +20, 200, 40);
        
        [btn setTitle:@"hide" forState:UIControlStateNormal];
        [btn setTitleColor:KBlackColor forState:UIControlStateNormal];
        
        btn.layer.borderColor = KGray2Color.CGColor;
        btn.layer.borderWidth = 1;
        
        [btn addTarget: self action: @selector(destroyeBtnClick) forControlEvents: UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:destroyeBtn];
    
    UIView *gameBtnView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*2/3, K_Width, 30)];
        view.hidden = YES;
        view;
    });
    [self.view addSubview:gameBtnView];
    self.gameBtnView = gameBtnView;
    
    for (int i=0; i<gameList.count; i++) {
        JoyGameInfoModel *model = gameList[i];
        
        UIButton *gameBtn =({
            UIButton *btn = [[UIButton alloc] init];
            btn.frame = CGRectMake((K_Width/gameList.count -2)*i, 0, K_Width/gameList.count -4, 30);
            
            [btn setTitle:model.gameName forState:UIControlStateNormal];
            btn.titleLabel.font = SYSTEMFONT(15);
            [btn setTitleColor:KBlackColor forState:UIControlStateNormal];
            
            btn.layer.borderColor = KGray2Color.CGColor;
            btn.layer.borderWidth = 1;
            
            btn.tag = model.gameId;
            [btn addTarget: self action: @selector(gameBtnClick:) forControlEvents: UIControlEventTouchUpInside];
            btn;
        });
        [gameBtnView addSubview:gameBtn];
    }
    
    UIButton *turnModeBtn =({
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(0, SCREEN_HEIGHT*3/4, K_Width, 40);
        btn.backgroundColor = UIColor.grayColor;
        
        [btn setTitle:@"切换至  游戏列表模式" forState:UIControlStateNormal];
        btn.titleLabel.font = SYSTEMFONT(16);
        
        btn.layer.borderColor = KGray2Color.CGColor;
        btn.layer.borderWidth = 1;
        
        [btn addTarget: self action: @selector(turnModeBtnClick:) forControlEvents: UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:turnModeBtn];
}

- (void)changeFloatingButtonSizeBtnClick{
    [JoyGame.sharedInstance setFloatingButtonFrame:CGRectMake(100, 100, 120, 60)];
}

-(void)turnModeBtnClick:(UIButton*)btn{
    
    self.addGameHallBtn.hidden =! self.addGameHallBtn.hidden;
    self.gameBtnView.hidden =! self.gameBtnView.hidden;
    
    if (self.addGameHallBtn.hidden) {
        [btn setTitle:@"切换至  大厅模式" forState:UIControlStateNormal];
        
    } else {
        [btn setTitle:@"切换至  游戏列表模式" forState:UIControlStateNormal];
        
    }
}

-(void)destroyeBtnClick{
    [JoyGame.sharedInstance hideGameView];
}

@end
