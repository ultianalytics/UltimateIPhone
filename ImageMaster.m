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
static UIImage* maleImage = nil;
static UIImage* femaleImage = nil;
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
    unknownImage = [UIImage imageNamed:@"hearts.png"];
//    maleImage = [UIImage imageNamed:@"man.png"];
//    femaleImage = [UIImage imageNamed:@"woman.png"];
    maleImage = [UIImage imageNamed:@"big_smile.png"];
    femaleImage = [UIImage imageNamed:@"girl.png"];
}

+ (UIImage*) getImageForEvent: (Event*) event {
    if ((![event isOffense]) && event.action == Goal) {
        return [ImageMaster getTheirGoalImage];  
    } else if ((![event isOffense]) && event.action == Throwaway) {
        return [ImageMaster getOpponentThrowawayImage];  
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
        case Pull:
            return [ImageMaster getPullImage];
        case PullOb:
            return [ImageMaster getPullObImage];
        case De:
            return [ImageMaster getDeImage];             
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

+(UIImage*)getUnknownImage {
    return unknownImage;
}
+(UIImage*)getMaleImage {
    return maleImage;
}
+(UIImage*)getFemaleImage {
    return femaleImage;
}

@end
