//
//  CloudRequestStatus.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/30/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "CloudRequestStatus.h"

@interface CloudRequestStatus ()

@end

@implementation CloudRequestStatus
@dynamic ok;

+(CloudRequestStatus*) status: (CloudRequestStatusCode) code {
    CloudRequestStatus* status = [[CloudRequestStatus alloc] init];
    status.code = code;
    return status;
}

-(BOOL)ok {
    return self.code == CloudRequestStatusCodeOk;
}

@end
