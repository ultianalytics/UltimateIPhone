//
//  PointSummary.m
//  Ultimate
//
//  Created by Jim Geppert on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PointSummary.h"

@implementation PointSummary
@synthesize score,isOline,previousPoint,isFinished,isAfterHalftime,elapsedSeconds;

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: self.isOline ? @"O" : @"D" forKey:kLineTypeProperty];
    [dict setValue: [NSNumber numberWithBool:self.isFinished] forKey:kIsFinishedProperty];
    [dict setValue: [NSNumber numberWithInt:self.elapsedSeconds ] forKey:kElapsedTimeProperty];
    
    NSMutableDictionary* scoreDict = [[NSMutableDictionary alloc] init];
    [dict setValue: scoreDict forKey:kScoreProperty];
    [scoreDict setValue: [NSNumber numberWithInt:self.score.ours ] forKey:kScoreOursProperty];
    [scoreDict setValue: [NSNumber numberWithInt:self.score.theirs ] forKey:kScoreTheirsProperty];
    
    return dict;
}
- (NSString*)description {
    return [NSString stringWithFormat:@"score: ours=%d, theirs=%d isOline=%@ isFinished=%@ isAfterHalftime=%@, elapsedSeconds=%d",
        score.ours, score.theirs, (isOline ? @"YES" : @"NO"), (isFinished ? @"YES" : @"NO"), (isAfterHalftime ? @"YES" : @"NO"), elapsedSeconds];
}

@end
