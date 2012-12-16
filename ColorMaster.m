//
//  ColorMaster.m
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorMaster.h"
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@implementation ColorMaster

static UIColor* massivelyDarkColor = nil;
static UIColor* hugelyColor = nil;
static UIColor* veryVeryDarkColor = nil;
static UIColor* veryDarkColor = nil;
static UIColor* almostVeryDarkColor = nil;
static UIColor* darkerColor = nil;
static UIColor* darklightColor = nil;
static UIColor* darklightestColor = nil;
static UIColor* lighterColor = nil;
static UIColor* lighterishColor = nil;
static UIColor* lightestColor = nil;

static UIColor* offenseEventColor = nil;
static UIColor* defenseEventColor = nil;

static UIColor* scoreWinColor = nil;
static UIColor* scoreLoseColor = nil;

static UIColor* activeGameColor = nil;

static UIColor* benchRowColor = nil;
static UIColor* navBarTintColor = nil;

static UIColor* alarmingButtonHighColor = nil;
static UIColor* alarmingButtonLowColor = nil;

static UIColor* darkButtonHighColor = nil;
static UIColor* darkButtonLowColor = nil;

static UIColor* linePlayerButtonColor0 = nil;
static UIColor* linePlayerButtonColor1 = nil;
static UIColor* linePlayerButtonColor2 = nil;
static UIColor* linePlayerButtonColor3 = nil;
static UIColor* linePlayerButtonColor4 = nil;
static UIColor* linePlayerButtonColor5 = nil;
static UIColor* linePlayerButtonColor6 = nil;
static NSArray* linePlayerButtonColors = nil;

static UIColor* linePlayerButtonPositionColorLight = nil;
static UIColor* linePlayerButtonPositionColorDark = nil;
static UIColor* linePlayerButtonPointsColorLight = nil;
static UIColor* linePlayerButtonPointsColorDark = nil;

static UIColor* linePlayerImbalanceWarningGirls;
static UIColor* linePlayerImbalanceWarningBoys;

+ (void) initialize {
    scoreWinColor = RGB(25,102,25);  // shade of green
    scoreLoseColor = RGB(178,5,0);  // shade of red
    
    // grayish sapphire blue  http://www.perbang.dk/rgb/10131C/
    // darkest to lightest
    //linePlayerButtonColor7 = RGB(0,6,25);
    linePlayerButtonColor6 = RGB(25,31,51);
    linePlayerButtonColor5 = RGB(51,57,76);
    linePlayerButtonColor4 = RGB(76,82,102);
    linePlayerButtonColor3 = RGB(102,108,127);
    linePlayerButtonColor2 = RGB(127,133,153);
    linePlayerButtonColor1 = RGB(153,159,178);
    linePlayerButtonColor0 = RGB(178,184,204);
    //linePlayerButtonColor0 = RGB(204,210,229);
    //linePlayerButtonColor0 = RGB(229,235,255);
    linePlayerButtonColors = [[NSArray alloc] initWithObjects:linePlayerButtonColor0, linePlayerButtonColor1, linePlayerButtonColor2,linePlayerButtonColor3,linePlayerButtonColor4,linePlayerButtonColor5,linePlayerButtonColor6,nil];
    
    linePlayerButtonPositionColorLight = RGB(204,178,229);
    linePlayerButtonPositionColorDark = RGB(128,108,153);
    linePlayerButtonPointsColorLight = RGB(229,219,153);
    linePlayerButtonPointsColorDark = RGB(102,94,51);
    
    
    darkButtonHighColor = RGB(102, 102, 102);
    darkButtonLowColor = RGB(25, 25, 0);// #191900
    
    massivelyDarkColor = RGB(25, 25, 0);// #191900
    hugelyColor = RGB(51,51,0); // ##333300
    veryVeryDarkColor = RGB(76,76,25); // #4C4C19
    veryDarkColor = RGB(102,102,51); // #666633
    almostVeryDarkColor = RGB(127,127,76); // #7F7F4C
    darkerColor = RGB(153,153,102);  // #999966
    darklightColor = RGB(173,173,132);  // ADAD84
    darklightestColor = RGB(193,193,162);  // C1C1A2
    lighterColor = RGB(204,204,153);  // #CCCC99
    lighterishColor = RGB(232,228,196);  // #CCCC99
    lightestColor =  RGB(255,255,204);  // #FFFFCC
    
    alarmingButtonHighColor = RGB(204,76,76);  // #CC4C4C
    alarmingButtonLowColor = RGB(153,25,25);  // #991919
    
    offenseEventColor = lightestColor;
    defenseEventColor = darkerColor;
    
    
    activeGameColor = [UIColor blueColor];
    
    benchRowColor = lighterColor;
    
    navBarTintColor = veryDarkColor;
    
    linePlayerImbalanceWarningBoys = RGB(153, 242, 255);  // #99F2FF 
    linePlayerImbalanceWarningGirls = RGB(255, 178, 242);  // #FFB2F2  

}

+(UIColor*)getTabBarSelectedImageColor {
    return lightestColor;
}

+(UIColor*)getSearchBarTintColor {
    return almostVeryDarkColor;
}

+(UIColor*)getNormalButtonHighColor {
    return linePlayerButtonColor4;
}

+(UIColor*)getNormalButtonLowColor {
    return linePlayerButtonColor6;
}

+(UIColor*)getNormalButtonSelectedHighColor {
    return linePlayerButtonColor0;
}
+(UIColor*)getNormalButtonSelectedLowColor {
    return linePlayerButtonColor2;
}

+(UIColor*)getPasserButtonHighColor {
    return linePlayerButtonColor4;
}

+(UIColor*)getPasserButtonLowColor {
    return linePlayerButtonColor6;
}

+(UIColor*)getPasserButtonSelectedHighColor {
    return linePlayerButtonColor0;
}

+(UIColor*)getPasserButtonSelectedLowColor {
    return linePlayerButtonColor2;
}

+(UIColor*)getNavBarTintColor {
    return navBarTintColor;
}

+(UIColor*)getDarkButtonHighColor {
    return darkButtonHighColor;
}

+(UIColor*)getDarkButtonLowColor {
    return darkButtonLowColor;
}

+(UIColor*)getWinScoreColor {
    return scoreWinColor;
}

+(UIColor*)getLoseScoreColor {
    return scoreLoseColor;
}

+(UIColor*)getActiveGameColor {
    return activeGameColor;
}

+(UIColor*)getOffenseEventColor {
    return offenseEventColor;
}

+(UIColor*)getDefenseEventColor {
    return defenseEventColor;
}

+(NSArray*)getLinePlayerButtonColors {
    return linePlayerButtonColors;
}

+(UIColor*)getLinePlayerPositionColor: (BOOL) dark {
    return dark ? linePlayerButtonPositionColorDark : linePlayerButtonPositionColorLight;
}

+(UIColor*)getLinePlayerPointsColor: (BOOL) dark {
    return dark ? linePlayerButtonPointsColorDark : linePlayerButtonPointsColorLight;
}

+(UIColor*)getBenchRowColor {
    return benchRowColor;
}

+(UIColor*)getFormTableCellColor {
    return lightestColor;
}

+(UIColor*)getTableListSeparatorColor {
    return lighterColor;
}

+(UIColor*)getAlarmingButtonHighColor {
    return alarmingButtonHighColor;
}

+(UIColor*)getAlarmingButtonLowColor {
    return alarmingButtonLowColor;
}

+(UIColor*)getSegmentControlLightTintColor {
    return darklightColor;
}

+(UIColor*)getSegmentControlDarkTintColor {
    return navBarTintColor;
}

+(UIColor*)getPlayerImbalanceColor: (BOOL)isBoy {
    return isBoy ? linePlayerImbalanceWarningBoys : linePlayerImbalanceWarningGirls;
}

+(void)styleAsWhiteLabel: (UILabel*) label size: (CGFloat) size {
    label.font = [UIFont boldSystemFontOfSize:size];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, 1);
}

@end
