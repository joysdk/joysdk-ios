//
//  ASGameCollectionViewCell.h
//  anchorlive
//
//  Created by apple on 2022/10/27.
//

#import <UIKit/UIKit.h>
#import <JoySDK/JoySDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASGameCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) JoyGameInfoModel *joyGameInfoModel;

@end

NS_ASSUME_NONNULL_END
