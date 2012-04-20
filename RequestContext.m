//
//  RequestContext.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/15/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "RequestContext.h"

@implementation RequestContext
@synthesize requestData, responseData;


- (id)initWithRequestData:(id) aRequestData responseData: (id)aResponseData error: (int) errorCode { 
    self = [super init];
    if (self) {
        requestData = aRequestData;
        responseData = aResponseData;
        error = errorCode;
    }
    return self;
}

- (id)initWithRequestData:(id) aRequestData responseData: (id)aResponseData { 
    self = [super init];
    if (self) {
        requestData = aRequestData;
        responseData = aResponseData;
        error = -1;
    }
    return self;
}

- (id)initWithRequestError: (int) errorCode { 
    self = [super init];
    if (self) {
        [self setErrorCode:errorCode];
    }
    return self;
}

-(void)setErrorCode: (int) code {
    error = code;
}

-(int)getErrorCode {
    return [self hasError] ? error : -1;
}

-(BOOL)hasError {
    return error != -1;
}

- (NSString* )description {
    return [NSString stringWithFormat:@"RequestContext hasError=%@ errorCode=%d requestData=%@, responseData=%@", [self hasError] ? @"true" : @"false", [self getErrorCode], self.requestData, self.responseData];
}


@end
