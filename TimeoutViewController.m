//
//  TimeoutViewController.m
//  UltimateIPhone
//
//  Created by james on 4/10/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "TimeoutViewController.h"
#import "UltimateSegmentedControl.h"
#import "DarkButton.h"
#import "RedButton.h"
#import "UILabel+Utilities.h"
#import "Game.h"
#import "TimeoutDetails.h"
#import "Preferences.h"

@interface TimeoutViewController ()
@property (strong, nonatomic) IBOutlet UltimateSegmentedControl *quotaPerHalfSegmentedControl;
@property (strong, nonatomic) IBOutlet UltimateSegmentedControl *quotaFloatersSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *takenFirstHalf;
@property (strong, nonatomic) IBOutlet UILabel *takenSecondHalf;
@property (strong, nonatomic) IBOutlet UILabel *availableNow;
@property (strong, nonatomic) IBOutlet UILabel *availableNowLabel;
@property (strong, nonatomic) IBOutlet UILabel *takenFirstHalfLabel;
@property (strong, nonatomic) IBOutlet UILabel *takenSecondHalfLabel;
@property (strong, nonatomic) IBOutlet DarkButton *timeoutButton;
@property (strong, nonatomic) IBOutlet RedButton *undoButton;

@property (strong, nonatomic) TimeoutDetails* timeoutDetails;

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
    [self populateView];
}

-(void)populateView {
    if (!self.game.timeoutDetails) {
        self.timeoutDetails = [[TimeoutDetails alloc] init];
        self.timeoutDetails.quotaPerHalf = [Preferences getCurrentPreferences].timeoutsPerHalf;
        self.timeoutDetails.quotaFloaters = [Preferences getCurrentPreferences].timeoutFloaters;
        [self saveTimeoutDetails];
    } else {
        self.timeoutDetails = self.game.timeoutDetails;
    }
    BOOL hasGameStarted = [self.game hasEvents];
    BOOL is2ndHalf = [self.game isAfterHalftime];
    self.quotaPerHalfSegmentedControl.selectedSegmentIndex = self.timeoutDetails.quotaPerHalf;
    self.quotaFloatersSegmentedControl.selectedSegmentIndex = self.timeoutDetails.quotaFloaters;
    self.takenFirstHalf.text = [NSString stringWithFormat:@"%d", self.timeoutDetails.takenFirstHalf];
    self.takenSecondHalf.text = [NSString stringWithFormat:@"%d", self.timeoutDetails.takenSecondHalf];
    self.takenFirstHalfLabel.font = is2ndHalf ? [UIFont systemFontOfSize:17] : [UIFont boldSystemFontOfSize:17];
    self.takenSecondHalfLabel.font = is2ndHalf ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17];
    self.availableNow.text = [NSString stringWithFormat:@"%d", self.game.availableTimeouts];
    self.availableNow.textColor = self.game.availableTimeouts > 0 ? [UIColor whiteColor] : [UIColor redColor];
    self.availableNow.hidden = !hasGameStarted;
    self.availableNowLabel.hidden = self.availableNow.hidden;
    self.timeoutButton.hidden = !(hasGameStarted && (self.game.availableTimeouts > 0));
    if ([self.game isAfterHalftime]) {
        self.undoButton.hidden = !(self.timeoutDetails.takenSecondHalf > 0);
    } else {
        self.undoButton.hidden = !(self.timeoutDetails.takenFirstHalf > 0);
    }
    
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
    [self setAvailableNowLabel:nil];
    [self setTakenFirstHalfLabel:nil];
    [self setTakenSecondHalfLabel:nil];
    [super viewDidUnload];
}

- (IBAction)quotaPerHalfChanged:(id)sender {
    self.timeoutDetails.quotaPerHalf = self.quotaPerHalfSegmentedControl.selectedSegmentIndex;
    [self populateView];
    [self saveTimeoutDetails];
    [Preferences getCurrentPreferences].timeoutsPerHalf = self.timeoutDetails.quotaPerHalf;
    [[Preferences getCurrentPreferences] save];
}

- (IBAction)floatersChanged:(id)sender {
    self.timeoutDetails.quotaFloaters = self.quotaFloatersSegmentedControl.selectedSegmentIndex;
    [self populateView];
    [self saveTimeoutDetails];
    [Preferences getCurrentPreferences].timeoutFloaters = self.timeoutDetails.quotaFloaters;
    [[Preferences getCurrentPreferences] save];
}

- (IBAction)timeoutButtonTapped:(id)sender {
    if ([self.game isAfterHalftime]) {
        self.timeoutDetails.takenSecondHalf = self.timeoutDetails.takenSecondHalf + 1;
    } else {
        self.timeoutDetails.takenFirstHalf = self.timeoutDetails.takenFirstHalf + 1;
    }
    [self populateView];
    [self saveTimeoutDetails];
}

- (IBAction)undoButtonTapped:(id)sender {
    if ([self.game isAfterHalftime]) {
        self.timeoutDetails.takenSecondHalf = self.timeoutDetails.takenSecondHalf - 1;
    } else {
        self.timeoutDetails.takenFirstHalf = self.timeoutDetails.takenFirstHalf - 1;
    }
    [self populateView];
    [self saveTimeoutDetails];
}

-(void)saveTimeoutDetails {
    self.game.timeoutDetails = self.timeoutDetails;
    [self.game save];
}

@end
