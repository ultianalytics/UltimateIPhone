//
//  ColorMaster.h
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorMaster : NSObject

+(UIColor*)getTabBarSelectedImageColor;
+(UIColor*)getOffenseEventColor;
+(UIColor*)getDefenseEventColor;
+(UIColor*)getWinScoreColor;
+(UIColor*)getLoseScoreColor;
+(UIColor*)getActiveGameColor;
+(UIColor*)getBenchRowColor;
+(UIColor*)getNavBarTintColor;
+(NSArray*)getLinePlayerButtonColors;
+(UIColor*)getLinePlayerPositionColor: (BOOL) dark;
+(UIColor*)getLinePlayerPointsColor: (BOOL) dark;
+(UIColor*)getNormalButtonHighColor;
+(UIColor*)getNormalButtonLowColor;
+(UIColor*)getNormalButtonSelectedHighColor;
+(UIColor*)getNormalButtonSelectedLowColor;
+(UIColor*)getPasserButtonHighColor;
+(UIColor*)getPasserButtonLowColor;
+(UIColor*)getPasserButtonSelectedHighColor;
+(UIColor*)getPasserButtonSelectedLowColor;
+(UIColor*)getFormTableCellColor;
+(UIColor*)getTableListSeparatorColor;
+(UIColor*)getAlarmingButtonHighColor;
+(UIColor*)getAlarmingButtonLowColor;
+(UIColor*)getSegmentControlLightTintColor;
+(UIColor*)getSegmentControlDarkTintColor;
+(UIColor*)getPlayerImbalanceColor: (BOOL)isMaleImbalance;

@end
