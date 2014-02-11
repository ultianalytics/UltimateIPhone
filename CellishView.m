//
//  CellishView.m
//  UltimateIPhone
//
//  Created by james on 2/8/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "CellishView.h"
#import "UIView+Convenience.h"
#import "ColorMaster.h"

#define separatorHeight 1

@implementation CellishView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    [self commonInit];
    }
    return self;
}

-(void)awakeFromNib {
    [self commonInit];
}

-(void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    [self addSeparator:YES];
    [self addSeparator:NO];
}

-(void)addSeparator: (BOOL)isTop {
    CGRect frame = self.bounds;
    if (!isTop) {
        frame.origin.y = frame.size.height - separatorHeight;
    }
    frame.size.height = separatorHeight;
    UIView* separator = [[UIView alloc] initWithFrame:frame];
    separator.backgroundColor = [ColorMaster separatorColor];
    separator.autoresizingMask = isTop ?
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin :
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:separator];
}


@end
