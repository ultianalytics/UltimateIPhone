//
//  ImageMaster.h
//  Ultimate
//
//  Created by james on 1/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface ImageMaster : NSObject

+(UIImage*)getImageForEvent: (Event*) event;
+(UIImage*)getCatchImage;
+(UIImage*)getDropImage;
+(UIImage*)getOurGoalImage;
+(UIImage*)getTheirGoalImage;
+(UIImage*)getThrowawayImage;
+(UIImage*)getOpponentThrowawayImage;
+(UIImage*)getPullImage;
+(UIImage*)getPullObImage;
+(UIImage*)getDeImage;
+(UIImage*)getOurCallahanImage;
+(UIImage*)getTheirCallahanImage;
+(UIImage*)getMaleImage;
+(UIImage*)getFemaleImage;
+(UIImage*)getNeutralGenderImage;
+(UIImage*)getNeutralGenderAbsentImage;
+(UIImage*)getUnknownImage;
+(UIImage*)stretchableWhite100Radius3;
+(UIImage*)stretchableWhite200Radius3;
+(UIImage*)stretchableImageForPlayingTimeFactor: (int)factor;

@end
