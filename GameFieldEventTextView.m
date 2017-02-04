//
//  GameFieldEventTextView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/3/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldEventTextView.h"
#import "UIView+Convenience.h"

@interface GameFieldEventTextView ()

@property (nonatomic, weak) IBOutlet UILabel* eventDescriptionLabel;

@end

@implementation GameFieldEventTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.eventDescriptionLabel.text = @"";
    self.eventDescriptionLabel.preferredMaxLayoutWidth = self.boundsWidth;
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.eventDescriptionLabel.textColor = textColor;
}

-(void)setPointDescription:(NSString *)description {
    _pointDescription = description;
    self.eventDescriptionLabel.text = description;
}

@end
