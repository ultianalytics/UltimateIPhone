//
//  PlayerButtonActual.m
//
//  Created by james on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerButtonActual.h"
#import "ColorMaster.h"
#define kMaxPlayerFactor 7

@implementation PlayerButtonActual

- (void)initCharacteristics {
    [self setColor: 0];
}

-(void)setColor: (float) pointsPlayedFactor {
    long factor = lroundf(pointsPlayedFactor * ([[ColorMaster getLinePlayerButtonColors] count] - 3));
    self.highColor = [[ColorMaster getLinePlayerButtonColors] objectAtIndex:MAX(factor, 0)];
    self.lowColor = [[ColorMaster getLinePlayerButtonColors] objectAtIndex:MIN(factor + 2, [[ColorMaster getLinePlayerButtonColors] count] - 1)];
    
    self.borderColor = self.highColor;
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self setNeedsDisplay];
}


@end
