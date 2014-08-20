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

#define kPromptConfirmUndo 1
#define kPromptForWhichHalfUndo 2
#define kPromptForWhichHalfApplyDuringHalf 3

@interface TimeoutViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UltimateSegmentedControl *quotaPerHalfSegmentedControl;
@property (strong, nonatomic) IBOutlet UltimateSegmentedControl *quotaFloatersSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *takenFirstHalf;
@property (strong, nonatomic) IBOutlet UILabel *takenSecondHalf;
@property (strong, nonatomic) IBOutlet UILabel *availableNow;
@property (strong, nonatomic) IBOutlet UILabel *takenFirstHalfLabel;
@property (strong, nonatomic) IBOutlet UILabel *takenSecondHalfLabel;
@property (strong, nonatomic) IBOutlet UIView *actionView;
@property (strong, nonatomic) IBOutlet UIView *timeoutButtonView;
@property (strong, nonatomic) IBOutlet UIView *undoButtonView;

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
    self.title = @"Team Timeouts";
    if (IS_IPAD && self.modalMode) {
        UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelModalDialog)];
        self.navigationItem.rightBarButtonItem = cancelBarItem;
    }
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
    self.takenSecondHalfLabel.font = is2ndHalf ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17];
    self.availableNow.text = [NSString stringWithFormat:@"%d", self.game.availableTimeouts];
    self.availableNow.textColor = self.game.availableTimeouts > 0 ? [UIColor blackColor] : [UIColor redColor];
    
    // hide stuff that is not applicable
    self.actionView.hidden = !hasGameStarted;
    self.timeoutButtonView.hidden = !(self.game.availableTimeouts > 0) && hasGameStarted;
    self.undoButtonView.hidden = !(self.timeoutDetails.takenFirstHalf > 0 || self.timeoutDetails.takenSecondHalf > 0);
    self.takenSecondHalf.hidden = !is2ndHalf;
    self.takenSecondHalfLabel.hidden = self.takenSecondHalf.hidden;
}


- (IBAction)quotaPerHalfChanged:(id)sender {
    self.timeoutDetails.quotaPerHalf = (int)self.quotaPerHalfSegmentedControl.selectedSegmentIndex;
    [self populateView];
    [self saveTimeoutDetails];
    [Preferences getCurrentPreferences].timeoutsPerHalf = self.timeoutDetails.quotaPerHalf;
    [[Preferences getCurrentPreferences] save];
}

- (IBAction)floatersChanged:(id)sender {
    self.timeoutDetails.quotaFloaters = (int)self.quotaFloatersSegmentedControl.selectedSegmentIndex;
    [self populateView];
    [self saveTimeoutDetails];
    [Preferences getCurrentPreferences].timeoutFloaters = self.timeoutDetails.quotaFloaters;
    [[Preferences getCurrentPreferences] save];
}

- (IBAction)timeoutButtonTapped:(id)sender {
    if ([self.game isHalftime]) {
        [self promptForApplyDuringHalf];
    } else if ([self.game isAfterHalftimeStarted]) {
        self.timeoutDetails.takenSecondHalf = self.timeoutDetails.takenSecondHalf + 1;
    } else {
        self.timeoutDetails.takenFirstHalf = self.timeoutDetails.takenFirstHalf + 1;
    }
    [self populateView];
    [self saveTimeoutDetails];
}

- (IBAction)undoButtonTapped:(id)sender {
    if ([self.game isAfterHalftime]) {
        if (self.timeoutDetails.takenFirstHalf > 0 && self.timeoutDetails.takenSecondHalf) {
            [self promptForWhichHalfForUndo];
        } else {
            [self promptForFirstUndoConfirm];
        }
    } else {
        [self promptForFirstUndoConfirm];
    }
    [self populateView];
    [self saveTimeoutDetails];
}

-(void)saveTimeoutDetails {
    self.game.timeoutDetails = self.timeoutDetails;
    if ([self.game hasBeenSaved]) {
        [self.game save];
    }
}

#pragma Prompting

-(void)promptForWhichHalfForUndo {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Timeout Undo"
                          message:@"From which half should we undo a timeout?"
                          delegate:self
                          cancelButtonTitle:@"Nevermind"
                          otherButtonTitles:@"2nd Half", @"1st Half", nil];
    alert.tag = kPromptForWhichHalfUndo;
    [alert show];
}

-(void)promptForFirstUndoConfirm {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Timeout Undo"
                          message:@"Are you sure you want to undo the last timeout?"
                          delegate:self
                          cancelButtonTitle:@"No...nevermind"
                          otherButtonTitles:@"Yes", nil];
    alert.tag = kPromptConfirmUndo;
    [alert show];
}

-(void)promptForApplyDuringHalf {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Timeout During Halftime"
                          message:@"We are at halftime. To which half should timeout be applied?"
                          delegate:self
                          cancelButtonTitle:@"Nevermind"
                          otherButtonTitles:@"2nd Half", @"1st Half", nil];
    alert.tag = kPromptForWhichHalfApplyDuringHalf;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kPromptConfirmUndo) {
        if (buttonIndex == 1) {
            if (self.timeoutDetails.takenFirstHalf > 0) {
                self.timeoutDetails.takenFirstHalf = self.timeoutDetails.takenFirstHalf - 1;
            } else {
                self.timeoutDetails.takenSecondHalf = self.timeoutDetails.takenSecondHalf - 1;
            }
        }
    } else if (alertView.tag == kPromptForWhichHalfUndo) {
        if (buttonIndex == 1) {
            self.timeoutDetails.takenSecondHalf = self.timeoutDetails.takenSecondHalf - 1;
        } else if (buttonIndex == 2) {
            self.timeoutDetails.takenFirstHalf = self.timeoutDetails.takenFirstHalf - 1;
        }
    } else if (alertView.tag == kPromptForWhichHalfApplyDuringHalf) {
        if (buttonIndex == 1) {
            self.timeoutDetails.takenSecondHalf = self.timeoutDetails.takenSecondHalf + 1;
        } else if (buttonIndex == 2) {
            self.timeoutDetails.takenFirstHalf = self.timeoutDetails.takenFirstHalf + 1;
        }
    }
    [self saveTimeoutDetails];
    [self populateView];
}

-(void)cancelModalDialog {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


@end
