//
//  PointSummary.h
//  Ultimate
//
//  Created by Jim Geppert on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UPoint;

#define kLineTypeProperty       @"lineType"
#define kScoreProperty          @"score"
#define kScoreOursProperty      @"ours"
#define kScoreTheirsProperty    @"theirs"
#define kIsFinishedProperty     @"finished"
#define kElapsedTimeProperty    @"elapsedTime"

@interface PointSummary : NSObject

@property (nonatomic) Score score;
@property (nonatomic) BOOL isOline;
@property (nonatomic) BOOL isFinished;
@property (nonatomic) BOOL isAfterHalftime;
@property (nonatomic) long elapsedSeconds;
@property (nonatomic, strong) UPoint* previousPoint;

-(NSDictionary*) asDictionary;

@end
