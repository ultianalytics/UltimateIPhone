//
//  UPoint.h
//  Ultimate
//
//  Created by james on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "PointSummary.h"

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
-(NSDictionary*) asDictionary;

@end
