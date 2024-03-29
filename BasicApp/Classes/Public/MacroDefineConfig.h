//
//  MacroDefineConfig.h
//  KSMovie
//
//  Created by young He on 2018/9/11.
//  Copyright © 2018年 youngHe. All rights reserved.
//

#ifndef MacroDefineConfig_h
#define MacroDefineConfig_h

#define ScreenWidth           [[UIScreen mainScreen]bounds].size.width
#define ScreenHeight          [[UIScreen mainScreen]bounds].size.height

//正则表达
/** 手机正则 */
#define RegextestMobile       @"^1([3|5|7|8|])[0-9]{9}$"
/** 密码正则 */
#define RegextestPassword     @"^[@A-Za-z0-9!#$%^&*.~_(){},?:;]{6,20}$"
/** 验证码 */
#define kRegexVerCode         @"^[0-9]{6}$"
/** 邮箱 */
#define RegexestEmail         @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}"

#import "AppDelegate.h"
#define g_App               ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define SelectVC          (KSBaseNavViewController*)g_App.tabBarVC.selectedViewController
#define NSValueToString(a)  [NSString stringWithFormat:@"%@",a]

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
#define iOS10Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
#define iOS11Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)

#define ContentOffsetInTop   [UIApplication sharedApplication].statusBarFrame.size.height == 44?88.f:64.f

//------ appKey ------//

#define MainWindow [UIApplication sharedApplication].keyWindow
#define KFONT(size) [UIFont systemFontOfSize:size]
#define kBLOD_FONT(size) [UIFont boldSystemFontOfSize:size]
#define KCOLOR(str) [Tool colorConvertFromString:str]
#define KURLSTR(str1,str2) [NSString stringWithFormat:@"%@%@",str1,str2]
#define Image_Named(str)      [UIImage imageNamed:str]
#define K_IMG(str)      [UIImage imageNamed:str]

#define KWIDTH(width) [Helper returnUpWidth:width]
#define KHEIGHT(height) [Helper returnUpWidth:height]

//用户管理类
#define IS_LOGIN [[UserManager shareManager] isLogin]
#define USER_MANAGER [UserManager shareManager]

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:alphaValue]
#define UIColorRGB(x,y,z) [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:1.0]

// 适配
#define DevicesScale ([UIScreen mainScreen].bounds.size.height==480?1.00:[UIScreen mainScreen].bounds.size.height==568?1.00:[UIScreen mainScreen].bounds.size.height==667?1.17:1.29)


//#define weakify(...) \
//ext_keywordify \
//metamacro_foreach_cxt(ext_weakify_,, __weak, __VA_ARGS__)
//
//#define strongify(...) \
//ext_keywordify \
//_Pragma("clang diagnostic push") \
//_Pragma("clang diagnostic ignored \"-Wshadow\"") \
//metamacro_foreach(ext_strongify_,, __VA_ARGS__) \
//_Pragma("clang diagnostic pop")


/** 人物头像默认图 */
#define img_placeHolderIcon [UIImage imageNamed:@"img_placeHolderIcon"]

/** 图片占位图  */
#define img_placeHolder [UIImage imageNamed:@"img_placeHolder"]


//视频详情页顶部高度
#define VDTopViewH (ScreenWidth*422/750)
//视频详情页Tab高度
#define VDTabHeight self.sizeH(30)

//设备型号
#define MOBILE_TYPE  [[[UIDevice currentDevice] identifierForVendor] UUIDString]

//-----------UtilsMacro--------\\

// 打印
#ifdef DEBUG
# define SSLog(fmt, ...) NSLog((@"📍[函数名:%s]" "🎈[行号:%d]" fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
# define SSLog(...)
#endif

#define WSOther(weakSelf)  __weak __typeof(&*self)weakSelf = self;

/**  常用设备型号 */
/** iPad */
#define IS_IPad               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
/** iPhone */
#define IS_IPhone             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
/** iPhone4 */
#define IS_IPhone4            ([[UIScreen mainScreen] bounds].size.height == 480)
/** iPhone5 */
#define IS_IPhone5            ([[UIScreen mainScreen] bounds].size.height == 568)
/** iPhone6 */
#define IS_IPhone6            ([[UIScreen mainScreen] bounds].size.width == 375)
/** iPhonePlus */
#define IS_IPhonePlus         ([[UIScreen mainScreen] bounds].size.width == 414)
/** iPhoneX Xs */
#define IS_IPhoneXorXs        ([[UIScreen mainScreen] bounds].size.width == 375 && [[UIScreen mainScreen] bounds].size.height == 812)
/** iPhoneXs Max */
#define Is_IPhoneXSMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)


/** 获取设备ID */
#define DEVICE_ID             [[UIDevice currentDevice].identifierForVendor UUIDString]
/** 获取类名 */
#define ClassString NSStringFromClass([self class])

/** 获取系统版本 */
#define SYSTEM_VERSION        [UIDevice currentDevice].systemVersion.floatValue
/** 判断当前iOS系统是否高于iOS7 */
#define IS_IOS7               (SYSTEM_VERSION >= 7.0)
#define IS_IOS8               (SYSTEM_VERSION >= 8.0)

/** 通知中心 */
#define NOTIFICATION          [NSNotificationCenter defaultCenter]
/** NsUserDefault替换 */
#define USERDEFAULTS          [NSUserDefaults standardUserDefaults]
/** 应用程序 */
#define APPLICATION           [UIApplication sharedApplication]
/** URL */
#define URL(url)              [NSURL URLWithString:url]
#define SSStr(a,b)               [NSString stringWithFormat:@"%@%@",a,b]
/** NSInteger 转 NSString */
#define String_Integer(x)     [NSString stringWithFormat:@"%ld",(long)x]

/** 常用颜色 */
#define Orange_ThemeColor           KCOLOR(@"#FF5C3E")  //主橙色
#define ThemeColor           KCOLOR(@"#ffcc00")  //主题颜色
#define Black_Color           [UIColor blackColor]
#define Blue_Color            [UIColor blueColor]
#define Brown_Color           [UIColor brownColor]
#define Clear_Color           [UIColor clearColor]
#define DarkGray_Color        [UIColor darkGrayColor]
#define DarkText_Color        [UIColor darkTextColor]
#define White_Color           [UIColor whiteColor]
#define Yellow_Color          [UIColor yellowColor]
#define Red_Color             [UIColor redColor]
#define Orange_Color          [UIColor orangeColor]
#define Purple_Color          [UIColor purpleColor]
#define LightText_Color       [UIColor lightTextColor]
#define LightGray_Color       [UIColor lightGrayColor]
#define Green_Color           [UIColor greenColor]
#define Gray_Color            [UIColor grayColor]
#define Magenta_Color         [UIColor magentaColor]

/** 动态设定字体大小 */
#define Get_Size(x)           IS_IPhonePlus ? ((x) + 1) : IS_IPhone6 ? (x) : (x) - 1

#define Font_Size(x)          [UIFont systemFontOfSize:Get_Size(x)]
#define Font_Bold(y)          [UIFont boldSystemFontOfSize:Get_Size(y)]
#define Font_Slim(y)          [UIFont fontWithName:@"STHeitiTC-Light" size:Get_Size(y)]
#define Font_Name(x,y)        [UIFont fontWithName:(x) size:(y)];

/** 字号设置字号：36pt 30pt 24pt */
#define TitleFont             [UIFont systemFontOfSize:Get_Size(18.0f)]
#define NormalFont            [UIFont systemFontOfSize:Get_Size(15.0f)]
#define ContentFont           [UIFont systemFontOfSize:Get_Size(12.0f)]
#define WS() typeof(self) __weak weakSelf = self;
#define SS() typeof(weakSelf) __strong strongSelf = weakSelf;

#define MWeakSelf(type)  __weak typeof(type) weak##type = type;
#define MStrongSelf(type)  __strong typeof(type) type = weak##type;

// 过期提醒
#define HZAddititonsDeprecated(instead) NS_DEPRECATED(1_0, 1_0, 2_0, 2_0, instead)

// -------------------------------- 用户 ---------------------------------\\
/** 用户id */
#define NowUserID                    @"userid"
/** 用户token */
#define UserToken                    @"token"
/** 用户头像 */
#define UserHeaderImg                @"headerImg"
/** 用户名 */
#define UserNickName                 @"userNickName"
/* 实名认证 */
#define RealName                    @"bcertid"

//键盘弹起来通知
#define KEYBOARD_SHOW @"keyboard_show"

//token过期
#define OverDateToken @"outDate_token"

//数据处理码
#define ErrorCode @"errCode"
#define ErrorMsg  @"errMsg"
#define Succeed   @"succeed"

#define FIRST_IN_KEY            @"FIRST_IN_KEY"

#define Tmp_VideoUrl @"[NSURL URLWithString:@"http://flv3.bn.netease.com/tvmrepo/2018/6/H/9/EDJTRBEH9/SD/EDJTRBEH9-mobile.mp4"]"

#define kVideoCover @"https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"

#define PageCount_Normal 10
#define PageCount_Recom 3
#define PageCount_VideoLib 15

//表名  缓存表 存 LJDownloadModel
#define CACHE_Table @"HistoryCACHE_Table"

//------ appKey ------//

//#define WXAppID    @""
//#define WXAppSecret   @""

#define UMengAppKey    @""


#endif /* MacroDefineConfig_h */
