//
//  ColorMaster.m
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorMaster.h"

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
    scoreWinColor = uirgb(25,102,25);  // shade of green
    scoreLoseColor = uirgb(178,5,0);  // shade of red
    
    // grayish sapphire blue  http://www.perbang.dk/rgb/10131C/
    // darkest to lightest
    //linePlayerButtonColor7 = uirgb(0,6,25);
    linePlayerButtonColor6 = uirgb(25,31,51);
    linePlayerButtonColor5 = uirgb(51,57,76);
    linePlayerButtonColor4 = uirgb(76,82,102);
    linePlayerButtonColor3 = uirgb(102,108,127);
    linePlayerButtonColor2 = uirgb(127,133,153);
    linePlayerButtonColor1 = uirgb(153,159,178);
    linePlayerButtonColor0 = uirgb(178,184,204);
    //linePlayerButtonColor0 = uirgb(204,210,229);
    //linePlayerButtonColor0 = uirgb(229,235,255);
    linePlayerButtonColors = [[NSArray alloc] initWithObjects:linePlayerButtonColor0, linePlayerButtonColor1, linePlayerButtonColor2,linePlayerButtonColor3,linePlayerButtonColor4,linePlayerButtonColor5,linePlayerButtonColor6,nil];
    
    linePlayerButtonPositionColorLight = uirgb(204,178,229);
    linePlayerButtonPositionColorDark = uirgb(128,108,153);
    linePlayerButtonPointsColorLight = uirgb(229,219,153);
    linePlayerButtonPointsColorDark = uirgb(102,94,51);
    
    
    darkButtonHighColor = uirgb(102, 102, 102);
    darkButtonLowColor = uirgb(25, 25, 0);// #191900
    
    massivelyDarkColor = uirgb(25, 25, 0);// #191900
    hugelyColor = uirgb(51,51,0); // ##333300
    veryVeryDarkColor = uirgb(76,76,25); // #4C4C19
    veryDarkColor = uirgb(102,102,51); // #666633
    almostVeryDarkColor = uirgb(127,127,76); // #7F7F4C
    darkerColor = uirgb(153,153,102);  // #999966
    darklightColor = uirgb(173,173,132);  // ADAD84
    darklightestColor = uirgb(193,193,162);  // C1C1A2
    lighterColor = uirgb(204,204,153);  // #CCCC99
    lighterishColor = uirgb(232,228,196);  // #CCCC99
    lightestColor =  uirgb(255,255,204);  // #FFFFCC
    
    alarmingButtonHighColor = uirgb(204,76,76);  // #CC4C4C
    alarmingButtonLowColor = uirgb(153,25,25);  // #991919
    
    offenseEventColor = lightestColor;
    defenseEventColor = darkerColor;
    
    
    activeGameColor = [UIColor redColor];
    
    benchRowColor = lighterColor;
    
    navBarTintColor = veryDarkColor;
    
    linePlayerImbalanceWarningBoys = uirgb(153, 242, 255);  // #99F2FF 
    linePlayerImbalanceWarningGirls = uirgb(255, 178, 242);  // #FFB2F2  

}

+(UIColor*)getTabBarSelectedImageColor {
    return [UIColor whiteColor];
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
    return [UIColor colorWithWhite:255.f/255.f alpha:1.f];
}

+(UIColor*)getTableListSeparatorColor {
    return [UIColor colorWithWhite:200.f/255.f alpha:1.f];
}

+(UIColor*)getAlarmingButtonHighColor {
    return alarmingButtonHighColor;
}

+(UIColor*)getAlarmingButtonLowColor {
    return alarmingButtonLowColor;
}

+(UIColor*)getSegmentControlLightTintColor {
    return [UIColor darkGrayColor];
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

+(UIColor*)applicationTintColor {
//    return [UIColor redColor];
//    return uihex(0x999919);  // ultimate tint green
    return uirgb(131,187,44); // green
}

@end
