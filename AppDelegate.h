//
//  AppDelegate.h
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewSwitcherController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

-(void)switchGameView: (Class) viewClass transition: (UIViewAnimationTransition) transition;
-(GameViewSwitcherController*)getGameViewSwitchController;

@end
