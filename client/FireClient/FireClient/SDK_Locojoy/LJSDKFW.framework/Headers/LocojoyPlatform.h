//
//  LocojoyPlatform.h
//
//
//  Created by waleneqi on 10/19/15.
//  Copyright © 2015 leneqi. All rights reserved.
//
//version:4.1.1
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>


@protocol LocojoyPlatformInitDelegate <NSObject>
/**
 *  初始化回调接口
 *
 *  @param initState 1 代表初始化成功
 */
-(void)locojoyInitCallBack:(NSInteger) initState result:(NSDictionary *)data;

@end

@protocol LocojoyPlatformLoginDelegate <NSObject>
/**
 *  登陆回调接口
 *
 *  @param loginState  3 代表成功
 *  @param data       返回的数据
 */
-(void)locojoyLoginCallBack:(NSInteger) loginState result:(NSDictionary *)data;
@end

@protocol LocojoyPlatformPayDelegate <NSObject>
/**
 *  支付回调接口
 *
 *  @param payState 100 代表成功
 *  @param data     返回数据
 */
-(void)locojoyPayCallBack:(NSInteger) payState result:(NSDictionary *)data;

@end

@protocol LocojoyPlatformCutDelegate <NSObject>
/**
 *  切换账号接口
 *
 *  @param cutState 1 代表成功
 *  @param data     返回的数据
 */
-(void)locojoyCutCallBack:(NSInteger)cutState result:(NSDictionary *)data;
@end

typedef NS_ENUM(NSInteger, LOCATION){
    V1,V2,V3,V4,
    H1,H2,H3,H4,
};

@interface LocojoyPlatform : NSObject

+(LocojoyPlatform *)sharedUserData;
/**
 *  初始化接口
 */
- (void)locojoyInit;
/**
 *  登陆接口
 isAutoLogin 是否自动登录 YES-自动登录 NO-非自动登录
 */
- (void)locojoyLogin:(BOOL)isAutoLogin;
/**
 *  GameCenter登陆接口
*/
- (void)locojoyLoginForGameCenter;
/**
 *  支付接口
 *
 *  @param viewController viewcontroller
 *  @param productId      商品id
 *  @param extraData      额外携带参数(订单)
 */
- (void)locojoyPayWithView:(UIViewController *)viewController productId:(NSString *)productId extraData:(NSString *)extraData;
/**
 *  自定义浮标的位置
 *
 *  @param location 可以参考接入文档
 */
- (void)locojoyShowToolBar:(LOCATION)location;
/**
 *  支付宝回调
 *
 *  @param url url
 */
-(void)alpayOpenURL:(NSURL *)url;

/**
 *  设置用户反馈页面的一些用户信息
 
 gameUserInfo： 游戏内用户的信息（键值都为NSString类型）
 必须包含的键：
 pid:游戏id（产品人员从平台部获取）
 gid:游戏大区id
 gsid:游戏服务器id
 rid:游戏角色id
 rname:角色昵称(utf8编码)
 
 
 返回值：YES:成功 NO:失败
 */
-(BOOL)setSDKGameUserInfo:(NSDictionary*)gameUserInfo;


@property(nonatomic) NSDictionary*gameUserInfo;
@property(nonatomic,assign) BOOL isAutoLogin;//是否自动登录

@property (nonatomic,assign) id<LocojoyPlatformInitDelegate> locojoyInitDelegate;
@property (nonatomic,assign) id<LocojoyPlatformLoginDelegate> locojoyLoginDelegate;
@property (nonatomic,assign) id<LocojoyPlatformPayDelegate> locojoyPayDelegate;
@property (nonatomic,weak) id<LocojoyPlatformCutDelegate> locojoyCutDelegate;






@end
