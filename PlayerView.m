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
@synthesize player,actionListener,passerButton,passPointer,defensePlayerNameLabel,firstButton,secondButton,thirdButton;

-(void)initUI {
    self.player = [Player getAnonymous];
    [self setIsOffense: YES];
    [self makeSelected:NO];
    [self addGestureRecognizers];
    self.passerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.passerButton.titleLabel.numberOfLines = 1;
    self.passerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.passerButton.titleLabel.minimumScaleFactor = 0.5f;
}

- (void) setIsOffense: (BOOL) shouldSwitchToOffense {
    self.passPointer.hidden = NO;
    self.firstButton.hidden = NO;
    self.secondButton.hidden = NO;
    self.thirdButton.hidden = NO;
    
    self.thirdButton.hidden = isSelected;
    isOffense = shouldSwitchToOffense;
    self.passerButton.hidden = !isOffense;
    self.passPointer.hidden = !isOffense;
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
            self.defensePlayerNameLabel.text = @"UNKNOWN";
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
    [self.passerButton setIsCurrentPasser:isSelected];
    if (isOffense) {
        BOOL hide = isSelected && !player.isAnonymous;
        self.passPointer.hidden = hide;
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
       [self.actionListener action: Catch targetPlayer: self.player fromView: self];
    } else {
       [self.actionListener action: De targetPlayer: self.player fromView: self];
    }
}
- (IBAction)secondButtonClicked: (id) sender {
    if (isOffense) {
        [self.actionListener action: Drop targetPlayer: self.player fromView: self];
    } else {
        [self.actionListener action: Pull targetPlayer: self.player fromView: self];
    }
}
- (IBAction)thirdButtonClicked: (id) sender {
    [self.actionListener action: Goal targetPlayer: self.player fromView: self];
}

- (void)update: (Game*) game {
    if (!isOffense) {
        self.firstButton.hidden = [game canNextPointBePull] ? YES : NO;
        self.secondButton.hidden = [game canNextPointBePull] ? NO : YES;
    }
}

-(void)addGestureRecognizers {
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(passerButtonLongPress:)];
    [self.passerButton addGestureRecognizer:longPressRecognizer];
    
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(firstButtonLongPress:)];
    [self.firstButton addGestureRecognizer:longPressRecognizer];
    
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(secondButtonLongPress:)];
    [self.secondButton addGestureRecognizer:longPressRecognizer];
    
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(thirdButtonLongPress:)];
    [self.thirdButton addGestureRecognizer:longPressRecognizer];
}

-(void)passerButtonLongPress: (UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.actionListener passerLongPress: self.player view: self];
    }
}

-(void)firstButtonLongPress: (UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (isOffense) {
            [self.actionListener actionLongPress: Catch targetPlayer: self.player fromView: self];
        } else {
            [self.actionListener actionLongPress: De targetPlayer: self.player fromView: self];
        }
    }
}

-(void)secondButtonLongPress: (UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (isOffense) {
            [self.actionListener actionLongPress: Drop targetPlayer: self.player fromView: self];
        } else {
            [self.actionListener actionLongPress: Pull targetPlayer: self.player fromView: self];
        }
    }
}

-(void)thirdButtonLongPress: (UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.actionListener actionLongPress: Goal targetPlayer: self.player fromView: self];
    }
}

-(CGPoint)firstButtonCenter {
    return self.firstButton.center;
}

@end
