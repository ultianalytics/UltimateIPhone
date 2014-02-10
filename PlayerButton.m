//
//  PlayerButton.m
//  Ultimate
//
//  Created by james on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerButton.h"
#import "ColorMaster.h"
#import "Team.h"
#import "PlayerButtonActual.h"
#import "Player.h"
#import "ImageMaster.h"

#define NUMBER_OF_BUTTON_COLORS 7

@implementation PlayerButton
@synthesize button, nameLabel, positionLabel, pointsLabel, genderImage;

-(void)setButtonFrame: (CGRect) buttonRectangle {
    super.frame = buttonRectangle;
    self.frame = buttonRectangle;
}

-(void)buttonClicked: (id) actualPlayerButton {
    [listener buttonClicked: self isOnField: isOnField];
}

-(void)setOnField: (BOOL) shouldBeOnField {
    isOnField = shouldBeOnField;
}

-(void)setClickListener: (id<PlayerButtonListener>) aListener {
    listener = aListener;
    [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setPlayer: (Player*) player {
    _player = player;
    if (isOnField) {
        [self.nameLabel setText: @"open"]; 
    } 
    if (_player != nil) {
        [self.button setTitle: [_player getDisplayName] forState:UIControlStateNormal];
        [self.nameLabel setText: [_player getDisplayName]];
        self.positionLabel.text = _player.position == Any ? @"" : _player.position == Cutter ? @"C" : @"H";
    }
    self.button.hidden = _player == nil ? YES : NO;
    self.nameLabel.hidden = _player == nil ? NO : YES;
    self.positionLabel.hidden = _player == nil ? YES : NO;
    self.pointsLabel.hidden = _player == nil ? YES : NO;
    BOOL isMixedTeam = [Team getCurrentTeam].isMixed;
    self.genderImage.hidden = player == nil || !isMixedTeam || (isMixedTeam && player.isMale);
}

-(void)setPlayer: (Player*) player points: (float) points pointFactor: (float) pointFactor {
    [self setPlayer:player];
    if (ceil(points) == floor(points)) {
        self.pointsLabel.text = [NSString stringWithFormat:@"%d", (int)points];
    } else {
        self.pointsLabel.text = [NSString stringWithFormat:@"%.1f", points]; 
    }
    [self setButtonColor: pointFactor];
    self.pointsLabel.textColor = [ColorMaster getLinePlayerPointsColor: pointFactor <= 0.3];
    self.positionLabel.textColor = [ColorMaster getLinePlayerPositionColor: pointFactor <= 0.3];
}

-(void)setButtonColor: (float) pointsPlayedFactor {
    int factor = lroundf(pointsPlayedFactor * (float)(NUMBER_OF_BUTTON_COLORS - 1));
    int normalColorIndex = MIN(MAX(factor, 0), NUMBER_OF_BUTTON_COLORS - 1);
    int highlightColorIndex = MIN(MAX(factor + 1, 0), NUMBER_OF_BUTTON_COLORS);
    [self.button setBackgroundImage:[ImageMaster stretchableImageForPlayingTimeFactor:normalColorIndex] forState:UIControlStateNormal];
    [self.button setBackgroundImage:[ImageMaster stretchableImageForPlayingTimeFactor:highlightColorIndex] forState:UIControlStateHighlighted];
    self.button.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
//    [self.button setTitleColor: (factor < 3 ? [UIColor blackColor] : [UIColor whiteColor]) forState:UIControlStateNormal];
    [self.button setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
}

-(Player*)getPlayer {
    return _player;
}

-(NSString*)getPlayerName {
    return _player == nil ? self.nameLabel.text : [_player getDisplayName];
}

- (NSString* )description {
    return [NSString stringWithFormat:@"PlayerButton player = %@, player name = %@, isOnField = %@", [_player description], [self getPlayerName], isOnField ? @"YES" : @"NO"];
}



@end
