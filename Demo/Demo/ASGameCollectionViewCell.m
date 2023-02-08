//
//  ASGameCollectionViewCell.m
//  anchorlive
//
//  Created by apple on 2022/10/27.
//

#import "ASGameCollectionViewCell.h"
#import "Header.h"

@interface ASGameCollectionViewCell()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation ASGameCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self buildUI];
        
    }
    return self;
}

- (void)setJoyGameInfoModel:(JoyGameInfoModel *)joyGameInfoModel{
    
    if (![joyGameInfoModel.iconUrl isKindOfClass:[NSNull class]]) {
        //dataWithContentsOfURL卡顿，在子线程解决
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            UIImage *iconImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:joyGameInfoModel.iconUrl]]];
            // 设置图片，要回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                self.iconImageView.image = iconImage;
                
            });
        });
    }

    self.nameLabel.text = joyGameInfoModel.gameName;
}

-(void)buildUI{
    
    NSInteger imageViewSize = GetHeight(self) -20;
    UIImageView *iconImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(Middle(GetWidth(self), imageViewSize), 0, imageViewSize, imageViewSize);
        
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        imageView;
    });
    [self addSubview:iconImageView];
    self.iconImageView = iconImageView;
    
    UILabel *nameLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, MaxY(iconImageView), GetWidth(self), 20);
        
        [label setFont:SYSTEMFONT(16)];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
}

@end
