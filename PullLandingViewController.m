//
//  PullLandingViewController.m
//  UltimateIPhone
//
//  Created by james on 10/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "PullLandingViewController.h"
#import "ColorMaster.h"
#import "DefenseEvent.h"
#import <QuartzCore/QuartzCore.h>

@interface PullLandingViewController ()

@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;
@property (strong, nonatomic) IBOutlet UIView *hangtimeView;
@property (strong, nonatomic) IBOutlet UIView *waitingView;
@property (strong, nonatomic) IBOutlet UILabel *hangtimeValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *hangtimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *landedButton;
@property (strong, nonatomic) IBOutlet UIButton *landedNoHangButton;
@property (strong, nonatomic) IBOutlet UIButton *obButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic) int hangtimeMillis;

@end

@implementation PullLandingViewController

#pragma mark Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stylize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark Event handling

- (IBAction)landedButtonTapped:(id)sender {
    double currentTime = CACurrentMediaTime();
    self.hangtimeMillis = (currentTime - self.pullBeginTime) * 1000;
    if (self.hangtimeMillis < 0 || self.hangtimeMillis > 300000) { // handle user responding after to much time has passed
        self.hangtimeMillis = 0;
        [self notifyPullComplete];
    } else {
        self.hangtimeValueLabel.text = [NSString stringWithFormat:@"%@ seconds", [DefenseEvent formatHangtime:self.hangtimeMillis]];
        [UIView transitionFromView:self.waitingView toView:self.hangtimeView duration:.5 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            [NSTimer scheduledTimerWithTimeInterval:1.1 target:self selector:@selector(notifyPullComplete) userInfo:nil repeats:NO];
        }];
    }
}

- (IBAction)landedDoNotTimeTapped:(id)sender {
    self.hangtimeMillis = 0;
    [self notifyPullComplete];
}

- (void)notifyPullComplete {
    if (self.completion) {
        self.completion(NO, NO, self.hangtimeMillis);
    }
}

- (IBAction)outOfBoundsTapped:(id)sender {
    if (self.completion) {
        self.completion(NO, YES, 0);
    }
}

- (IBAction)cancelTapped:(id)sender {
    if (self.completion) {
        self.completion(YES, NO, 0);
    }
}

#pragma mark Miscellaneous 

-(void)stylize {

    self.landedNoHangButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:@"Caught/Landed\n(no hang time)"];
    // set attributes for entire string
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrStr.length)];
    // smaller font for 2nd line
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(14, 14)];
    [self.landedNoHangButton setAttributedTitle:attrStr forState:UIControlStateNormal];

}

@end
