//
//  RequestContext.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/15/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestContext : NSObject {
    @private
    int error;
}

@property (nonatomic, strong) id requestData;
@property (nonatomic, strong) id responseData;

-(void)setErrorCode: (int) code;
-(int)getErrorCode;
-(BOOL)hasError;

- (id)initWithRequestData:(id) aRequestData responseData: (id)aResponseData error: (int) errorCode;
- (id)initWithRequestData:(id) aRequestData responseData: (id)aResponseData;
- (id)initWithRequestError: (int) errorCode;

@end
