//
//  UniqueTimestampGenerator.m
//  UltimateIPhone
//
//  Created by james on 3/30/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "UniqueTimestampGenerator.h"


@interface UniqueTimestampGenerator()

@property (nonatomic) NSTimeInterval lastEventTimeIntervalSinceReferenceDateSeconds;

@end


@implementation UniqueTimestampGenerator

+ (UniqueTimestampGenerator*)sharedGenerator {
    
    static UniqueTimestampGenerator *sharedUniqueTimestampGenerator;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        sharedUniqueTimestampGenerator = [[self alloc] init];
    });
    return sharedUniqueTimestampGenerator;
}


-(NSTimeInterval)uniqueTimeIntervalSinceReferenceDateSeconds {
    NSTimeInterval newTimestamp = MAX(ceil([NSDate timeIntervalSinceReferenceDate]),self.lastEventTimeIntervalSinceReferenceDateSeconds);
    while (newTimestamp == self.lastEventTimeIntervalSinceReferenceDateSeconds) {
        newTimestamp = newTimestamp + 2;  // increment by 2 so that insertions can be made for special events
    }
    self.lastEventTimeIntervalSinceReferenceDateSeconds = newTimestamp;
    return newTimestamp;
}


@end
