//
//  ColorMaster.m
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorMaster.h"

@implementation ColorMaster

+(UIColor*)getWinScoreColor {
    return [self applicationTintColor];
}

+(UIColor*)getLoseScoreColor {
    return [UIColor redColor];
}

+(UIColor*)getActiveGameColor {
    return [self applicationTintColor];
}

+(UIColor*)getLinePlayerPositionColor: (BOOL) dark {
    return dark ? [ColorMaster darkGrayColor] : [ColorMaster darkGrayColor];
}

+(UIColor*)getLinePlayerPointsColor: (BOOL) dark {
    return dark ? [UIColor whiteColor] : [UIColor whiteColor];
}

+(UIColor*)getFormTableCellColor {
    return [UIColor colorWithWhite:255.f/255.f alpha:1.f];
}

+(UIColor*)getPlayerImbalanceColor: (BOOL)isBoy {
    return isBoy ? uirgb(153, 242, 255) : uirgb(255, 178, 242);
}

+(UIColor*)applicationTintColor {
    return uirgb(132,188,44); // light green
}

+(UIColor*)titleBarColor {
    return [self lightBackgroundColor];
}

+(UIColor*)lightBackgroundColor {
    return uirgb(236, 235, 232);
}

+(UIColor*)separatorColor {
    return uirgb(213, 212, 216);
}

+(UIColor*)darkGrayColor {
    return uirgb(68, 68, 68);
}

+(UIColor*)getOffenseEventColor {
    return uirgb(255, 255, 255);
}

+(UIColor*)getDefenseEventColor {
    return uirgb(240, 239, 234);
}

+(UIColor*)actionBackgroundColor {
    return uirgb(216, 215, 200);  // sort of mouse grey
}

+(UIColor*)ourTeamPositionalColor {
    return [self applicationTintColor];
}

+(UIColor*)theirTeamPositionalColor {
    return [UIColor redColor];
}

@end
