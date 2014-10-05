//
//  Authenticator.m
//  IOSoAuth2Tester
//
//  Created by Jim Geppert on 9/27/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GoogleOAuth2Authenticator.h"
#import "Preferences.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"

static NSString *const kKeychainItemName = @"com.summithillsoftware.UltimateIPhone";
static NSString *const kGoogleClientID = @"308589977906-jcsohi4nbdq3rf6ls8qph3n9mtm0u9ce.apps.googleusercontent.com";  // from https://console.developers.google.com/project
static NSString *const kGoogleClientSecret = @"4YzUz4OwNQXJ-pVyTeRAMWcV";  // from https://console.developers.google.com/project
static NSString *const kGoogleAppScope = @"https://www.googleapis.com/auth/userinfo.email"; // NOTE:  This must match the scope used on the server (a parameter when requesting the User object from the oauth service)

@interface GoogleOAuth2Authenticator ()

@property (strong, nonatomic) void (^signonViewControllerCompletion)(SignonStatus signStatus);
@property (strong, nonatomic) GTMOAuth2Authentication* currentAuthentication;

@end


@implementation GoogleOAuth2Authenticator

+ (GoogleOAuth2Authenticator*)sharedAuthenticator {
    
    static GoogleOAuth2Authenticator *sharedAuthenticator;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        sharedAuthenticator = [[GoogleOAuth2Authenticator alloc] init];
        if (!sharedAuthenticator) {
            sharedAuthenticator = [[self alloc] init];
        }
    });
    return sharedAuthenticator;
}

-(BOOL)hasBeenAuthenticated {
    return [Preferences getCurrentPreferences].userid != nil && [self getCurrentAuth];
    
}

-(void)signInUsingNavigationController: (UINavigationController*)navController completion: (void (^)(SignonStatus signonStatus)) completionBlock {
    self.signonViewControllerCompletion = completionBlock;
    [self signOut];
    
    // create the oAuth controller that will do the signon
    GTMOAuth2ViewControllerTouch* authViewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kGoogleAppScope
                                                                                                clientID:kGoogleClientID
                                                                                            clientSecret:kGoogleClientSecret
                                                                                        keychainItemName:kKeychainItemName
                                                                                                delegate:self
                                                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    // We can set a URL for deleting the cookies after sign-in so the next time
    // the user signs in, the browser does not assume the user is already signed in
    authViewController.browserCookiesURL = [NSURL URLWithString:@"http://www.ultanalytics.com"];
    
    // Optional: display some html briefly before the sign-in page loads
    NSString *html = @"<html><body bgcolor=white><div align=center style=\"font-family: Arial, Helvetica, sans-serif;\">Waiting for Google...</div></body></html>";
    authViewController.initialHTMLString = html;
    
    // Change back button text to "Cancel"
    navController.topViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    // Now push our sign-in view
    [navController pushViewController:authViewController animated:YES];
    
}

- (void)signOut {
    GTMOAuth2Authentication* auth =  [self getCurrentAuth];
    if (auth) {
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:auth];
        // remove the stored Google authentication from the keychain, if any
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    }
    [Preferences getCurrentPreferences].userid = nil;
    [Preferences getCurrentPreferences].accessToken = nil;
    [[Preferences getCurrentPreferences] save];
}


-(GTMOAuth2Authentication*)getCurrentAuth {
    if (!self.currentAuthentication) {
        GTMOAuth2Authentication* auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                              clientID:kGoogleClientID
                                                                                          clientSecret:kGoogleClientSecret];
        auth.accessToken = [Preferences getCurrentPreferences].accessToken;
        self.currentAuthentication = auth;
    }
    return self.currentAuthentication;
}

- (void)authorizeRequest:(NSMutableURLRequest *)request completionHandler:(void (^)(AuthenticationStatus status))handler {
    if ([self hasBeenAuthenticated]) {
        dispatch_async(dispatch_get_main_queue(), ^{  // google's code gets hung if not started from the main thread
            [[self getCurrentAuth] authorizeRequest:request completionHandler:^(NSError *error) {
                [Preferences getCurrentPreferences].accessToken = [self getCurrentAuth].accessToken;
                [[Preferences getCurrentPreferences] save];
                AuthenticationStatus status = error == nil ? AuthenticationStatusOk : AuthenticationStatusNeedSignon;
                handler(status);
            }];
        });
    } else {
        handler(AuthenticationStatusNeedSignon);
    }
}

-(BOOL)authorizeRequest:(NSMutableURLRequest *)request {
    if ([self hasBeenAuthenticated]) {
        return [[self getCurrentAuth] authorizeRequest:request];
    } else {
        return NO;
    }
}

#pragma mark - GTMOAuth2ViewControllerTouch delegate

- (void)viewController:(GTMOAuth2ViewControllerTouch *)authViewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    SignonStatus status = SignonStatusOk;
    if (error) {
        if (error.code == kGTMOAuth2ErrorWindowClosed) {  // user cancelled
            status = SignonStatusUserCancel;
            SHSLog(@"user cancelled signon");
        } else {
            status = SignonStatusError;
            SHSLog(@"error attempting to signon = %@", error);
        }
    } else {
        // The auth data is stored in the keychain by google's authViewController...we don't need to do more to save it
        
        // We also want to remember the user's e-mail so we can tell them who is signed on.
        /* Per Google's doc:
         By default, the controller will fetch the user's email, but not the rest of
         the user's profile.  The full profile can be requested from Google's server
         by setting this property before sign-in:
         
         authViewController.signIn.shouldFetchGoogleUserProfile = YES;
         
         The profile will be available after sign-in as
         
         NSDictionary *profile = authViewController.signIn.userProfile;
         
         */
        NSString* email = authViewController.signIn.userProfile[@"email"];
        [Preferences getCurrentPreferences].userid = email;
        // the google signon does not seem to set the accessToken in the auth object so we need to save it ourselves and
        // insert it in the auth object later (neeeded for doing synchronous request authorizations)
        [Preferences getCurrentPreferences].accessToken = auth.accessToken;
        [[Preferences getCurrentPreferences] save];
        
        self.currentAuthentication = auth;
        
        SHSLog(@"authentication complete for user %@.  expire is %@.  Now is %@", email, auth.expirationDate, [NSDate date]);
        
        if (self.signonViewControllerCompletion) {
            self.signonViewControllerCompletion(SignonStatusOk);
        }
    }
    
    
}

@end
