//
//  SHSAnalytics.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/10/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//


#define kFlurryAppId 

#import "SHSAnalytics.h"
#import "Flurry.h"

/*
 
    NOTE:  Flurry must be called on Main Thread!
 
*/

@interface SHSAnalytics()

@property (nonatomic, strong) NSMutableSet* currentGameEvents;

@end


@implementation SHSAnalytics

+ (SHSAnalytics*)sharedAnalytics {
    
    static SHSAnalytics *sharedAnalytics;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        if (!sharedAnalytics) {
            sharedAnalytics = [[self alloc] init];
        }
    });
    return sharedAnalytics;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentGameEvents = [NSMutableSet set];
    }
    return self;
}

-(void)initializeAnalytics {
    
    //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
    [Flurry setCrashReportingEnabled:YES];
    
    // Replace YOUR_API_KEY with the api key in the downloaded package
    [Flurry startSession:@"NY7WRUDU774YNR26GQZ9"];
}

-(void)logGameStart {
    [self.currentGameEvents removeAllObjects];
    [self logEvent:kAnalyticsGameStart];
}

-(void)logEvent: (NSString*)eventName ifFirstForGame: (BOOL)onlyLogIfFirstForCurrentGame {
    if (onlyLogIfFirstForCurrentGame) {
        @synchronized(self.currentGameEvents) {
            if (![self.currentGameEvents containsObject:eventName]) {
                [self.currentGameEvents addObject:eventName];
                [self logEvent:eventName];
            } 
        }
    } else {
        [self logEvent:eventName];
    }
}

-(void)logEvent: (NSString*)eventName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Flurry logEvent:eventName];
    });
}

-(void)logEvent: (NSString*)eventName withParameters: (NSDictionary*)eventParameters {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Flurry logEvent:eventName withParameters:eventParameters];
    });
}

@end
