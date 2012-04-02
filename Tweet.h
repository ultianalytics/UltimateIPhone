//
//  Tweet.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ACAccount;
typedef enum {
    TweetQueued,
    TweetSent,
    TweetFailed,
    TweetIgnored
} TweetStatus;

@interface Tweet : NSObject

@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* undoMessage;
@property (nonatomic) TweetStatus status;
@property (nonatomic, strong) NSString* error;
@property (nonatomic) double time;

-(id) initMessage: (NSString*) aMessage type: (NSString*)type;
-(id) initMessage: (NSString*) aMessage;
-(id) initMessage: (NSString*) aMessage status: (TweetStatus)status;
-(id) initMessage: (NSString*) aMessage failed: (NSString*)error;

@end
