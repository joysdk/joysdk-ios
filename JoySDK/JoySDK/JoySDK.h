//
//  JoySDK.h
//  JoySDK
//
//  Created by apple on 2022/9/30.
//

#import <Foundation/Foundation.h>

//! Project version number for JoySDK.
FOUNDATION_EXPORT double JoySDKVersionNumber;

//! Project version string for JoySDK.
FOUNDATION_EXPORT const unsigned char JoySDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JoySDK/PublicHeader.h>

//把公开的头文件要引用一下，"Missing submodule '********'"的警告就会消失了
#import <JoySDK/JoyGame.h>
