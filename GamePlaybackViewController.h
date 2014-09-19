//
//  GamePlaybackViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/11/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Game, Team;

@interface GamePlaybackViewController : UIViewController

@property (nonatomic, strong) Game* game;
@property (nonatomic, strong) Team* team;

@end