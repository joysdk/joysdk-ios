//
//  Header.h
//  live
//
//  Created by apple on 2021/3/11.
//

#ifndef Header_h
#define Header_h

//#import <SDWebImage/SDWebImage.h>
//#import <UMCommon/MobClick.h>
//#import "LCPublicKit.h"
//#import "LCPublicMethod.h"

#define appid    @"1584099968"
#define appStore @"https://apps.apple.com/us/app/id1584099968"

#define K_Theme_Color               0xC63AE0
#define K_Theme_Color2               0x23B4E0
#define Terms         @"http://www.jiaoyibei.com/tl-use.html"
#define PrivacyPolicy @"http://www.jiaoyibei.com/tl.html"
#define appName       @"Laya"
#define ReportWebAddress       @"https://kkyun.com/html/feedback_en.html"

//状态栏和导航栏的总高度
#define K_StatusNav_Height (SafeAreaTop + K_Nav_Height)
//顶部安全距离
#define SafeAreaTop [[UIApplication sharedApplication] keyWindow].safeAreaInsets.top
//导航栏高度
#define K_Nav_Height 44
/** 底部安全区域 **/
#define SafeAreaBottom [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom

//获取屏幕宽高
#define K_Width       [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define K_Height self.view.frame.size.height
#define StudioPadding 14
#define StudioBgColor [LCPublicKit colorWithHexadecimal:0x000000 alpha:0.27]
#define StudioRadius 15

//拼接字符串
#define Format(format, ...) [NSString stringWithFormat:format, ##__VA_ARGS__]

/// 是否为空对象
#define kObjectIsNil(__object) ((nil == __object) || [__object isKindOfClass:NSNull.class])
#define kObjectIsNotNil(__object) (!kObjectIsNil(__object))
/// 字符串为空
#define kStringIsEmpty(__string) (kObjectIsNil(__string) || (__string.length == 0))
/// 字符串不为空
#define kStringIsNotEmpty(__string) (!kStringIsEmpty(__string))

//颜色
#define KClearColor  [UIColor clearColor]
#define KWhiteColor  [UIColor whiteColor]
#define KBlackColor  [UIColor blackColor]
#define KGrayColor   [UIColor grayColor]
#define KGray2Color  [UIColor lightGrayColor]
#define KBlueColor   [UIColor blueColor]
#define KRedColor    [UIColor redColor]
#define KGreenColor  [UIColor greenColor]
#define kRandomColor KRGBColor(arc4random_uniform(256) / 255.0, arc4random_uniform(256) / 255.0, arc4random_uniform(256) / 255.0) //随机色生成

//字体
#define BOLDSYSTEMFONT(FONTSIZE) [UIFont boldSystemFontOfSize:FONTSIZE]
#define SYSTEMFONT(FONTSIZE)     [UIFont systemFontOfSize:FONTSIZE]
#define FONT(NAME, FONTSIZE)     [UIFont fontWithName:(NAME) size:(FONTSIZE)]

//定义UIImage对象
#define IMAGE_NAMED(name) [UIImage imageNamed:name]

// View 圆角
#define radius(View)                                    \
                                                        \
    [View.layer setCornerRadius:(GetHeight(View) / 2)]; \
    [View.layer setMasksToBounds:YES]

#define radiusCorner(View, corner)         \
                                           \
    [View.layer setCornerRadius:(corner)]; \
    [View.layer setMasksToBounds:YES]

#define RGBCOLOR(r, g, b)           [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1]
#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define titleBGColor                RGBCOLOR(77, 191, 167)

// 颜色
#define GKColorRGBA(r, g, b, a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]
#define GKColorRGB(r, g, b)     GKColorRGBA(r, g, b, 1.0)
#define GKColorGray(v)          GKColorRGB(v, v, v)

#define MaxY(v)                    CGRectGetMaxY((v).frame)
#define MinY(v)                    CGRectGetMinY((v).frame)
#define MaxX(v)                    CGRectGetMaxX((v).frame)
#define MinX(v)                    CGRectGetMinX((v).frame)
#define GetHeight(v)               CGRectGetHeight((v).frame)
#define GetWidth(v)                CGRectGetWidth((v).frame)
#define Middle(SuperSize, SubSize) (SuperSize - SubSize) / 2

#define max(a, b) (((a) > (b)) ? (a) : (b))

// 适配比例
#define ADAPTATIONRATIO K_Width / 750.0f
// 顶部安全区域高度
#define GK_SAFEAREA_TOP [GKNavigationBarConfigure safeAreaInsets].top

//屏幕底部 tabBar高度49pt + 安全视图高度34pt(iPhone X)
#define KTabBarHeight self.tabBarController.tabBar.bounds.size.height
#define kLocal(key)     NSLocalizedString(key, nil)

static const NSInteger colorValue[] = {
    0x877b88, 0xfae5ff, 0xffedcf, 0xc8dfff, 0x888c83, 0x6e7a87, 0x8c5c94, 0xffdede, 0x976557, 0xfff9ca, 0xd1d0ff};

//debug模式下才NSlog
#ifdef __OBJC__
#ifdef DEBUG
//#define NSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define NSLog(fmt, ...) NSLog((@"\n >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n " fmt), ##__VA_ARGS__)
#else
#define NSLog(...)
#endif
#endif

// 来自YYKit
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) \
    autoreleasepool {}  \
    __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) \
    autoreleasepool {}  \
    __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) \
    try {               \
    } @finally {}       \
    {}                  \
    __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) \
    try {               \
    } @finally {}       \
    {}                  \
    __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) \
    autoreleasepool {}    \
    __typeof__(object) object = weak##_##object;
#else
#define strongify(object) \
    autoreleasepool {}    \
    __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) \
    try {                 \
    } @finally {}         \
    __typeof__(object) object = weak##_##object;
#else
#define strongify(object) \
    try {                 \
    } @finally {}         \
    __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define Test 1
#endif /* Header_h */
