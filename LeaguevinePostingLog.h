//
//  LeaguevinePostingLog.h
//  UltimateIPhone
//
//  Created by james on 3/31/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event, LeaguevineEvent;

@interface LeaguevinePostingLog : NSObject

-(void)logLeaguevineEvent: (LeaguevineEvent*)event;
-(NSUInteger)leaguevineEventIdForTimestamp: (NSTimeInterval)eventTimestamp;

@end
