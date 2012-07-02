//
//  PlayerView.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "PlayerView.h"
#import "Player.h"
#import "PasserButton.h"
#import "Game.h"
#import "AnonymousPlayer.h"

@implementation PlayerView
@synthesize player,actionListener,passerButton,passPointerLabel,defensePlayerNameLabel,firstButton,secondButton,thirdButton;

-(void)initUI {
    self.player = [Player getAnonymous];
    [self setIsOffense: YES];
    [self makeSelected:NO];
}

- (void) setIsOffense: (BOOL) shouldSwitchToOffense {
    self.passPointerLabel.hidden = NO;
    self.firstButton.hidden = NO;
    self.secondButton.hidden = NO;
    self.thirdButton.hidden = NO;
    
    self.thirdButton.hidden = isSelected;
    isOffense = shouldSwitchToOffense;
    self.passerButton.hidden = !isOffense;
    self.passPointerLabel.hidden = !isOffense;
    self.defensePlayerNameLabel.hidden = isOffense;
    self.thirdButton.hidden = !isOffense;
    self.secondButton.hidden = [player isAnonymous] && !isOffense;
    [self.firstButton setTitle: isOffense ? @"Catch" : @"D" forState:UIControlStateNormal];
    [self.secondButton setTitle: isOffense ? @"Drop" : @"Pull" forState:UIControlStateNormal];
    [self.thirdButton setTitle:@"Goal" forState:UIControlStateNormal];
    if ([player isAnonymous]) {
        if (isOffense) {
            [self.passerButton setTitle: @"UNKNOWN" forState:UIControlStateNormal];
        } else {
            self.defensePlayerNameLabel.text = @"TEAM";
        }
    } 
}

- (NSString* )description {
    return self.player ? [NSString stringWithFormat:@"PlayerView with player %@", [self.player getDisplayName]] : @"PlayerView wihout a Player";
}

-(void)setPlayer:(Player*) aPlayer {
    player = aPlayer;
    [passerButton setTitle: [self.player getDisplayName] forState:UIControlStateNormal];
    defensePlayerNameLabel.text = [self.player getDisplayName];
}

- (void)makeSelected: (BOOL) shouldBeSelected {
    isSelected = shouldBeSelected;
    [self.passerButton setSelected:isSelected];
    if (isOffense) {
        BOOL hide = isSelected && !player.isAnonymous;
        self.passPointerLabel.hidden = hide;
        self.firstButton.hidden = hide;
        self.secondButton.hidden = hide;
        self.thirdButton.hidden = hide;
    }
    [self setNeedsDisplay];
}

- (void) setNeedToSelectPasser: (BOOL) needToSelectPasser {
    self.passerButton.isLabelStyle = !needToSelectPasser;
}

- (BOOL)isSelected {
    return isSelected;
}

- (IBAction)passerButtonClicked: (id) sender {
    [self.actionListener passerSelected: self.player view: self];
}

- (IBAction)firstButtonClicked: (id) sender {
    if (isOffense) {
       [self caughtButtonClicked];
    } else {
       [self deButtonClicked]; 
    }
}
- (IBAction)secondButtonClicked: (id) sender {
    if (isOffense) {
        [self droppedButtonClicked];
    } else {
        [self pullButtonClicked]; 
    }
}
- (IBAction)thirdButtonClicked: (id) sender {
    [self goalButtonClicked];
}

- (void)caughtButtonClicked {
    [self.actionListener action: Catch targetPlayer: self.player fromView: self];
}
- (void)droppedButtonClicked {
    [self.actionListener action: Drop targetPlayer: self.player fromView: self];
}
- (void)goalButtonClicked {
    [self.actionListener action: Goal targetPlayer: self.player fromView: self];
}
- (void)deButtonClicked {
    [self.actionListener action: De targetPlayer: self.player fromView: self];
}
- (void)pullButtonClicked {
    [self.actionListener action: Pull targetPlayer: self.player fromView: self];
}

- (void)update: (Game*) game {
    if (!isOffense) {
        self.firstButton.hidden = [game canNextPointBePull] ? YES : NO;
        self.secondButton.hidden = [game canNextPointBePull] ? NO : YES;
    }
}

@end
