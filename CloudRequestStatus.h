//
//  CloudRequestStatus.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/30/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CloudRequestStatusCodeOk,
    CloudRequestStatusCodeUnauthorized,
    CloudRequestStatusCodeNotConnectedToInternet,
    CloudRequestStatusCodeMarshallingError,
    CloudRequestStatusCodeUnacceptableAppVersion,
    CloudRequestStatusCodeUnknownError
} CloudRequestStatusCode;

@interface CloudRequestStatus : NSObject

@property (nonatomic) CloudRequestStatusCode code;
@property (nonatomic) NSString* explanation;
@property (nonatomic, readonly) BOOL ok;

+(CloudRequestStatus*) status: (CloudRequestStatusCode) code;
+(NSString*) statusCodeDescripton: (CloudRequestStatusCode) status;

@end
