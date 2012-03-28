//
//  AppDelegate.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TeamViewController.h"
#import "GameViewSwitcherController.h"
#import "GameViewController.h"
#import "GamesPlayedController.h"
#import "PreferencesViewController.h"
#import "TestFlight.h"
#import "CloudViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

-(void)switchGameView: (Class) viewClass transition: (UIViewAnimationTransition) transition{
    //[[self getGameViewSwitchController] switchActiveContoller:viewClass];
    [[self getGameViewSwitchController] switchActiveControllerAnimated:viewClass transition: transition];
}

-(GameViewSwitcherController*)getGameViewSwitchController {
    return [self.tabBarController.viewControllers objectAtIndex:1];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // start up test flight SDK
    [TestFlight takeOff:@"01dff7f7ad89edec89a36930e359a707_NjE1NDUyMDEyLTAyLTEyIDEzOjM5OjU0Ljc5NDg1OQ"];
 
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Tab 1: team
    TeamViewController *teamController = [[TeamViewController alloc] initWithNibName:@"TeamViewController" bundle:nil];
    UINavigationController* teamNavController = [[UINavigationController alloc] initWithRootViewController:teamController];
    UIViewController *viewController1 = teamNavController;

    // Tab 2: game
    GameViewController* gameController = [[GameViewController alloc] init];
    UINavigationController* gameNavController = [[UINavigationController alloc] initWithRootViewController:gameController];
    UIViewController *viewController2 = gameNavController;
    
    // Tab 3: games played
    GamesPlayedController* gamesPlayedController = [[GamesPlayedController alloc] init];
    UINavigationController* gamesPlayedNavController = [[UINavigationController alloc] initWithRootViewController:gamesPlayedController];
    UIViewController *viewController3 = gamesPlayedNavController;
    
    // Tab 4: cloud
    CloudViewController* cloudController = [[CloudViewController alloc] init];
    UINavigationController* cloudNavController = [[UINavigationController alloc] initWithRootViewController:cloudController];
    UIViewController* viewController4 = cloudNavController;
    
    // Tab 5: settings
    PreferencesViewController* preferencesController = [[PreferencesViewController alloc] init];
    UINavigationController* preferencesNavController = [[UINavigationController alloc] initWithRootViewController:preferencesController];
    UIViewController *viewController5 = preferencesNavController;
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, viewController4,viewController5, nil];
    
    UITabBarItem* tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:0];
    tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
    tabBarItem.title = @"Team";
    
    tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:1];
    tabBarItem.image = [UIImage imageNamed:@"63-runner.png"];
    tabBarItem.title = @"Game";
    
    tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:2];
    tabBarItem.image = [UIImage imageNamed:@"255-box.png"];
    tabBarItem.title = @"Games History";  
    
    tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:3];
    tabBarItem.image = [UIImage imageNamed:@"234-cloud.png"];
    tabBarItem.title = @"Cloud";  
    
    tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:4];
    tabBarItem.image = [UIImage imageNamed:@"19-gear.png"];
    tabBarItem.title = @"Config";  
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
