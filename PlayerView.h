//
//  PlayerView.h
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBView.h"
#import "ActionListener.h"
@class Player;
@class PasserButton;
@class Game;

@interface PlayerView : IBView {
    BOOL isOffense;
    BOOL isSelected;
}
@property (nonatomic, strong) Player* player;
@property (nonatomic, strong) id<ActionListener> actionListener;
@property (nonatomic, strong) IBOutlet PasserButton* passerButton;
@property (nonatomic, strong) IBOutlet UILabel* passPointerLabel;
@property (nonatomic, strong) IBOutlet UILabel* defensePlayerNameLabel;
@property (nonatomic, strong) IBOutlet UIButton* firstButton;
@property (nonatomic, strong) IBOutlet UIButton* secondButton;
@property (nonatomic, strong) IBOutlet UIButton* thirdButton;

- (void) setIsOffense: (BOOL) shouldSwitchToOffense;

- (IBAction)passerButtonClicked: (id) sender;
- (IBAction)firstButtonClicked: (id) sender;
- (IBAction)secondButtonClicked: (id) sender;
- (IBAction)thirdButtonClicked: (id) sender;
- (void)caughtButtonClicked;
- (void)droppedButtonClicked;
- (void)goalButtonClicked;
- (void)deButtonClicked;
- (void)pullButtonClicked;
- (void)makeSelected: (BOOL) shouldBeSelected;
- (BOOL)isSelected;
- (void)update: (Game*) game;


@end
