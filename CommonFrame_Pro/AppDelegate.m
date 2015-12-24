//
//  AppDelegate.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/5/22.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "AppDelegate.h"
#import "ICPersonalInfoViewController.h"
#import <SlideNavigationController.h>
//#import <AVOSCloud/AVOSCloud.h>
#import "UICommon.h"
#import "ICMainViewController.h"
#import "ICWorkingDetailViewController.h"
#import "APService.h"
#import "MQMyMessageListController.h"

#define checkCurrentConWith(_model) \
if ([currentViewCon isKindOfClass:[_model class]]) \
{return;}

@interface AppDelegate ()
{
    NSString * _workGroupId;
    NSString * _taskId;
    NSString * _currentTag;
    NSString * _commentsId;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

     
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    
    
    //ICPersonalInfoViewController* leftMenu = (ICPersonalInfoViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"ICPersonalInfoViewController"];
    
    //[SlideNavigationController sharedInstance].leftMenu = leftMenu;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    /*
     UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [button setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
     [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleRightMenu) forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
     [SlideNavigationController sharedInstance].rightBarButtonItem = rightBarButtonItem;
     
     [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
     NSString *menu = note.userInfo[@"menu"];
     NSLog(@"Closed %@", menu);
     }];
     
     [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
     NSString *menu = note.userInfo[@"menu"];
     NSLog(@"Opened %@", menu);
     }];
     
     [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
     NSString *menu = note.userInfo[@"menu"];
     NSLog(@"Revealed %@", menu);
     }];
     
     */
    
    /*
    //leancloud
    [AVOSCloud setApplicationId:@"8XDxjHTxkM2pCCOhgs39qwno"
                      clientKey:@"EchvO498r256FWNfuFlGmkqe"];
    if([UICommon getSystemVersion] < 8.0)
    {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    else
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert
                                                | UIUserNotificationTypeBadge
                                                | UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
     */
    
//    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
    
    // Required
    [APService setupWithOption:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Required
    [APService handleRemoteNotification:userInfo];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);

    int type = [[userInfo valueForKey:@"type"] intValue];
    
    /* todo
    NSString * workGroupId = [userInfo valueForKey:@"workGroupId"];
    if(workGroupId.length && (type == 1 || type == 2 || type == 3 || type == 8))
    {
        UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
        
        UIViewController* currentViewCon = nav.topViewController;
        
        if([currentViewCon isKindOfClass:[ICMainViewController class]])
        {
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            
            [dic setObject:workGroupId forKey:@"workGroupId"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeMainGroupCount"
                                                                object:dic];
        }
    }*/
    
    NSString * sourceId = [userInfo objectForKey:@"sourceId"];
    NSString * mainStr = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];

    // 1 任务  2：异常  3议题  6加入工作组  7：评论 8:申请 9:审核加入org 10:任务超时
    switch (type) {
        case 6:
            _workGroupId = sourceId;
            
            if(_workGroupId.length)
            {
                if (application.applicationState == UIApplicationStateActive) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:mainStr
                                                                   delegate:self
                                                          cancelButtonTitle:@"关闭"
                                                          otherButtonTitles:@"查看", nil];
                    alert.tag = type;
                    [alert show];
                }
                else if (application.applicationState == UIApplicationStateInactive)
                {
                    [self jumpToMainView:_workGroupId];
                }
            }
            break;
        case 9:
            
            if (application.applicationState == UIApplicationStateActive) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:mainStr
                                                               delegate:self
                                                      cancelButtonTitle:@"关闭"
                                                      otherButtonTitles:@"查看", nil];
                alert.tag = type;
                [alert show];
            }
            else if (application.applicationState == UIApplicationStateInactive)
            {
                [self jumpToSystemList];
            }
            
            break;
        default:
            
            _taskId = sourceId;
            
            NSString * commentId = [userInfo objectForKey:@"commentId"];
            
            if(commentId.length > 0)
            {
                _commentsId = commentId;
            }
            else
            {
                _commentsId = @"";
            }
            
            if(_taskId.length)
            {
                if (application.applicationState == UIApplicationStateActive) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:mainStr
                                                                   delegate:self
                                                          cancelButtonTitle:@"关闭"
                                                          otherButtonTitles:@"查看", nil];
                    alert.tag = type;
                    [alert show];
                }
                else if (application.applicationState == UIApplicationStateInactive)
                {
                    [self jumpToMissionDetail:_taskId];
                }
            }

            break;
    }
    
    /*LEAN CLOUD
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    
    if ([[userInfo objectForKey:@"inviteToGroup"] isEqualToString:@"inviteToGroup"]) {
        
        _currentTag = @"inviteToGroup";
        _workGroupId = [numberFormatter stringFromNumber:[userInfo objectForKey:@"workGroupId"]];
        if(_workGroupId.length)
        {
            NSString * alertStr = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];

            if (application.applicationState == UIApplicationStateActive) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:alertStr
                                                               delegate:self
                                                      cancelButtonTitle:@"关闭"
                                                      otherButtonTitles:@"查看", nil];
                [alert show];
            }
            else if (application.applicationState == UIApplicationStateInactive)
            {
                [self jumpToMainView:_workGroupId];
            }
        }

    }
    else if ([[userInfo objectForKey:@"missionNotify"] isEqualToString:@"missionNotify"]) {
        
        _currentTag = @"missionNotify";

        _taskId = [numberFormatter stringFromNumber:[userInfo objectForKey:@"taskId"]];
        if(_taskId.length)
        {
            NSString * alertStr = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            
            if (application.applicationState == UIApplicationStateActive) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:alertStr
                                                               delegate:self
                                                      cancelButtonTitle:@"关闭"
                                                      otherButtonTitles:@"查看", nil];
                [alert show];
            }
            else if (application.applicationState == UIApplicationStateInactive)
            {
                [self jumpToMissionDetail:_taskId];
            }
        }
        
    }
    */
}

- (void) jumpToSystemList
{
    UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
    
    UIViewController* currentViewCon = nav.topViewController;
    
    if([currentViewCon isKindOfClass:[MQMyMessageListController class]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"jumpToSystemList"
                                                            object:nil];
    }
    else
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQMyMessageListController"];
        ((MQMyMessageListController *)vc).sysBtnSelected = YES;
        
        [nav pushViewController:vc animated:YES];
    }

 
}

- (void) jumpToMissionDetail:(NSString *)taskId
{
    UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
    
    UIViewController* currentViewCon = nav.topViewController;

    if([currentViewCon isKindOfClass:[ICWorkingDetailViewController class]])
    {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        
        [dic setObject:taskId forKey:@"taskId"];
        [dic setObject:_commentsId forKey:@"commentId"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"jumpToMissionDetail"
                                                            object:dic];
    }
    else
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
        
        ((ICWorkingDetailViewController*)vc).taskId = taskId;
        ((ICWorkingDetailViewController*)vc).commentsId = _commentsId;
        
        [nav pushViewController:vc animated:YES];
    }
    
    /*
    UINavigationController * nav = (UINavigationController *)self.window.rootViewController;

//    if([UICommon getOldViewController:[ICWorkingDetailViewController class] withNavController:nav])
//    {
//        NSLog(@"got Old View Controller");
//    }
    
    UIViewController* currentViewCon = nav.topViewController;
    
//    checkCurrentConWith(ICWorkingDetailViewController);

    if([currentViewCon isKindOfClass:[ICWorkingDetailViewController class]])
    {
        UIViewController *model =  [UICommon getOldViewController:[ICWorkingDetailViewController class] withNavController:nav];
        if (model && [model isKindOfClass:[UIViewController class]])
        {
            ((ICWorkingDetailViewController*)model).taskId = taskId;
            ((ICWorkingDetailViewController*)model).commentsId = _commentsId;
            
            [nav popToViewController:model animated:YES];
        }
    }
    */
}

- (void) jumpToMainView:(NSString *)workGroupId
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMainViewController"];
    ((ICMainViewController*)vc).pubGroupId = workGroupId;
    
    UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
    [nav pushViewController:vc animated:YES];
    
    /*
    UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
    
    UIViewController* currentViewCon = nav.topViewController;
    
    if([currentViewCon isKindOfClass:[ICMainViewController class]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"jumpToMainView"
                                                            object:workGroupId];
    }
    else
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMainViewController"];
        ((ICMainViewController*)vc).pubGroupId = workGroupId;
        
        UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
        [nav pushViewController:vc animated:YES];
    }*/
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        /*
        if([_currentTag isEqualToString:@"inviteToGroup"])
        {
            [self jumpToMainView:_workGroupId];
        }
        else if ([_currentTag isEqualToString:@"missionNotify"])
        {
            [self jumpToMissionDetail:_taskId];
        }*/
        
        if(alertView.tag == 6)
        {
            [self jumpToMainView:_workGroupId];
        }
        else if (alertView.tag == 9)
        {
            [self jumpToSystemList];
        }
        else
        {
            [self jumpToMissionDetail:_taskId];
        }
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSInteger num=application.applicationIconBadgeNumber;
    if(num!=0)
    {
        [application setApplicationIconBadgeNumber:0];
        [APService setBadge:0];
    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSInteger num=application.applicationIconBadgeNumber;
    if(num!=0)
    {
        [application setApplicationIconBadgeNumber:0];
        [APService setBadge:0];
        [application cancelAllLocalNotifications];
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //进入前台
    
    UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
    
    UIViewController* currentViewCon = nav.topViewController;
    
    if([currentViewCon isKindOfClass:[ICMainViewController class]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMainView"
                                                            object:nil];
    }
    
    /*
    int num=application.applicationIconBadgeNumber;
    if(num!=0){
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveEventually];
        application.applicationIconBadgeNumber=0;
    }
    [application cancelAllLocalNotifications];
     */
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    /*
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
     */
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册失败，无法获取设备 ID, 具体错误: %@", error);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSInteger num=application.applicationIconBadgeNumber;
    if(num!=0)
    {
        [application setApplicationIconBadgeNumber:0];
        [APService setBadge:0];
    }
}

@end
