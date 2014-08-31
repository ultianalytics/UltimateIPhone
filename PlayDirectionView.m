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

-(void)setIsLeft:(BOOL)isLeft {
    _isLeft = isLeft;
    [self updateView];
}

-(void)setIsOurTeam:(BOOL)isOurTeam {
    _isOurTeam = isOurTeam;
    self.rightTeamName.textColor = isOurTeam ? [ColorMaster applicationTintColor] : [UIColor redColor];
    [self updateView];
}

-(void)setTeamName:(NSString *)teamName {
    _teamName = teamName;
    self.rightTeamName.text = teamName;
    self.leftTeamName.text = teamName;
    [self updateView];
}

-(void)updateView {
    self.leftView.visible = self.isLeft;
    self.rightView.hidden = self.leftView.visible;
    if (self.leftView.visible) {
        self.leftArrow.image = [UIImage imageNamed:self.isOurTeam ? @"play-direction-our-team-left" : @"play-direction-their-team-left"];
    } else {
        self.rightArrow.image = [UIImage imageNamed:self.isOurTeam ? @"play-direction-our-team-right" : @"play-direction-their-team-right"];
    }
}

@end
