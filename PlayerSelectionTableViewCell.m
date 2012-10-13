//
//  PlayerSelectionTableViewCell.m
//  UltimateIPhone
//
//  Created by james on 10/11/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "PlayerSelectionTableViewCell.h"
#import "Constants.h"
#import "Player.h"

@interface PlayerSelectionTableViewCell()

@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation PlayerSelectionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

-(void)setPlayer:(Player *)player {
    _player = player;
    NSString* playerName = [player isAnonymous] ? @"UNKNOWN" : player.name;
    self.label.text = playerName;
    self.button.titleLabel.text = playerName;
}

- (void)setChosen:(BOOL)isChosen {
    self.button.hidden = isChosen;
    self.label.hidden = !isChosen;
}

-(NSString*)reuseIdentifier {
    return STD_ROW_TYPE;
}

-(void)awakeFromNib {
    self.button.titleLabel.bounds = self.bounds;
}

@end
