//
//  PlayDirectionView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/31/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "PlayDirectionView.h"
#import "UIView+Convenience.h"
#import "ColorMaster.h"
#import "Team.h"
#import "Game.h"

@interface PlayDirectionView()

@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;
@property (weak, nonatomic) IBOutlet UILabel *rightTeamName;
@property (weak, nonatomic) IBOutlet UIImageView *leftArrow;
@property (weak, nonatomic) IBOutlet UILabel *leftTeamName;

@end

@implementation PlayDirectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)setIsPointingLeft:(BOOL)isPointingLeft {
    _isPointingLeft = isPointingLeft;
    [self updateView];
}

-(void)setIsOurTeam:(BOOL)isOurTeam {
    _isOurTeam = isOurTeam;
    NSString* teamName = isOurTeam ? [Team getCurrentTeam].name : [Game getCurrentGame].opponentName;
    self.self.leftTeamName.text = teamName;
    self.self.rightTeamName.text = teamName;
    [self updateView];
}

-(void)updateView {
    self.leftView.visible = self.isPointingLeft;
    self.rightView.hidden = self.leftView.visible;
    if (self.leftView.visible) {
        self.leftArrow.image = [UIImage imageNamed:self.isOurTeam ? @"play-direction-our-team-left" : @"play-direction-their-team-left"];
        self.leftTeamName.textColor = self.isOurTeam ? [ColorMaster applicationTintColor] : [UIColor redColor];
    } else {
        self.rightArrow.image = [UIImage imageNamed:self.isOurTeam ? @"play-direction-our-team-right" : @"play-direction-their-team-right"];
        self.rightTeamName.textColor = self.isOurTeam ? [ColorMaster applicationTintColor] : [UIColor redColor];
    }
}

@end
