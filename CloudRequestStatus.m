//
//  CloudRequestStatus.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/30/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "CloudRequestStatus.h"

@interface CloudRequestStatus ()

@property (strong, nonatomic) NSDate* timestamp;

@end

@implementation CloudRequestStatus
@dynamic ok;

+(CloudRequestStatus*) status: (CloudRequestStatusCode) code {
    CloudRequestStatus* status = [[CloudRequestStatus alloc] init];
    status.code = code;
    return status;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timestamp = [NSDate date];
    }
    return self;
}

-(BOOL)ok {
    return self.code == CloudRequestStatusCodeOk;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"CloudRequestStatus: %@", [[self class] statusCodeDescripton: self.code]];
}

+(NSString*) statusCodeDescripton: (CloudRequestStatusCode) status {
    switch (status) {
        case CloudRequestStatusCodeOk:
            return @"OK";
            break;
        case CloudRequestStatusCodeUnauthorized:
            return @"Unauthorized";
            break;
        case CloudRequestStatusCodeNotConnectedToInternet:
            return @"NotConnectedToInternet";
            break;
        case CloudRequestStatusCodeMarshallingError:
            return @"MarshallingError";
            break;
        case CloudRequestStatusCodeUnacceptableAppVersion:
            return @"UnacceptableAppVersion";
            break;
        case CloudRequestStatusCodeUnknownError:
            return @"UnknownError";
            break;
        default:
            return @"UNKNOWN STATUS";
            break;
    }
}

@end
