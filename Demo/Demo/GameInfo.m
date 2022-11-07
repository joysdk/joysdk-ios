//
//  GameInfo.m
//  Demo
//
//  Created by apple on 2022/10/14.
//

#import "GameInfo.h"

@implementation GameInfo

+(instancetype)shared{
    static GameInfo *gameInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gameInfo = [[self alloc]init];
    });
    return gameInfo;
}

@end
