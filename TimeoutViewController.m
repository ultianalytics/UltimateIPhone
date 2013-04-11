//
//  TimeoutViewController.m
//  UltimateIPhone
//
//  Created by james on 4/10/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "TimeoutViewController.h"
#import "UltimateSegmentedControl.h"
#import "StandardButton.h"
#import "RedButton.h"

@interface TimeoutViewController ()
@property (strong, nonatomic) IBOutlet UltimateSegmentedControl *quotaPerHalfSegmentedControl;
@property (strong, nonatomic) IBOutlet UltimateSegmentedControl *quotaFloatersSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *takenFirstHalf;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *takenSecondHalf;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *availableNow;
@property (strong, nonatomic) IBOutlet StandardButton *timeoutButton;
@property (strong, nonatomic) IBOutlet RedButton *undoButton;

@end

@implementation TimeoutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
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
    [self setQuotaPerHalfSegmentedControl:nil];
    [self setQuotaFloatersSegmentedControl:nil];
    [self setTakenFirstHalf:nil];
    [self setTakenSecondHalf:nil];
    [self setAvailableNow:nil];
    [self setTimeoutButton:nil];
    [self setUndoButton:nil];
    [super viewDidUnload];
}

- (IBAction)quotaPerHalfChanged:(id)sender {
    
}

- (IBAction)floatersChanged:(id)sender {
    
}

- (IBAction)timeoutButtonTapped:(id)sender {
    
}

- (IBAction)undoButtonTapped:(id)sender {
    
}

@end
