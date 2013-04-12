//
//  TimeoutDetails.m
//  UltimateIPhone
//
//  Created by james on 4/11/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "TimeoutDetails.h"
#import "NSDictionary+JSON.h"

#define kTimeoutQuotaPerHalf @"quotaPerHalf"
#define kTimeoutQuotaFloaters @"quotaFloaters"
#define kTimeoutTakenFirstHalf @"takenFirstHalf"
#define kTimeoutTakenSecondHalf @"takenSecondHalf"

@implementation TimeoutDetails

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.quotaPerHalf = [decoder decodeIntForKey:kTimeoutQuotaPerHalf];
        self.quotaFloaters = [decoder decodeIntForKey:kTimeoutQuotaFloaters];
        self.takenFirstHalf = [decoder decodeIntForKey:kTimeoutTakenFirstHalf];
        self.takenSecondHalf = [decoder decodeIntForKey:kTimeoutTakenSecondHalf];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.quotaPerHalf forKey:kTimeoutQuotaPerHalf];
    [encoder encodeInt:self.quotaFloaters forKey:kTimeoutQuotaFloaters];
    [encoder encodeInt:self.takenFirstHalf forKey:kTimeoutTakenFirstHalf];
    [encoder encodeInt:self.takenSecondHalf forKey:kTimeoutTakenSecondHalf];
}

+(TimeoutDetails*)fromDictionary:(NSDictionary*) dict {
    TimeoutDetails* timeoutDetails = [[TimeoutDetails alloc] init];
    timeoutDetails.quotaPerHalf = [dict intForJsonProperty:kTimeoutQuotaPerHalf defaultValue:0];
    timeoutDetails.quotaFloaters = [dict intForJsonProperty:kTimeoutQuotaFloaters defaultValue:0];
    timeoutDetails.takenFirstHalf = [dict intForJsonProperty:kTimeoutTakenFirstHalf defaultValue:0];
    timeoutDetails.takenSecondHalf = [dict intForJsonProperty:kTimeoutTakenSecondHalf defaultValue:0];
    return timeoutDetails;
}

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: [NSNumber numberWithInt:self.quotaPerHalf ] forKey:kTimeoutQuotaPerHalf];
    [dict setValue: [NSNumber numberWithInt:self.quotaFloaters ] forKey:kTimeoutQuotaFloaters];
    [dict setValue: [NSNumber numberWithInt:self.takenFirstHalf ] forKey:kTimeoutTakenFirstHalf];
    [dict setValue: [NSNumber numberWithInt:self.takenSecondHalf ] forKey:kTimeoutTakenSecondHalf];
    return dict;
}

@end
