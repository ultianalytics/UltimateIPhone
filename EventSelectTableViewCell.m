//
//  EventSelectTableViewCell.m
//  UltimateIPhone
//
//  Created by james on 10/11/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "EventSelectTableViewCell.h"
#import "Constants.h"
#import "Event.h"
#import "ColorMaster.h"

@interface EventSelectTableViewCell()

@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation EventSelectTableViewCell

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
    [self commonInit];
}

-(void)commonInit {
    self.chosen = NO;
}

-(void)setEvent:(Event *)event {
    _event = event;
    self.label.text = [event description];
}

- (void)setChosen:(BOOL)isChosen {
    self.checkImageView.hidden = !isChosen;
    if (isChosen) {
        [ColorMaster styleAsWhiteLabel: self.label size: self.label.font.pointSize];
    } else {
        self.label.textColor = [UIColor blackColor];
        self.label.shadowOffset = CGSizeZero;
    }
}

-(NSString*)reuseIdentifier {
    return STD_ROW_TYPE;
}


@end
