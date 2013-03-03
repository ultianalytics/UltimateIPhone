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
    self.label.textColor = isChosen ? [UIColor whiteColor] : [UIColor blackColor];
}

-(NSString*)reuseIdentifier {
    return STD_ROW_TYPE;
}


@end
