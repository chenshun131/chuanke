//
//  AppDelegate.m
//  chuanke
//
//  Created by chenshun131 on 16/9/7.
//  Copyright © 2016年 chenshun131. All rights reserved.
//

#import "AppDelegate.h"
#import "JZCourseViewController.h"
#import "MineViewController.h"
#import "iflyMSC/iFlyMSC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // 1.
    JZCourseViewController *vc1 = [[JZCourseViewController alloc] init];
    vc1.title = @"课程推荐";
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    MineViewController *vc2  = [[MineViewController alloc] init];
    vc2.title = @"我的传课";
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    UIViewController *vc3 = [[UIViewController alloc] init];
    vc3.title = @"离线下载";
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    
    // 2.
    NSArray *viewCtrs = @[nav1, nav2, nav3];
    
    // 3.
    self.rootTabbarCtr = [[UITabBarController alloc] init];
    [self.rootTabbarCtr setViewControllers:viewCtrs animated:YES];
    
    // 4.
    self.window.rootViewController = self.rootTabbarCtr;
    
    // 5.
    UITabBar *tabbar = self.rootTabbarCtr.tabBar;
    UITabBarItem *item0 = [tabbar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabbar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabbar.items objectAtIndex:2];
    
    item0.image = [[UIImage imageNamed:@"bottom_tab1_unpre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item0.selectedImage = [[UIImage imageNamed:@"bottom_tab1_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.image = [[UIImage imageNamed:@"bottom_tab2_unpre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.selectedImage = [[UIImage imageNamed:@"bottom_tab2_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.image = [[UIImage imageNamed:@"bottom_tab3_unpre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.selectedImage = [[UIImage imageNamed:@"bottom_tab3_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 改变 UITabBarItem 字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:navigationBarColor, UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 科大讯飞语音初始化
        // 创建语音配置,appid必须要传入，仅执行一次则可
        NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"57d178ea"];
        // 所有服务启动前，需要确保执行createUtility
        [IFlySpeechUtility createUtility:initString];
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
