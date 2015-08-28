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
#import <AVOSCloud/AVOSCloud.h>
#import "UICommon.h"
#import "ICMainViewController.h"

@interface AppDelegate ()
{
    NSString * _workGroupId;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

     
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    
    
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
    
    // Override point for customization after application launch.
    
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
    
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSString *workGroupId = [numberFormatter stringFromNumber:[notificationPayload objectForKey:@"workGroupId"]];
    
    if(workGroupId.length)
    {
        [self jumpToMainView:workGroupId];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    _workGroupId = [numberFormatter stringFromNumber:[userInfo objectForKey:@"workGroupId"]];
    if(_workGroupId.length)
    {
        if ([[userInfo objectForKey:@"inviteToGroup"] isEqualToString:@"inviteToGroup"]) {
            
            NSString * alertStr = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            //判断应用程序当前的运行状态，如果是激活状态，则进行提醒，否则不提醒
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
                if(_workGroupId.length)
                {
                    [self jumpToMainView:_workGroupId];
                }
            }
        }
        
    }
}

- (void) jumpToMainView:(NSString *)workGroupId
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMainViewController"];
    ((ICMainViewController*)vc).pubGroupId = workGroupId;
    
    UINavigationController * nav = (UINavigationController *)self.window.rootViewController;
    [nav pushViewController:vc animated:YES];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self jumpToMainView:_workGroupId];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    int num=application.applicationIconBadgeNumber;
    if(num!=0){
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveEventually];
        application.applicationIconBadgeNumber=0;
    }
    [application cancelAllLocalNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册失败，无法获取设备 ID, 具体错误: %@", error);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
