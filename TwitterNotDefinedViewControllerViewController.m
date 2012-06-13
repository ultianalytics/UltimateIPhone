//
//  TwitterNotDefinedViewControllerViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 6/13/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "TwitterNotDefinedViewControllerViewController.h"
#import "Tweeter.h"

#define kMaxWaitSeconds 5

@interface TwitterNotDefinedViewControllerViewController ()

@property (nonatomic, strong) UIAlertView* busyView;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation TwitterNotDefinedViewControllerViewController
@synthesize messageLabel;
@synthesize busyView, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    self.busyView = nil;
    self.messageLabel = nil;
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(verifyAccount)
                                                 name: @"UIApplicationWillEnterForegroundNotification"
                                               object: nil];
    [self verifyAccount];
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super viewWillDisappear: animated];
}

-(void)verifyAccount {
    self.messageLabel.hidden = YES;
    [self verifyAccount:[NSDate date]];
}
    
-(void)verifyAccount: (NSDate *) beginVerifyTime {
    BOOL isVerified = [[Tweeter getCurrent] doesTwitterAccountExist];
    NSTimeInterval elapsedTimeSeconds = [beginVerifyTime timeIntervalSinceNow] * -1;
    if (!isVerified && (elapsedTimeSeconds < kMaxWaitSeconds)) {
        [self startBusyDialog];
        [self performSelector:@selector(verifyAccount:) withObject:beginVerifyTime afterDelay:2];
    } else {
        [self stopBusyDialog];
        if (isVerified) {
            [self.delegate accountVerified: self];
        } else {
            self.messageLabel.hidden = NO;
        }
    }
}

-(void)startBusyDialog {
    if (!busyView) {
        busyView = [[UIAlertView alloc] initWithTitle: @"Checking Twitter iPhone account settings..."
                                              message: nil
                                             delegate: self
                                    cancelButtonTitle: nil
                                    otherButtonTitles: nil];
        // Add a spinner
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.frame = CGRectMake(50,60, 200, 50);
        [busyView addSubview:spinner];
        [spinner startAnimating];
        
        [busyView show];
    }
}

-(void)stopBusyDialog {
    if (busyView) {
        [busyView dismissWithClickedButtonIndex:0 animated:NO];
        [busyView removeFromSuperview];
        busyView = nil;
    }
}

@end
