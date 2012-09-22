//
//  LeaguevineClient.h
//  UltimateIPhone
//
//  Created by Jim on 9/19/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LeaguevineInvokeOK,
    LeaguevineTooManyResults,
    LeaguevineInvokeCredentialsRejected,
    LeaguevineInvokeNetworkError,
    LeaguevineInvokeInvalidResponse,
} LeaguevineInvokeStatus;

@interface LeaguevineClient : NSObject

-(void)retrieveLeagues:(void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;

@end
