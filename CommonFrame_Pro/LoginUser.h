//
//  LoginUser.h
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/13.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LoginUser : NSObject

@property (nonatomic,strong) NSString*       userId;
@property (nonatomic,strong) NSString*       loginName;
@property (nonatomic,strong) NSString*       password;
@property (nonatomic,strong) NSString*       name;
@property (nonatomic,strong) NSString*       email;
@property (nonatomic,strong) NSString*       token;
@property (nonatomic,strong) NSString*       mobile;
@property (nonatomic,assign) NSInteger       type;
@property (nonatomic,assign) NSInteger       productId;
@property (nonatomic,strong) NSString*       version;
@property (nonatomic,strong) NSString*       systemVersion;
@property (nonatomic, strong) NSString *        duty;//职位
/*
 -2-- 冻结 -1-- 停用 0-- 未激活/无效 1-- 正常使用 3-- 待审核
 */
@property (nonatomic,assign) NSInteger       status;
@property (nonatomic,assign) NSInteger       score;
@property (nonatomic,assign) NSInteger       level;
@property (nonatomic,strong) NSString*       createTime;
/*
 1: web注册 2: 短信邀请 3: 邮箱邀请 4：qq授权 5：微信授权 6：微博授权
 */
@property (nonatomic,assign) NSInteger       source;
@property (nonatomic,strong) NSString*       img;

@property (nonatomic,strong) NSString*       orgId;//群组id
@property (nonatomic,assign) BOOL isPwdMD5;

- (BOOL)hasLogin:(NSString **)msg;
+ (BOOL)quit;
+ (BOOL)registeNewUser:(NSInteger)source sourceVale:(NSString*)sourceStr inviteCode:(NSString*)code password:(NSString*)pwd;
+ (LoginUser*)getLoginInfo;
+ (NSDictionary*)getLoginInfoWithNSDictionary;
+ (NSString*)loginUserID;
+ (NSString*)loginUserOrgID;
+ (NSString*)loginUserName;
+ (NSString*)loginUserDuty;
+ (NSString*)loginUserPwd;
+ (NSString*)loginUserPhoto;
+ (NSString*)loginUserMobile;
+ (BOOL)changePwd:(NSString*)oldPwd newPassword:(NSString*)newPwd;
+ (BOOL)findPassword:(NSInteger)source sourceValue:(NSString*)sourceStr;

+ (BOOL)updateInfo:(NSString*)name phone:(NSString*)phone email:(NSString*)mail photo:(NSString*)photo;
+ (BOOL)isKeepLogined;

+ (BOOL) uploadImage:(NSArray *)objs withUserImgPath:(NSString **)userImgPath;
+ (BOOL) uploadImageWithScale:(UIImage *)imgH fileName:(NSString *)filename userImgPath:(NSString **)userImgPath;
+ (BOOL) uploadImageWithScale:(UIImage *)imgH fileName:(NSString *)filename imageDic:(NSMutableDictionary **)imageDic;

+ (BOOL)registeUser:(NSString *)name mobile:(NSString*)mobile code:(NSString*)code password:(NSString*)pwd msg:(NSString **)msg;//注册用户
+ (BOOL)sendSMS:(NSInteger)source mobile:(NSString*)mobile status:(NSString **)status msg:(NSString **)msg;//获取验证码

+ (BOOL)updatePwd:(NSString*)mobile code:(NSString*)code password:(NSString*)pwd;//找回密码
@end
