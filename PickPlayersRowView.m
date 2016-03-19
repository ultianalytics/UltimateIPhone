//
//  PickPlayersRowView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/19/16.
//  Copyright © 2016 Summit Hill Software. All rights reserved.
//

#import "PickPlayersRowView.h"
#import "UIView+Convenience.h"
#import "PlayerButton.h"

@implementation PickPlayersRowView

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat viewWidth = self.superview.boundsWidth;
    int buttonWidth = (viewWidth - ((self.maxButtonsPerRow + 1) * self.buttonMargin)) / self.maxButtonsPerRow;
    int leftSlackMargin = (viewWidth - ((self.maxButtonsPerRow + 1) * self.buttonMargin) - (self.maxButtonsPerRow * buttonWidth)) / 2;
    
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[PlayerButton class]]) {
            long columnNumber = subView.tag;
            long x = leftSlackMargin + ((columnNumber + 1) * self.buttonMargin) + (columnNumber * buttonWidth);
            subView.frame = CGRectMake(x, 0, buttonWidth, self.buttonHeight);
        }
    }
    
}

@end
