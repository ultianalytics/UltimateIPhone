//
//  LeagueVineSignonViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LeagueVineSignonViewController.h" 
#import "ColorMaster.h"
#import "CloudClient.h"
#import "Reachability.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "Preferences.h"
#import "NSString+manipulations.h"
#import "NSString+manipulations.h"

#define REGISTERED_REDIRECT_URI @"http://www.ultimate-numbers.com/leaguevine-redirect.jsp"

@interface LeagueVineSignonViewController ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIView *coverView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UILabel *busyLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *webBusySpinner;

@property (nonatomic, strong) CalloutsContainerView *usageCallouts;
@property (nonatomic) BOOL hasDisplayedUsageCallouts;

@end

@implementation LeagueVineSignonViewController


#pragma mark - Signon

-(void)loadSignonPage {
    NSString* encodedRedirectUrl = [REGISTERED_REDIRECT_URI stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    NSString* baseUrl = [NSString stringWithFormat: @"https://www.leaguevine.com/oauth2/authorize/?client_id=462902f75595b99b55bf9cbe5d2821&response_type=token&redirect_uri=%@&scope=universal", encodedRedirectUrl];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&cache-buster=%ld", baseUrl, (long)[NSDate timeIntervalSinceReferenceDate]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)signonComplete {
    SHSLog(@"signon redirect complete");
    //NSString* email = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('email').value"];
    self.finishedBlock(YES,self);
}

#pragma mark - WebView delegate 

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showWebBusySpinner:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showWebBusySpinner:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    [self showWebBusySpinner:NO];
/*
     If the user logs in successfully, they will be redirected to:
     
     YOUR_REGISTERED_REDIRECT_URI#access_token=ACCESS_TOKEN
     &token_type=bearer
     &expires_in=157680000
     &scope=universal
*/
     
    NSURLRequest* finishedRequest = self.webView.request;
    SHSLog(@"finished loading URL %@", finishedRequest.URL);
    [self showWebView]; 
    if([finishedRequest.URL.absoluteString hasPrefix:REGISTERED_REDIRECT_URI]) {
        NSString* otherInfo = [finishedRequest.URL.absoluteString substringFromIndex:REGISTERED_REDIRECT_URI.length];
        if ([otherInfo rangeOfString:@"error_description"].location != NSNotFound) {
            if ([otherInfo rangeOfString:@"access_denied"].location != NSNotFound) {
                self.finishedBlock(NO,self);
            } else {
               [self showAlert:@"Leaguevine Error" message: @"Unexpected Error trying to communicate with Leaguevine.com"];
            }
        } else if ([otherInfo rangeOfString:@"access_token"].location != NSNotFound) {
            NSDictionary* queryStringParams = [otherInfo toQueryStringParamaters];
            NSString* token = [queryStringParams valueForKey:@"access_token"];
            if ([token isNotEmpty]) {
                NSString* tokenType = [queryStringParams valueForKey:@"token_type"];
                NSString* expiresIn = [queryStringParams valueForKey:@"expires_in"];
                NSString* scope = [queryStringParams valueForKey:@"scope"];
                SHSLog(@"Logged into Leaguevine.  token_type is %@ expires_in %@ scope is %@", tokenType, expiresIn, scope);
                [Preferences getCurrentPreferences].leaguevineToken = token;
                [[Preferences getCurrentPreferences] save];
                [self signonComplete];
            } else {
                [self showAlert:@"Leaguevine Error" message: @"Unexpected Error trying to communicate with Leaguevine.com"];
                self.finishedBlock(NO,self);
            }
        } else {
            [self signonComplete];
        }
    }
}

#pragma mark - Initialization 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.busyLabel.textColor = [UIColor whiteColor];
        self.busyLabel.shadowColor = [UIColor blackColor];
        self.busyLabel.shadowOffset = CGSizeMake(0, 1);
    }
    return self;
}

#pragma mark - Event handling

-(void)cancelButtonTapped {
    self.finishedBlock(NO,self);
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.finishedBlock(NO,self);
}


#pragma mark - Miscellaneous 

-(void)showWebView {
    [UIView transitionWithView:self.containerView
                      duration:0.6
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ 
                        [self.coverView removeFromSuperview]; 
                        [self.containerView addSubview:self.webView]; 
                    }
                    completion:^(BOOL finished) {
                        self.coverView = nil;
                    }];
}

-(BOOL)isNetworkAvailable {
    if (![CloudClient isConnected]) {
        [self showAlert:@"No Internet Access" message: @"We are not able to connect to Leaguevine.com.  Please make sure you have Internet access."];
        return NO;
    } else {
        return YES;
    }
}

-(void)showAlert:(NSString*) title message: (NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc]
                      initWithTitle: title
                      message: message
                      delegate: nil
                      cancelButtonTitle: NSLocalizedString(@"OK",nil)
                      otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Leaguevine Signon", @"Leaguevine Signon");
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTapped)];
    self.navigationItem.leftBarButtonItem = cancelBarItem;
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self isNetworkAvailable]) {
        [self loadSignonPage];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Help Callouts


-(BOOL)showNewLogonUsageCallouts {
    // TODO: this is using the cloud userid to decide if initial signon...need to change that technique if you use callout
    if (!self.hasDisplayedUsageCallouts && ![[Preferences getCurrentPreferences].userid isNotEmpty]) {
        self.hasDisplayedUsageCallouts = YES;
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGPoint anchor = [self.webView convertPoint:CGPointTop(self.webView.bounds) toView:self.view];
        
        [calloutsView addCallout:@"blah, blah, blah" anchor: anchor width: 270 degrees: 180 connectorLength: 200 font: [UIFont systemFontOfSize:14]];
        
        self.usageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - Misc

-(void)showWebBusySpinner: (BOOL)show {
    BOOL shouldDisplay = show && !self.coverView;
    self.webBusySpinner.hidden = !shouldDisplay;
    if (shouldDisplay) {
        [self.containerView bringSubviewToFront: self.webBusySpinner];
        [self.webBusySpinner startAnimating];
    } else {
        [self.webBusySpinner stopAnimating];
    }
}

@end
