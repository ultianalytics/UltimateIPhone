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

@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation PlayerSelectionTableViewCell

-(id)init {
    self = [super init];
    [self commonInit];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

-(void)commonInit {
    self.chosen = NO;
}

-(void)setPlayer:(Player *)player {
    _player = player;
    NSString* playerName = [player isAnonymous] ? @"UNKNOWN" : player.name;
    self.label.text = playerName;
}

- (void)setChosen:(BOOL)isChosen {
    self.checkImageView.hidden = !isChosen;
    self.label.textColor = isChosen ? [UIColor blackColor] : [UIColor darkGrayColor];
}

-(NSString*)reuseIdentifier {
    return STD_ROW_TYPE;
}


@end
