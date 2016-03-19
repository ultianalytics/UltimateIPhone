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
    
    int buttonMargin = 2;
    int buttonWidth = (self.boundsWidth - ((self.maxButtonsPerRow + 1) * buttonMargin)) / self.maxButtonsPerRow;
    int leftSlackMargin = (self.boundsWidth - ((self.maxButtonsPerRow + 1) * buttonMargin) - (self.maxButtonsPerRow * buttonWidth)) / 2;
    
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[PlayerButton class]]) {
            long columnNumber = subView.tag;
            long x = leftSlackMargin + ((columnNumber + 1) * buttonMargin) + (columnNumber * buttonWidth);
            subView.frame = CGRectMake(x, 0, buttonWidth, self.buttonHeight);
        }
    }
    
}

@end
