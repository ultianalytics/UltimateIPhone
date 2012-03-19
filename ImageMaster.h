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
+(UIImage*)getPullImage;
+(UIImage*)getDeImage;
+(UIImage*)getMaleImage;
+(UIImage*)getFemaleImage;
+(UIImage*)getUnknownImage;

@end
