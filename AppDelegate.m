//
//  AppDelegate.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TeamsViewController.h"
#import "TeamViewController.h"
#import "GameViewController.h"
#import "GamesPlayedController.h"
#import "PreferencesViewController.h"
#import "TestFlight.h"
#import "CloudViewController.h"
#import "TwitterController.h"
#import "ColorMaster.h"
#import "LeaguevineEventQueue.h"
#import "Reachability.h"
#import "BufferedNavigationController.h"

@implementation AppDelegate

UINavigationController* teamNavController;
UINavigationController* gameNavController;

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // start up test flight SDK
    [TestFlight takeOff:@"d8b09015-d74c-461d-993c-e7e378ebbeb5"];
    
    [self setupGlobalAppearance];
     
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Tab 1: team
    TeamsViewController* teamController = [[TeamsViewController alloc] initWithNibName:@"TeamsViewController" bundle:nil];
    teamNavController = [[BufferedNavigationController alloc] initWithRootViewController:teamController];
    UIViewController *viewController1 = teamNavController;

    // Tab 2: game
    GamesPlayedController* gameController = [[GamesPlayedController alloc] init];
    gameNavController = [[BufferedNavigationController alloc] initWithRootViewController:gameController];
    UIViewController *viewController2 = gameNavController;
    
    // Tab 3: cloud
    CloudViewController* cloudController = [[CloudViewController alloc] init];
    UINavigationController* cloudNavController = [[BufferedNavigationController alloc] initWithRootViewController:cloudController];
    UIViewController* viewController3 = cloudNavController;
    
    // Tab 4: twitter
    TwitterController* twitterController = [[TwitterController alloc] init];
    UINavigationController* twitterNavController = [[BufferedNavigationController alloc] initWithRootViewController:twitterController];
    UIViewController *viewController4 = twitterNavController;
    
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
    [teamNavController popToRootViewControllerAnimated:NO];
    [self resetGameTab];
}

-(void)resetGameTab {
    [gameNavController popToRootViewControllerAnimated:NO];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (!url) {  
        return NO; 
    }
    
    NSString *urlString = [url absoluteString];
    NSLog(@"app opening via registered URL %@", urlString);

    return YES;
}

-(void)setupGlobalAppearance {
    // TODO...update the global appearance?
//    [[UINavigationBar appearance] setTintColor: [ColorMaster getNavBarTintColor]];
//    [[UITabBar appearance] setSelectedImageTintColor: [ColorMaster getTabBarSelectedImageColor]];
//    [[UITableView appearance] setSeparatorColor:[ColorMaster getTableListSeparatorColor]];
//    [[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
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
