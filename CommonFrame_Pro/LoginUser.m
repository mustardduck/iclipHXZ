//
//  LoginUser.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/13.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "LoginUser.h"
#import "HttpBaseFile.h"
#import "CommonFile.h"
//#import <SBJson4Parser.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SVProgressHUD.h"

#define CURL                @"/user/loginUser.hz"
#define QUIT_URL            @"/user/outLogin.hz"
#define REG_URL             @"/user/receiveCode.hz"
#define REGISTER_USER_URL   @"/user/registerUser.hz"
#define PWD_URL             @"/user/updateUserPwd.hz"
#define FIND_PWD_URL        @"/user/sendSmsByPwd.hz"
#define SEND_SMS_URL        @"/user/sendSms.hz"
#define UPDATE_URL          @"/user/updateUserDetail.hz"
#define UPLOAD_IMAGE_URL    @"/file/upload.hz"
#define UPDATE_PWD_URL    @"/user/updatePwdBySms.hz"


@implementation LoginUser

- (BOOL)hasLogin
{
    BOOL hasLogined = NO;
    
    if (self.loginName != nil && self.password != nil) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:self.loginName forKey:@"loginName"];
        [dic setObject:[CommonFile md5:self.password]forKey:@"passWord"];
        [dic setObject:[NSString stringWithFormat:@"%ld",self.type] forKey:@"loginType"];
        [dic setObject:[NSString stringWithFormat:@"%ld",self.source] forKey:@"loginSource"];
        [dic setObject:[NSString stringWithFormat:@"%ld",self.productId] forKey:@"productId"];
        [dic setObject:self.version forKey:@"productVersion"];
        [dic setObject:self.systemVersion forKey:@"systemVersion"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:CURL postData:dic];
        
        if (responseString == nil) {
            return hasLogined;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic1 = (NSDictionary*)val;
            
            if (dic1 != nil) {
                if ([[dic1 valueForKey:@"state"] intValue] == 1) {
                    hasLogined = YES;
                    [CommonFile saveInfoWithKey:[dic1 valueForKey:@"data"] withKey:@"loginInfo"];
                    NSLog(@"Dic:%@",dic1);
                }
            }
            
        }
    }
    
    return hasLogined;
}

+ (LoginUser*)getLoginInfo
{
    LoginUser* user = [LoginUser new];
    
    id val = [CommonFile getInfoWithKey:@"loginInfo"];
    
    if (val != nil) {
        
         NSDictionary* dic = (NSDictionary*)val;
         user.createTime = [dic valueForKey:@"createTime"];
         user.email = [dic valueForKey:@"email"];
         user.img = [dic valueForKey:@"img"];
         user.level = [[dic valueForKey:@"level"] integerValue];
         user.loginName = [dic valueForKey:@"loginName"];
         user.mobile = [dic valueForKey:@"mobile"];
         user.name = [dic valueForKey:@"name"];
         user.password = [dic valueForKey:@"password"];
         user.productId = [[dic valueForKey:@"productId"] integerValue];
         user.score = [[dic valueForKey:@"score"] integerValue];
         user.source = [[dic valueForKey:@"source"] integerValue];
         user.status = [[dic valueForKey:@"status"] integerValue];
         user.token = [dic valueForKey:@"token"];
         user.type = [[dic valueForKey:@"type"] integerValue];
         user.userId = [dic valueForKey:@"userId"];
        
        NSString * orgID = [dic valueForKey:@"orgId"];
        
        user.orgId = orgID ? orgID : @"1015050511520001";

    }
    
    return user;
}

+ (NSDictionary*)getLoginInfoWithNSDictionary
{
    id val = [CommonFile getInfoWithKey:@"loginInfo"];
    if (val != nil)
        return (NSDictionary*)val;
    return nil;
}

+ (NSString*)loginUserID
{
    return [self getLoginInfo].userId;
}

+ (NSString*)loginUserOrgID
{
    return [self getLoginInfo].orgId;
}

+ (NSString*)loginUserName
{
    return [self getLoginInfo].name;
}

+ (NSString*)loginUserPwd
{
    return [self getLoginInfo].password;
}

+ (NSString*)loginUserPhoto
{
     return [self getLoginInfo].img;
}

+ (BOOL)quit
{
    BOOL re = NO;
    
    NSString* userid = [LoginUser loginUserID];
    
    if (userid != nil) {
        NSData* responseString = [HttpBaseFile requestDataWithSync:[NSString stringWithFormat:@"%@?userId=%@",QUIT_URL,userid]];
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    [CommonFile removeInfoWithKey:@"loginInfo"];
                }
            }
            
        }

    }
    
    return re;
}


+ (BOOL)updatePwd:(NSString*)mobile code:(NSString*)code password:(NSString*)pwd
{
    BOOL re = NO;
    
    if (mobile && code && pwd)
    {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:[CommonFile md5:pwd]forKey:@"newPwd"];
        [dic setObject:mobile forKey:@"mobile"];
        [dic setObject:code forKey:@"code"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_PWD_URL postData:dic];
        
        if (responseString == nil) {
            return re;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    [CommonFile saveInfoWithKey:[dic valueForKey:@"data"] withKey:@"loginInfo"];
                    NSLog(@"Dic:%@",dic);
                }
            }
            
        }
    }
    
    return  re;
    
}

+ (BOOL)registeUser:(NSString *)name mobile:(NSString*)mobile code:(NSString*)code password:(NSString*)pwd
{
    BOOL re = NO;
    
    if (name && mobile && code && pwd)
    {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:[CommonFile md5:pwd]forKey:@"pwd"];
        [dic setObject:name forKey:@"name"];
        [dic setObject:mobile forKey:@"mobile"];
        [dic setObject:code forKey:@"code"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:REGISTER_USER_URL postData:dic];
        
        if (responseString == nil) {
            return re;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    [CommonFile saveInfoWithKey:[dic valueForKey:@"data"] withKey:@"loginInfo"];
                    NSLog(@"Dic:%@",dic);
                }
            }
            
        }
    }
    
    return  re;
    
}

+ (BOOL)registeNewUser:(NSInteger)source sourceVale:(NSString*)sourceStr inviteCode:(NSString*)code password:(NSString*)pwd
{
    BOOL re = NO;
    
    if (code != nil && sourceStr != nil && pwd != nil) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:[CommonFile md5:pwd]forKey:@"pwd"];
        [dic setObject:[NSString stringWithFormat:@"%ld",source] forKey:@"source"];
        [dic setObject:sourceStr forKey:@"sourceStr"];
        [dic setObject:code forKey:@"code"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:REG_URL postData:dic];
        
        if (responseString == nil) {
            return re;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    [CommonFile saveInfoWithKey:[dic valueForKey:@"data"] withKey:@"loginInfo"];
                    NSLog(@"Dic:%@",dic);
                }
            }
            
        }
    }
    
    return  re;
}


+ (BOOL)changePwd:(NSString*)oldPwd newPassword:(NSString*)newPwd
{
    BOOL re = NO;
    
    if (oldPwd != nil && newPwd != nil ) {
         NSString* userid = [LoginUser loginUserID];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:[CommonFile md5:oldPwd]forKey:@"oldPwd"];
        [dic setObject:[CommonFile md5:newPwd]forKey:@"newPwd"];
        [dic setObject:userid forKey:@"userId"];
       
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:PWD_URL postData:dic];
        
        if (responseString == nil) {
            return re;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    NSLog(@"Dic:%@",dic);
                }
            }
            
        }
    }
    
    return re;
}

+ (BOOL)sendSMS:(NSInteger)source mobile:(NSString*)mobile status:(NSString **)status
{
    BOOL re = NO;
    
    if (mobile != nil ) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:mobile forKey:@"mobile"];
        [dic setObject:[NSString stringWithFormat:@"%ld",source] forKey:@"source"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:SEND_SMS_URL postData:dic];
        
        if (responseString == nil) {
            return re;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    NSLog(@"Dic:%@",dic);
                }
                else if ([[dic valueForKey:@"state"] intValue] == -2)
                {
                    *status = @"-2";
                }
            }
            
        }
    }
    
    return re;
}

+ (BOOL)findPassword:(NSInteger)source sourceValue:(NSString*)sourceStr
{
    BOOL re = NO;
    
    if (sourceStr != nil ) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        
        [dic setObject:sourceStr forKey:@"sourceStr"];
        [dic setObject:[NSString stringWithFormat:@"%ld",source] forKey:@"source"];
        
        NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:FIND_PWD_URL postData:dic];
        
        if (responseString == nil) {
            return re;
        }
        
        id val = [CommonFile jsonNSDATA:responseString];
        
        if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)val;
            
            if (dic != nil) {
                if ([[dic valueForKey:@"state"] intValue] == 1) {
                    re = YES;
                    NSLog(@"Dic:%@",dic);
                }
            }
            
        }
    }
    
    return re;
}

+ (BOOL) uploadImageWithScale:(UIImage *)imgH fileName:(NSString *)filename imageDic:(NSMutableDictionary **)imageDic
{
    BOOL isOk = NO;
    
    NSData* data = UIImageJPEGRepresentation(imgH, 1.0f);
    
    NSString* filePath = [CommonFile saveImageToDocument:data fileName:filename];
    
    NSData* responseString = [HttpBaseFile requestImageWithSyncByPost:UPLOAD_IMAGE_URL withFilePath:filePath];
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
                NSLog(@"Dic:%@",dic);
                
                *imageDic = [dic objectForKey:@"data"];
                
            }
        }
    }
    
    return isOk;
}

+ (BOOL) uploadImageWithScale:(UIImage *)imgH fileName:(NSString *)filename userImgPath:(NSString **)userImgPath
{
    BOOL isOk = NO;
    
    NSData* data = UIImageJPEGRepresentation(imgH, 1.0f);
    
    NSString* filePath = [CommonFile saveImageToDocument:data fileName:filename];
    
    NSData* responseString = [HttpBaseFile requestImageWithSyncByPost:UPLOAD_IMAGE_URL withFilePath:filePath];
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    NSString * strImg = @"";
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
                NSLog(@"Dic:%@",dic);
                
                NSDictionary * sdic = [dic objectForKey:@"data"];
                
                strImg = [sdic valueForKey:@"path"];
            }
        }
        
    }
    
    *userImgPath = strImg;
    
    return isOk;
}

+ (BOOL)uploadImage:(NSArray *)objs withUserImgPath:(NSString **)userImgPath
{
    BOOL isOk = NO;
    
    ALAsset* asset = (ALAsset*)objs[0];
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
    NSString* filename = [representation filename];
    
    imgH = [UIImage
            imageWithCGImage:[representation fullScreenImage]
            scale:[representation scale]
            orientation:UIImageOrientationUp];
    
    NSData* data = UIImageJPEGRepresentation(imgH, 1.0f);
    
    NSString* filePath = [CommonFile saveImageToDocument:data fileName:filename];
    
    NSData* responseString = [HttpBaseFile requestImageWithSyncByPost:UPLOAD_IMAGE_URL withFilePath:filePath];
    
    if (responseString == nil) {
        return isOk;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    NSString * strImg = @"";
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                isOk = YES;
                NSLog(@"Dic:%@",dic);
                
                NSDictionary * sdic = [dic objectForKey:@"data"];
                
                strImg = [sdic valueForKey:@"path"];
            }
        }
        
    }
    
    *userImgPath = strImg;
    
    return isOk;
}

+ (BOOL)updateInfo:(NSString*)name phone:(NSString*)phone email:(NSString*)mail photo:(NSString*)photo
{
    BOOL re = NO;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:name forKey:@"name"];
    [dic setObject:phone forKey:@"mobile"];
    [dic setObject:mail forKey:@"email"];
    [dic setObject:[LoginUser loginUserID] forKey:@"userId"];
    [dic setObject:photo forKey:@"img"];
    
    NSData* responseString = [HttpBaseFile requestDataWithSyncByPost:UPDATE_URL postData:dic];
    
    if (responseString == nil) {
        return re;
    }
    
    id val = [CommonFile jsonNSDATA:responseString];
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)val;
        
        if (dic != nil) {
            if ([[dic valueForKey:@"state"] intValue] == 1) {
                re = YES;
                NSLog(@"Dic:%@",dic);
                
                NSDictionary* cDic = [LoginUser getLoginInfoWithNSDictionary];
                
                if (cDic != nil) {
                    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionaryWithDictionary:cDic];
                    
                    [tmpDic setObject:name forKey:@"name"];
                    [tmpDic setObject:phone forKey:@"mobile"];
                    [tmpDic setObject:mail forKey:@"email"];
                    [tmpDic setObject:photo forKey:@"img"];
                    
                    [CommonFile saveInfoWithKey:tmpDic withKey:@"loginInfo"];
                }
                
            }
        }
        
    }
    
    
    return re;
}

+ (BOOL)isKeepLogined
{
    id val = [CommonFile getInfoWithKey:@"loginInfo"];
    if (val != nil) {
        return YES;
    }
    return NO;
}

@end
