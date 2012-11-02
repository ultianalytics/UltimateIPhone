//
//  UPoint.h
//  Ultimate
//
//  Created by Jim Geppert
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event;
@class PointSummary;

#define kEventsKey      @"events"
#define kLineKey        @"line"
#define kStartTimeKey   @"startSeconds"
#define kEndTimeKey     @"endSeconds"

@interface UPoint : NSObject {
    
}
@property (nonatomic, strong) NSMutableArray* events;
@property (nonatomic, strong) NSArray* line;
@property (nonatomic) int timeStartedSeconds; // since epoch
@property (nonatomic) int timeEndedSeconds; // since epoch
@property (nonatomic, strong) PointSummary* summary;  // transient!
@property (nonatomic, strong) NSArray* playerSubstitutions;

+ (UPoint*) fromDictionary:(NSDictionary*) dict;

-(NSArray*)getEvents;
-(void)addEvent: (Event*) event;
-(Event*)getEventAtMostRecentIndex: (int) index;
-(Event*)getLastEvent;
-(NSEnumerator*)getLastEvents: (int) number;
-(void)removeLastEvent;
-(BOOL)isFinished;
-(BOOL)isOurPoint;
-(int)getNumberOfEvents;
-(NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub;

@end
