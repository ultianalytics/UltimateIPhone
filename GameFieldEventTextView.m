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
@property (nonatomic, weak) IBOutlet UILabel* outOfBoundLabel;

@end

@implementation GameFieldEventTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)awakeFromNib {
    self.outOfBoundLabel.text = @"Out of\nBounds";
    self.eventDescriptionLabel.text = @"";
    self.outOfBoundLabel.preferredMaxLayoutWidth = self.boundsWidth;
    self.eventDescriptionLabel.preferredMaxLayoutWidth = self.boundsWidth;
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.eventDescriptionLabel.textColor = textColor;
}

-(void)setPointDescription:(NSString *)description {
    _pointDescription = description;
    self.eventDescriptionLabel.text = description;
}

- (void)flashOutOfBoundsMessage {
    [self showOutOfBounds];
}

- (void)showOutOfBounds {
    self.eventDescriptionLabel.hidden = YES;
    self.outOfBoundLabel.hidden = NO;
    [self performSelector:@selector(animateHideOfBoundsLabel) withObject:self afterDelay:1];
}

- (void)animateHideOfBoundsLabel {
    self.eventDescriptionLabel.alpha = 0;
    self.eventDescriptionLabel.hidden = NO;
    [UIView animateWithDuration:.5 animations:^{
        self.outOfBoundLabel.alpha = 0;
        self.eventDescriptionLabel.alpha = 1;
    } completion:^(BOOL finished) {
        self.outOfBoundLabel.hidden = YES;
        self.outOfBoundLabel.alpha = 1;
    }];
}


@end
