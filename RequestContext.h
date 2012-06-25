//
//  RequestContext.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/15/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestContext : NSObject {
}

@property (nonatomic, strong) id requestData;
@property (nonatomic, strong) id responseData;
@property (nonatomic, strong) NSString *errorExplanation;

-(void)setErrorCode: (int) code;
-(int)getErrorCode;
-(BOOL)hasError;

- (id)initWithReqData:(id) aRequestData responseData: (id)aResponseData errorCode: (int) errorCode;
- (id)initWithReqData:(id) aRequestData responseData: (id)aResponseData error: (NSError *) requestError;
- (id)initWithReqData:(id) aRequestData responseData: (id)aResponseData;
- (id)initWithReqErrorCode: (int) errorCode;
- (id)initWithReqError: (NSError *) error;

@end
