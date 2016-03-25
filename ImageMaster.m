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
static UIImage* penaltyImage = nil;
static UIImage* stallImage = nil;
static UIImage* defenseThrowawayImage = nil;
static UIImage* pullImage = nil;
static UIImage* pullObImage = nil;
static UIImage* deImage = nil;
static UIImage* ourCallahanImage = nil;
static UIImage* theirCallahanImage = nil;

static UIImage* opponentPullImage = nil;
static UIImage* opponentPullObImage = nil;
static UIImage* opponentCatchImage = nil;
static UIImage* pullBeginImage = nil;
static UIImage* pickupDiskImage = nil;

static UIImage* maleImage = nil;
static UIImage* femaleImage = nil;
static UIImage* neutralGenderImage = nil;
static UIImage* neutralGenderAbsentImage = nil;
static UIImage* cessationImage = nil;
static UIImage* gameoverImage = nil;
static UIImage* unknownImage = nil;


+ (void) initialize {
    catchImage = [UIImage imageNamed:@"Event-catch"];
    dropImage = [UIImage imageNamed:@"Event-drop"];
    ourGoalImage = [UIImage imageNamed:@"Event-goal"];
    theirGoalImage = [UIImage imageNamed:@"Event-goal-opponent"];
    offenseThrowawayImage = [UIImage imageNamed:@"Event-throwaway"];
    defenseThrowawayImage = [UIImage imageNamed:@"Event-throwaway"];
    stallImage = [UIImage imageNamed:@"Event-stall"];
    penaltyImage = [UIImage imageNamed:@"Event-penalty"];
    pullImage = [UIImage imageNamed:@"Event-pull"];
    pullObImage = [UIImage imageNamed:@"Event-pull-ob"];
    deImage = [UIImage imageNamed:@"Event-d"];
    ourCallahanImage = [UIImage imageNamed:@"Event-callhan"];
    theirCallahanImage = [UIImage imageNamed:@"Event-callahan-opponent"];
    opponentPullImage = [UIImage imageNamed:@"Event-pull"];
    opponentPullObImage = [UIImage imageNamed:@"Event-pull-ob"];
    opponentCatchImage = [UIImage imageNamed:@"Event-catch"];
    pullBeginImage = [UIImage imageNamed:@"Event-pull-begin"];
    pickupDiskImage = [UIImage imageNamed:@"Event-pickup"];
    unknownImage = [UIImage imageNamed:@"Event-unkown"];
    maleImage = [UIImage imageNamed:@"769-male.png"];
    femaleImage = [UIImage imageNamed:@"768-female.png"];
    neutralGenderImage = [UIImage imageNamed:@"player_passing.png"];
    neutralGenderAbsentImage = [UIImage imageNamed:@"player_passing_absent.png"];
    cessationImage = [UIImage imageNamed:@"Event-period-end"];
    gameoverImage = [UIImage imageNamed:@"Event-game-over"];
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
            return [ImageMaster getStallImage];
        case MiscPenalty:
            return [ImageMaster getPenaltyImage];
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
        case OpponentCatch:
            return [ImageMaster getOpponentCatchImage];
        case OpponentPull:
            return [ImageMaster getOpponentPullImage];
        case OpponentPullOb:
            return [ImageMaster getOpponentPullOBImage];
        case PickupDisc:
            return [ImageMaster getPickupDiscImage];
        case PullBegin:
            return [ImageMaster getPullBeginImage];
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

+(UIImage*)getStallImage {
    return stallImage;
}

+(UIImage*)getPenaltyImage {
    return penaltyImage;
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

+(UIImage*)getOpponentPullImage {
    return opponentPullImage;
}

+(UIImage*)getOpponentPullOBImage {
    return opponentPullObImage;
}

+(UIImage*)getOpponentCatchImage {
    return opponentCatchImage;
}

+(UIImage*)getPullBeginImage {
    return pullBeginImage;
}

+(UIImage*)getPickupDiscImage {
    return pickupDiskImage;
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

+(UIImage*)getNeutralGenderAbsentImage {
    return neutralGenderAbsentImage;
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
            return [[UIImage imageNamed:@"color4D7F00Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 1:
            return [[UIImage imageNamed:@"color4D7F00Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 2:
            return [[UIImage imageNamed:@"color3E6600Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 3:
            return [[UIImage imageNamed:@"color3E6600Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 4:
            return [[UIImage imageNamed:@"color2E4C00Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 5:
            return [[UIImage imageNamed:@"color2E4C00Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 6:
            return [[UIImage imageNamed:@"color1F3300Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        case 7:
            return [[UIImage imageNamed:@"color1F3300Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
        default:
            return [[UIImage imageNamed:@"color1F3300Radius3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            break;
    }
}



@end
