//
//  ImageMaster.m
//  Ultimate
//
//  Created by james on 1/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageMaster.h"


@implementation ImageMaster

static UIImage* catchImage = nil;
static UIImage* dropImage = nil;
static UIImage* ourGoalImage = nil;
static UIImage* theirGoalImage = nil;
static UIImage* offenseThrowawayImage = nil;
static UIImage* defenseThrowawayImage = nil;
static UIImage* pullImage = nil;
static UIImage* pullObImage = nil;
static UIImage* deImage = nil;
static UIImage* ourCallahanImage = nil;
static UIImage* theirCallahanImage = nil;
static UIImage* maleImage = nil;
static UIImage* femaleImage = nil;
static UIImage* neutralGenderImage = nil;
static UIImage* cessationImage = nil;
static UIImage* gameoverImage = nil;
static UIImage* unknownImage = nil;


+ (void) initialize {
    catchImage = [UIImage imageNamed:@"big_smile.png"];
    dropImage = [UIImage imageNamed:@"eyes_droped.png"];
    ourGoalImage = [UIImage imageNamed:@"super_man.png"];
    theirGoalImage = [UIImage imageNamed:@"cry.png"];
    offenseThrowawayImage = [UIImage imageNamed:@"shame.png"];
    defenseThrowawayImage = [UIImage imageNamed:@"exciting.png"];
    pullImage = [UIImage imageNamed:@"nothing.png"];
    pullObImage = [UIImage imageNamed:@"what.png"];
    deImage = [UIImage imageNamed:@"electric_shock.png"];
    ourCallahanImage = [UIImage imageNamed:@"victory.png"];
    theirCallahanImage = [UIImage imageNamed:@"shocked"];
    unknownImage = [UIImage imageNamed:@"hearts.png"];
    maleImage = [UIImage imageNamed:@"769-male.png"];
    femaleImage = [UIImage imageNamed:@"768-female.png"];
    neutralGenderImage = [UIImage imageNamed:@"player_passing.png"];
    cessationImage = [UIImage imageNamed:@"stopwatch1.png"];
    gameoverImage = [UIImage imageNamed:@"finishflag.png"];
}

+ (UIImage*) getImageForEvent: (Event*) event {
    if ((![event isOffense]) && event.action == Goal) {
        return [ImageMaster getTheirGoalImage];  
    } else if ((![event isOffense]) && event.action == Throwaway) {
        return [ImageMaster getOpponentThrowawayImage];  
    } else if (event.action == Callahan) {
        return event.isOffense ? [ImageMaster getTheirCallahanImage] : [ImageMaster getOurCallahanImage];
    }
    switch(event.action) {
        case Catch:
            return [ImageMaster getCatchImage];
        case Drop:
            return [ImageMaster getDropImage];
        case Goal:
            return [ImageMaster getOurGoalImage];    
        case Throwaway:
            return [ImageMaster getThrowawayImage];
        case Stall:
            return [ImageMaster getThrowawayImage];
        case MiscPenalty:
            return [ImageMaster getThrowawayImage];
        case Pull:
            return [ImageMaster getPullImage];
        case PullOb:
            return [ImageMaster getPullObImage];
        case De:
            return [ImageMaster getDeImage];
        case EndOfFirstQuarter:
            return [ImageMaster getPeriodEndImage];
        case EndOfThirdQuarter:
            return [ImageMaster getPeriodEndImage];
        case Halftime:
            return [ImageMaster getPeriodEndImage];
        case EndOfFourthQuarter:
            return [ImageMaster getPeriodEndImage];
        case EndOfOvertime:
            return [ImageMaster getPeriodEndImage];
        case GameOver:
            return [ImageMaster getFinishImage];
        case Timeout:
            return [ImageMaster getTimeoutImage];
        default:
            return [ImageMaster getUnknownImage];
    }
}


+(UIImage*)getCatchImage {
    return catchImage;
}

+(UIImage*)getDropImage {
    return dropImage;
}

+(UIImage*)getOurGoalImage {
    return ourGoalImage;
}

+(UIImage*)getTheirGoalImage {
    return theirGoalImage;
}

+(UIImage*)getThrowawayImage {
    return offenseThrowawayImage;
}

+(UIImage*)getOpponentThrowawayImage {
    return defenseThrowawayImage;
}

+(UIImage*)getPullImage {
    return pullImage;
}

+(UIImage*)getPullObImage {
    return pullObImage;
}

+(UIImage*)getDeImage {
    return deImage;
}

+(UIImage*)getOurCallahanImage {
    return ourCallahanImage;
}

+(UIImage*)getTheirCallahanImage {
    return theirCallahanImage;
}

+(UIImage*)getUnknownImage {
    return unknownImage;
}

+(UIImage*)getMaleImage {
    return maleImage;
}

+(UIImage*)getFemaleImage {
    return femaleImage;
}

+(UIImage*)getNeutralGenderImage {
    return neutralGenderImage;
}

+(UIImage*)getCessationImage {
    return cessationImage;
}

+(UIImage*)getPeriodEndImage {
    return cessationImage;
}

+(UIImage*)getFinishImage {
    return gameoverImage;
}

+(UIImage*)getTimeoutImage {
    return cessationImage;
}

+(UIImage*)stretchableWhite100Radius3 {
    	return [[UIImage imageNamed:@"white100radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

+(UIImage*)stretchableWhite200Radius3 {
    return [[UIImage imageNamed:@"white200radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

// for a number 0-6...answer a button image...lower number is lighter image
+(UIImage*)stretchableImageForPlayingTimeFactor: (int)factor {
    switch (factor) {
        case 0:
            return [[UIImage imageNamed:@"color7CCC00Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 1:
            return [[UIImage imageNamed:@"color6DB200Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 2:
            return [[UIImage imageNamed:@"color5D9900Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 3:
            return [[UIImage imageNamed:@"color4D7F00Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 4:
            return [[UIImage imageNamed:@"color3E6600Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 5:
            return [[UIImage imageNamed:@"color2E4C00Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 6:
            return [[UIImage imageNamed:@"color1F3300Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        default:
            return [[UIImage imageNamed:@"color1F3300Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
    }
}



@end
