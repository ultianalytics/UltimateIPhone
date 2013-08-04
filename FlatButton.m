//
//  FlatButton.m
//  UltimateIPhone
//
//  Created by james on 8/4/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "FlatButton.h"

@implementation FlatButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.layer setCornerRadius:3.0f];
}


@end
