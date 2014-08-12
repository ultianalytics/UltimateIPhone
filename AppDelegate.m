//
//  AppDelegate.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TeamsViewController.h"
#import "TeamsMasterDetailViewController.h"
#import "TeamViewController.h"
#import "GameViewController.h"
#import "GamesMasterDetailViewController.h"
#import "GamesPlayedController.h"
#import "PreferencesViewController.h"
#import "CloudViewController.h"
#import "TwitterController.h"
#import "ColorMaster.h"
#import "LeaguevineEventQueue.h"
#import "Reachability.h"
#import "BufferedNavigationController.h"

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController* cloudNavController;
@property (nonatomic, strong) UINavigationController* iPhoneTeamNavController;
@property (nonatomic, strong) TeamsMasterDetailViewController* iPadTeamsMasterDetailController;
@property (nonatomic, strong) UINavigationController* gameNavController;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

+ (AppDelegate *)instance {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self setupGlobalAppearance: application];
    
    UIViewController *viewController1, *viewController2, *viewController3, *viewController4;
    
    // Tab 1: team
    if (IS_IPHONE) {
        TeamsViewController* teamController = [[TeamsViewController alloc] initWithNibName:@"TeamsViewController" bundle:nil];
        self.iPhoneTeamNavController = [[BufferedNavigationController alloc] initWithRootViewController:teamController];
        viewController1 = self.iPhoneTeamNavController;
    } else {
        self.iPadTeamsMasterDetailController = [[TeamsMasterDetailViewController alloc] init];
        viewController1 = self.iPadTeamsMasterDetailController;
    }

    // Tab 2: game
    if (IS_IPHONE) {
        GamesPlayedController* gameController = [[GamesPlayedController alloc] init];
        self.gameNavController = [[BufferedNavigationController alloc] initWithRootViewController:gameController];
    } else {
        GamesMasterDetailViewController* gameController = [[GamesMasterDetailViewController alloc] init];
        self.gameNavController = [[BufferedNavigationController alloc] initWithRootViewController:gameController];
        self.gameNavController.navigationBar.hidden = YES;
    }
    viewController2 = self.gameNavController;
    
    // Tab 3: cloud
    CloudViewController* cloudController = [[CloudViewController alloc] init];
    self.cloudNavController = [[BufferedNavigationController alloc] initWithRootViewController:cloudController];
    viewController3 = self.cloudNavController;
    
    // Tab 4: twitter
    TwitterController* twitterController = [[TwitterController alloc] init];
    UINavigationController* twitterNavController = [[BufferedNavigationController alloc] initWithRootViewController:twitterController];
    viewController4 = twitterNavController;
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, viewController4,nil];
    
    UITabBarItem* tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:0];
    tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
    tabBarItem.title = @"Team";
    
    tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:1];
    tabBarItem.image = [UIImage imageNamed:@"63-runner.png"];
    tabBarItem.title = @"Game";
    
    tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:2];
    tabBarItem.image = [UIImage imageNamed:@"137-presentation.png"];
    tabBarItem.title = @"Website";  
    
    tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:3];
    tabBarItem.image = [UIImage imageNamed:@"210-twitterbird.png"];
    tabBarItem.title = @"Tweeting";  
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)resetTeamTab {
    if (IS_IPHONE) {
        [self.iPhoneTeamNavController popToRootViewControllerAnimated:NO];
    } else {
        [self.iPadTeamsMasterDetailController reset];
    }
    [self resetGameTab];
}

-(void)resetGameTab {
    [self.gameNavController popToRootViewControllerAnimated:NO];
}

-(void)resetCloudTab {
    [self.cloudNavController popToRootViewControllerAnimated:NO];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (!url) {  
        return NO; 
    }
    
    NSString *urlString = [url absoluteString];
    SHSLog(@"app opening via registered URL %@", urlString);

    return YES;
}

-(void)setupGlobalAppearance: (UIApplication *)application {
    self.window.tintColor = [ColorMaster applicationTintColor];
    application.statusBarStyle = UIStatusBarStyleLightContent;  // Causes light text in status bar
    
    // tab bar
    [UITabBar appearance].backgroundColor = [UIColor blackColor];
    [UITabBar appearance].barTintColor = [UIColor blackColor];
    
    // nav bar
    [UINavigationBar appearance].barStyle = UIBarStyleBlack;  // Causes light text in nav bar
    [UINavigationBar appearance].backgroundColor = [UIColor blackColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [ColorMaster titleBarColor],NSFontAttributeName : [UIFont boldSystemFontOfSize:18.0]}];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:18.0]} forState:UIControlStateNormal];
    
    // table view
    [UITableView appearance].separatorColor = [ColorMaster separatorColor];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[LeaguevineEventQueue sharedQueue] triggerImmediateSubmit];
    [[Reachability reachabilityForInternetConnection] startNotifier];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


@end
