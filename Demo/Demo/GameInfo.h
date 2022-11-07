//
//  GameInfo.h
//  Demo
//
//  Created by apple on 2022/10/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameInfo : NSObject
+(instancetype)shared;
@property (nonatomic, strong) NSArray *gameList;
@end

NS_ASSUME_NONNULL_END
