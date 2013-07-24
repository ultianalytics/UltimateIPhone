//
//  WebViewSignonController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 7/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WebViewSignonController.h"
#import "ColorMaster.h"
#import "CloudClient.h"
#import "Reachability.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "Preferences.h"
#import "NSString+manipulations.h"

@interface WebViewSignonController ()

@property (nonatomic, strong) CalloutsContainerView *usageCallouts;
@property (nonatomic) BOOL hasDisplayedUsageCallouts;

@end

@implementation WebViewSignonController
@synthesize delegate;
@synthesize containerView;
@synthesize webView;
@synthesize coverView;
@synthesize navigationBar;
@synthesize cancelButton;
@synthesize busyLabel;

@synthesize usageCallouts;
@synthesize hasDisplayedUsageCallouts;

#pragma mark - Signon

-(void)loadAccessCheckPage {
    NSString* relativeUrl = [NSString stringWithFormat:@"%@?redirect=true&cache-buster=%ld", [self accessCheckPageUrl], (long)[NSDate timeIntervalSinceReferenceDate]];
    NSURL* url = [NSURL URLWithString:relativeUrl relativeToURL:[NSURL URLWithString:[CloudClient getBaseUrl]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(NSString*)accessCheckPageUrl {
    return @"access-test.jsp";
}

- (void)accessPageLoaded {
    NSLog(@"access page loaded");
    NSString* email = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('email').value"];
    [self.delegate dismissSignonController:YES email:email];
}

#pragma mark - WebView delegate 

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    NSURLRequest* finishedRequest = webView.request;
    NSLog(@"finished loading URL %@", finishedRequest.URL);
    [self showWebView]; 
    if([finishedRequest.URL.lastPathComponent isEqualToString:[self accessCheckPageUrl]]) {
        [self accessPageLoaded];
    }
}

#pragma mark - Initialization 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        busyLabel.textColor = [UIColor whiteColor];
        busyLabel.shadowColor = [UIColor blackColor];
        busyLabel.shadowOffset = CGSizeMake(0, 1);
    }
    return self;
}

-(void)initializeCancelButton {
    self.cancelButton.target = self;
    self.cancelButton.action = @selector(cancelButtonTapped);
}

#pragma mark - Event handling

-(void)cancelButtonTapped {
    [self.delegate dismissSignonController:NO email: nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.delegate dismissSignonController:NO email:nil];
}

#pragma mark - Help Callouts
   

-(BOOL)showNewLogonUsageCallouts {
    if (!self.hasDisplayedUsageCallouts && ![[Preferences getCurrentPreferences].userid isNotEmpty]) {
        self.hasDisplayedUsageCallouts = YES;
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGPoint anchor = [self.webView convertPoint:CGPointTop(self.webView.bounds) toView:self.view];
        
        CalloutView* callout = [calloutsView addCallout:@"This app uses Google App Engine™ to store your team data so you must signon to a Google account (Gmail™) before uploading or downloading.\n\nNOTE: If you will be sharing upload/download duties with other people it is suggested you create and use a separate Gmail™ account for this app.\n\n              - Tap to dismiss -" anchor: anchor width: 270 degrees: 180 connectorLength: 200 font: [UIFont systemFontOfSize:16]];  
        
        // customize callout...
        UITextView *calloutTextView = [[UITextView alloc] init];
        calloutTextView.textColor = [UIColor whiteColor];
        calloutTextView.font = [UIFont systemFontOfSize:16]; 
        calloutTextView.backgroundColor = [ColorMaster getSegmentControlLightTintColor];
        callout.textView = calloutTextView;
        
        self.usageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
        return YES;
    } else {
        return NO;
    }
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
                    completion:NULL];
    [self showNewLogonUsageCallouts];
}

-(BOOL)isNetworkAvailable {
    if (![CloudClient isConnected]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: @"No Internet Access"
                              message: @"We are not able to connect to Google.  Please make sure you have Internet access."
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
        return NO;
    } else {
        return YES;
    }
}
  
       
#pragma mark - Lifecycle 

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeCancelButton];
    self.title = NSLocalizedString(@"Cloud Signon", @"Cloud Signon"); 
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self isNetworkAvailable]) {
        [self loadAccessCheckPage];
    }
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setCancelButton:nil];
    [self setNavigationBar:nil];
    [self setCoverView:nil];
    [self setBusyLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
