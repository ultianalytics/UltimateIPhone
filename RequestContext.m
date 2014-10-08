//
//  RequestContext.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/15/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "RequestContext.h"
#import "CloudMetaInfo.h"


#define kCloudErrorExplanationKey @"CloudErrorExplanation"

@interface RequestContext() 

@property (nonatomic) int error;

@end

@implementation RequestContext
@synthesize error, errorExplanation;

@synthesize requestData, responseData;


- (id)initWithReqData:(id) aRequestData responseData: (id)aResponseData errorCode: (int) errorCode { 
    self = [super init];
    if (self) {
        self.requestData = aRequestData;
        self.responseData = aResponseData;
        self.error = errorCode;
    }
    return self;
}

- (id)initWithReqData:(id) aRequestData responseData: (id)aResponseData error: (NSError *) requestError { 
    self = [super init];
    if (self) {
        self.requestData = aRequestData;
        self.responseData = aResponseData;
        self.error = (int)requestError.code;
        self.errorExplanation = [requestError.userInfo objectForKey:kCloudErrorExplanationKey];
    }
    return self;
}

- (id)initWithReqData:(id) aRequestData responseData: (id)aResponseData { 
    self = [super init];
    if (self) {
        self.requestData = aRequestData;
        self.responseData = aResponseData;
        self.error = -1;
    }
    return self;
}

- (id)initWithReqErrorCode: (int) errorCode { 
    self = [super init];
    if (self) {
        [self setErrorCode:errorCode];
    }
    return self;
}


- (id)initWithReqError: (NSError *) requestError {
    self = [self initWithReqErrorCode: (int)requestError.code];
    if (self) {
        self.errorExplanation = [requestError.userInfo objectForKey:kCloudErrorExplanationKey];
    }
    return self;
}



-(void)setErrorCode: (int) code {
    self.error = code;
}

-(int)getErrorCode {
    return [self hasError] ? self.error : -1;
}

-(BOOL)hasError {
    return self.error != -1;
}

- (NSString* )description {
    return [NSString stringWithFormat:@"RequestContext hasError=%@ errorCode=%d requestData=%@, responseData=%@", [self hasError] ? @"true" : @"false", [self getErrorCode], self.requestData, self.responseData];
}


@end
