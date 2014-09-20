//
//  ColorMaster.h
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorMaster : NSObject

+(UIColor*)getWinScoreColor;
+(UIColor*)getLoseScoreColor;
+(UIColor*)getActiveGameColor;
+(UIColor*)getOffenseEventColor;
+(UIColor*)getDefenseEventColor;
+(UIColor*)getLinePlayerPositionColor: (BOOL) dark;
+(UIColor*)getLinePlayerPointsColor: (BOOL) dark;
+(UIColor*)getFormTableCellColor;
+(UIColor*)getPlayerImbalanceColor: (BOOL)isMaleImbalance;
+(UIColor*)applicationTintColor;
+(UIColor*)titleBarColor;
+(UIColor*)lightBackgroundColor;
+(UIColor*)separatorColor;
+(UIColor*)darkGrayColor;
+(UIColor*)actionBackgroundColor;
+(UIColor*)ourTeamPositionalColor;
+(UIColor*)theirTeamPositionalColor;

@end
