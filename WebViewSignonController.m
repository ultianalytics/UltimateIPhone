//
//  WebViewSignonController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 7/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "WebViewSignonController.h"
#import "ColorMaster.h"
#import "CloudClient.h"
#import "Reachability.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"

#define kIsNotFirstSignonViewUsage @"IsNotFirstSignonViewUsage"

@interface WebViewSignonController ()

@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;

@end

@implementation WebViewSignonController
@synthesize delegate;
@synthesize containerView;
@synthesize webView;
@synthesize coverView;
@synthesize navigationBar;
@synthesize cancelButton;
@synthesize busyLabel;

@synthesize firstTimeUsageCallouts;

#pragma mark - Signon

-(void)loadAccessCheckPage {
    NSString* relativeUrl = [NSString stringWithFormat:@"%@?redirect=true", [self accessCheckPageUrl]];
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
   

-(BOOL)showFirstTimeUsageCallouts {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kIsNotFirstSignonViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstSignonViewUsage];
        
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGPoint anchor = [self.webView convertPoint:CGPointTop(self.webView.bounds) toView:self.view];
        
        [calloutsView addCallout:@"This app uses Google App Engine™ to store your team data so you must signon to Google (e.g., Gmail™ account) before uploading or downloading.\n\nNOTE: If you will be sharing upload/download duties with other people it is suggested you create and use a separate Gmail™ account." anchor: anchor width: 270 degrees: 200 connectorLength: 160 font: [UIFont systemFontOfSize:16]];    
        
        self.firstTimeUsageCallouts = calloutsView;
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
    self.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    self.title = NSLocalizedString(@"Cloud Signon", @"Cloud Signon"); 
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self isNetworkAvailable]) {
        [self showFirstTimeUsageCallouts];
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

@end
