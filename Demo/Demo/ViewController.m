//
//  ViewController.m
//  Demo
//
//  Created by apple on 2022/9/30.
//

#import "ViewController.h"
#import <JoySDK/JoyGame.h>
#import "Header.h"
#import "LCCollectionWaterfallLayout.h"
#import "ASGameCollectionViewCell.h"

static NSString *const GameCollectionViewCellID = @"GameCollectionViewCellID";

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, CollectionWaterfallLayoutProtocol>
@property (nonatomic, strong) UIButton *addGameHallBtn;

@property (nonatomic, strong) UITextField  *keyTextField;
@property (nonatomic, strong) UITextField  *tokenTextField;
@property (nonatomic, strong) NSArray *gameListArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL isDebug;
@property (nonatomic, strong) UIButton *gameInitBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.view.backgroundColor = KRedColor;
    // Do any additional setup after loading the view.
    self.isDebug = YES;
    
    NSInteger padding = 15;
    UITextField  *keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(padding, K_StatusNav_Height +10, K_Width- 2*padding, 40)];
    keyTextField.backgroundColor = [self colorWithHexValue:0xeeeeee alpha:1];
    radius(keyTextField);
    keyTextField.font = [UIFont systemFontOfSize:14];
    [keyTextField setPlaceholder:@"AppKey"];
    //keyTextField 左边距
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 20)];
    keyTextField.leftView = paddingView;
    keyTextField.leftViewMode = UITextFieldViewModeAlways;
    keyTextField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview: keyTextField];
    self.keyTextField = keyTextField;
    
    UITextField  *tokenTextField = [[UITextField alloc] initWithFrame:CGRectMake(MinX(keyTextField), MaxY(keyTextField) +15, GetWidth(keyTextField), GetHeight(keyTextField))];
    tokenTextField.backgroundColor = [self colorWithHexValue:0xeeeeee alpha:1];
    radius(tokenTextField);
    tokenTextField.font = [UIFont systemFontOfSize:14];
    [tokenTextField setPlaceholder:@"Token"];
    //tokenTextField 左边距
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 20)];
    tokenTextField.leftView = paddingView1;
    tokenTextField.leftViewMode = UITextFieldViewModeAlways;
    tokenTextField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview: tokenTextField];
    self.tokenTextField = tokenTextField;
    
    UILabel *debugLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(padding, MaxY(tokenTextField) +15, 0, 20);
        
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"测试服";
        [label setFont:SYSTEMFONT(18)];
        
        [label sizeToFit];
        label.hidden = YES;
        label;
    });
    [self.view addSubview:debugLabel];
    
    UISwitch * debugSwitch = [[UISwitch alloc] initWithFrame:(CGRectMake(MaxX(debugLabel), MinY(debugLabel), 0, 0))];
    debugSwitch.center = CGPointMake(debugSwitch.center.x, debugLabel.center.y);
    debugSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [debugSwitch addTarget:self action:@selector(debugSwitchClick) forControlEvents:UIControlEventTouchUpInside];
    debugSwitch.hidden = YES;
    [self.view addSubview:debugSwitch];
    
    UILabel *notDebugLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(MaxX(debugLabel) +51, MinY(debugLabel), 0, 20);
        
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"正式服";
        [label setFont:SYSTEMFONT(18)];
        
        [label sizeToFit];
        label.hidden = YES;
        label;
    });
    [self.view addSubview:notDebugLabel];
    
    UILabel *showFloatingLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(MaxX(notDebugLabel) +15, MinY(notDebugLabel), 0, 20);
        
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"显示悬浮按钮";
        [label setFont:SYSTEMFONT(18)];
        
        [label sizeToFit];
        label;
    });
    [self.view addSubview:showFloatingLabel];
    
    UISwitch * showFloatingSwitch = [[UISwitch alloc] initWithFrame:(CGRectMake(MaxX(showFloatingLabel), MinY(showFloatingLabel), 0, 0))];
    showFloatingSwitch.center = CGPointMake(showFloatingSwitch.center.x, showFloatingLabel.center.y);
    showFloatingSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [showFloatingSwitch addTarget:self action:@selector(showFloatingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showFloatingSwitch];
    
    UIButton *initGameBtn =({
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(MinX(tokenTextField), MaxY(notDebugLabel) +20, GetWidth(tokenTextField), GetHeight(tokenTextField));
        radius(btn);
        
        [btn setTitle:@"初始化SDK" forState:UIControlStateNormal];
        btn.titleLabel.font = SYSTEMFONT(18);
        [btn setTitleColor:KBlackColor forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
        btn.layer.borderColor = KGray2Color.CGColor;
        btn.layer.borderWidth = 1;
        
        [btn addTarget: self action: @selector(initGameBtnClick) forControlEvents: UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:initGameBtn];
    self.gameInitBtn = initGameBtn;
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(10*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
    //        [self destroyeBtnClick];
    //    });
    
    //    [self initGameBtnClick];
}

#pragma mark - 点击事件

- (void)showFloatingBtnClick{
    JoyGame.sharedInstance.showFloatingButton =! JoyGame.sharedInstance.showFloatingButton;
}

- (void)debugSwitchClick{
    self.isDebug =! self.isDebug;
    [self initGameBtnClick];
}

- (void)initGameBtnClick{
    
    if (self.keyTextField.text.length == 0 || self.tokenTextField.text.length == 0) {
        NSLog(@"key或token为空");
        return;
    }
    
    [self.view endEditing:YES];
    
    JoyGame.sharedInstance.isDebug = self.isDebug;
    [JoyGame.sharedInstance initWithAppKey:self.keyTextField.text
                             gameListBlock:^(NSArray<JoyGameInfoModel *> * _Nullable gameList) {
        
        if (gameList.count > 0) {
            NSLog(@"客户端获取到游戏列表");
            // 回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                self.gameListArray = gameList;
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
    
    [JoyGame.sharedInstance openHallWithToken:self.tokenTextField.text roomId:nil ext:nil rootViewController:self eventCode:^(JoyGameEventCode eventCode) {
        if (eventCode == Recharge) {
            NSLog(@"客户端收到游戏  充值点击");
            
        } else if (eventCode == Close) {
            NSLog(@"客户端收到游戏  关闭点击");
        }
    }];
}

- (void)changeFloatingButtonSizeBtnClick{
    [JoyGame.sharedInstance setFloatingButtonFrame:CGRectMake(100, 100, 120, 60)];
}

-(void)turnModeBtnClick:(UIButton*)btn{
    
    self.addGameHallBtn.hidden =! self.addGameHallBtn.hidden;
    self.collectionView.hidden =! self.collectionView.hidden;
    
    if (self.addGameHallBtn.hidden) {
        [btn setTitle:@"切换至  大厅模式" forState:UIControlStateNormal];
        
    } else {
        [btn setTitle:@"切换至  游戏列表模式" forState:UIControlStateNormal];
        
    }
}

-(void)destroyeBtnClick{
    NSLog(@"客户端   hideGameView");
    [JoyGame.sharedInstance hideGameView];
}

-(void)refreshGameBalanceClick{
    NSLog(@"客户端调用刷新");
    [JoyGame.sharedInstance refreshGameBalance];
}

#pragma mark - UI

-(void)initView:(NSArray *)gameList{
    
    if (self.collectionView) {
        [self.collectionView reloadData];
        
    } else {
        UIButton *addGameHallBtn =({
            UIButton *btn = [[UIButton alloc] init];
            btn.frame = CGRectMake(0, MaxY(self.gameInitBtn) +10, K_Width/2, 40);
            
            [btn setTitle:@"打开大厅" forState:UIControlStateNormal];
            [btn setTitleColor:KBlackColor forState:UIControlStateNormal];
            
            btn.layer.borderColor = KGray2Color.CGColor;
            btn.layer.borderWidth = 1;
            
            [btn addTarget: self action: @selector(addGameHallBtnClick) forControlEvents: UIControlEventTouchUpInside];
            btn;
        });
        [self.view addSubview:addGameHallBtn];
        self.addGameHallBtn = addGameHallBtn;
        
        UIButton *turnModeBtn =({
            UIButton *btn = [[UIButton alloc] init];
            btn.frame = CGRectMake(K_Width/2, MinY(addGameHallBtn), K_Width/2, 40);
            btn.backgroundColor = UIColor.grayColor;
            
            [btn setTitle:@"切换至  游戏列表模式" forState:UIControlStateNormal];
            btn.titleLabel.font = SYSTEMFONT(16);
            
            btn.layer.borderColor = KGray2Color.CGColor;
            btn.layer.borderWidth = 1;
            
            [btn addTarget: self action: @selector(turnModeBtnClick:) forControlEvents: UIControlEventTouchUpInside];
            btn;
        });
        [self.view addSubview:turnModeBtn];
        
        LCCollectionWaterfallLayout *collectionWaterfallLayout = [[LCCollectionWaterfallLayout alloc] init];
        collectionWaterfallLayout.delegate = self;
        //列数
        collectionWaterfallLayout.columns = 2;
        //两列之间的距离
        collectionWaterfallLayout.columnSpacing = 10;
        //两个cell的间距
        collectionWaterfallLayout.itemSpacing = 10;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(StudioPadding, MaxY(addGameHallBtn) +20, K_Width -2*StudioPadding, SCREEN_HEIGHT -(MaxY(addGameHallBtn) +20)) collectionViewLayout:collectionWaterfallLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.backgroundColor   = [UIColor clearColor];
        [collectionView registerClass:[ASGameCollectionViewCell class] forCellWithReuseIdentifier:GameCollectionViewCellID];
        
        //    UINib *headerViewNib = [UINib nibWithNibName:@"WFHeaderView" bundle:nil];
        //    [collectionView registerNib:headerViewNib forSupplementaryViewOfKind:kSupplementaryViewKindHeader withReuseIdentifier:GameCollectionViewCellID];
        collectionView.hidden = YES;
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
        
        //        [self turnModeBtnClick:turnModeBtn];
        
    }
    
}

- (UIColor*)colorWithHexValue:(NSInteger)aHexValue
                        alpha:(CGFloat)aAlpha {
    
    return [UIColor colorWithRed:((CGFloat)((aHexValue&0xFF0000)>>16))/255.0
                           green:((CGFloat)((aHexValue&0xFF00)>>8))/255.0
                            blue:((CGFloat)(aHexValue&0xFF))/255.0
                           alpha:aAlpha];
    
}

#pragma mark - UICollectionView配置

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.gameListArray.count) {
        //        [LCPublicKit toastShow:@"Data error"];
        return;
    }
    
    JoyGameInfoModel *joyGameInfoModel = self.gameListArray[indexPath.row];
    
    [JoyGame.sharedInstance openGameWithGameId:joyGameInfoModel.gameId token:self.tokenTextField.text roomId:nil ext:nil rootViewController:self eventCode:^(JoyGameEventCode eventCode) {
        if (eventCode == Recharge) {
            NSLog(@"客户端收到游戏  充值点击");
            
        } else if (eventCode == Close) {
            NSLog(@"客户端收到游戏  关闭点击");
        }
    }];
    
    
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JoyGameInfoModel *model = self.gameListArray[indexPath.row];
    
    ASGameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GameCollectionViewCellID forIndexPath:indexPath];
    cell.joyGameInfoModel = model;
    return cell;
}

//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.gameListArray.count;
}

//定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//定义每个UICollectionViewCell 的高度
- (CGFloat)collectionViewLayout:(LCCollectionWaterfallLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

//头部高度
- (CGFloat)collectionViewLayout:(LCCollectionWaterfallLayout *)layout heightForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
