//
//  GoogleOAuth2Authenticator.h
//  IOSoAuth2Tester
//
//  Created by Jim Geppert on 9/27/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    SignonStatusOk,
    SignonStatusError,
    SignonStatusUserCancel
} SignonStatus;

typedef enum {
    AuthenticationStatusOk,
    AuthenticationStatusNeedSignon
} AuthenticationStatus;

@interface GoogleOAuth2Authenticator : NSObject

+(GoogleOAuth2Authenticator*)sharedAuthenticator;

-(BOOL)hasBeenAuthenticated;
-(void)signInUsingNavigationController: (UINavigationController*)navController completion: (void (^)(SignonStatus signonStatus)) completionBlock;
-(void)signOut;
-(void)forceExpiration;

// Asynch authorizing: This method will refresh an expired token
-(void)authorizeRequest:(NSMutableURLRequest *)request completionHandler:(void (^)(AuthenticationStatus status))handler;

// Synchronous entry point; This method will NOT refresh an expired token
-(BOOL)authorizeRequest:(NSMutableURLRequest *)request;

-(void)applicationStarted;

@end
