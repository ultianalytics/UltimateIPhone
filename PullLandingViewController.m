//
//  PullLandingViewController.m
//  UltimateIPhone
//
//  Created by james on 10/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "PullLandingViewController.h"
#import "ColorMaster.h"

@interface PullLandingViewController ()

@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setStartLabel:nil];
    [self setEndLabel:nil];
    [super viewDidUnload];
}

#pragma mark Event handling

- (IBAction)landedButtonTapped:(id)sender {
    if (self.completion) {
        self.completion(NO, NO);
    }
}

- (IBAction)outOfBoundsTapped:(id)sender {
    if (self.completion) {
        self.completion(NO, YES);
    }
}

- (IBAction)cancelTapped:(id)sender {
    if (self.completion) {
        self.completion(YES, NO);
    }
}

#pragma mark Miscellaneous 

-(void)stylize {
    [ColorMaster styleAsWhiteLabel:self.startLabel size:18];
    [ColorMaster styleAsWhiteLabel:self.endLabel size:18];
}

@end
