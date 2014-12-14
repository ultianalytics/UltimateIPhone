//
//  WindViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WindViewController.h"
#import "WindDirectionSwipeRecognizer.h"
#import "ColorMaster.h"
#import "Game.h"
#import "ArrowView.h"
#import "Wind.h"
#import "WindSpeedClient.h"
#import "UIView+Toast.h"

@interface WindViewController () <WindSpeedClientDelegate>

@property (nonatomic, strong) IBOutlet UISegmentedControl* playStartSideSegmentedControl;
@property (nonatomic, strong) IBOutlet UIView* directionView;
@property (nonatomic, strong) IBOutlet UIView* directionSwipeView;  // transparent view on top of other view to enlarge swipe zone
@property (nonatomic, strong) IBOutlet ArrowView* directionArrowView;
@property (nonatomic, strong) IBOutlet UIButton* askWeatherServiceButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* busyIndicator;
@property (nonatomic, retain) IBOutlet UISlider* speedSlider;
@property (nonatomic, retain) IBOutlet UILabel* speedLabel;

@end

@implementation WindViewController

-(void)populateViewFromModel {
    [self populateSpeedLabel];
    self.playStartSideSegmentedControl.selectedSegmentIndex = self.game.wind.isFirstPullLeftToRight ? 0 : 1;
    self.directionArrowView.degrees = self.game.wind.directionDegrees;
}

-(IBAction)startDirectionChanged:(id)sender {
    self.game.wind.isFirstPullLeftToRight = self.playStartSideSegmentedControl.selectedSegmentIndex == 0; 
    [self saveChanges];
}

-(IBAction)askWeatherStationClicked:(id)sender {
    [self updateWindSpeedFromService];
}

- (void)windDirectionSwipe:(UISwipeGestureRecognizer *)recognizer 
{ 
    WindDirectionSwipeRecognizer* swipeRecognizer = (WindDirectionSwipeRecognizer*)recognizer;
    self.game.wind.directionDegrees = [swipeRecognizer getDegrees];
    self.directionArrowView.degrees = self.game.wind.directionDegrees;
    [self.directionArrowView setNeedsDisplay];
    [self saveChanges];
}

-(void)saveChanges {
    if ([self.game hasBeenSaved]) {
        [self.game save];  
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


-(IBAction)speedSliderChanged: (id)sender {
    int speedValue = self.speedSlider.value;
    self.game.wind.mph = speedValue; 
    [self populateSpeedLabel];
}

-(IBAction)speedSliderChangeEnded: (id)sender {
    [self saveChanges];
}

-(void)populateSpeedLabel {
    self.speedSlider.value = self.game.wind.mph;
    self.speedLabel.text = [NSString stringWithFormat:@"%d", self.game.wind.mph];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Wind", @"Wind");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.busyIndicator.hidden = YES;
    
    WindDirectionSwipeRecognizer* swipeRecognizer = 
        [[WindDirectionSwipeRecognizer alloc] initWithTarget:self action:@selector(windDirectionSwipe:)];
    [swipeRecognizer setDirection: UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown];
    [self.directionSwipeView addGestureRecognizer:swipeRecognizer];
    
    swipeRecognizer = [[WindDirectionSwipeRecognizer alloc] initWithTarget:self action:@selector(windDirectionSwipe:)];
    [swipeRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight];
    [self.directionSwipeView addGestureRecognizer:swipeRecognizer];
    
    [self populateViewFromModel];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -  Wind Speed Updating

-(void)updateWindSpeedFromService {
    [WindSpeedClient shared].delegate = self;
    self.busyIndicator.hidden = NO;
    [[WindSpeedClient shared] updateWindSpeed];
}

#pragma mark -  WindSpeedClientDelegate

-(void)windSpeedUpdateAttempted {
    [WindSpeedClient shared].delegate = nil;
    self.busyIndicator.hidden = YES;
    if ([[WindSpeedClient shared] hasWindSpeedBeenUpdatedRecently]) {
        self.game.wind.mph = [WindSpeedClient shared].lastWindSpeedMph;
        [self populateSpeedLabel];
        [UIView transitionWithView:self.speedLabel duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
            
        } completion:nil];
        [self.view makeToast:@"Wind speed updated from weather service"
                             duration:2.0
                             position:@"center"];
    } else {
        NSString* explanation = [[WindSpeedClient shared] isGeoLocationEnabled] ? @"We could not determine windspeed.  Perhaps you are not connected?" : @"It appears you did not enable location detection for this app.  You can re-enable this by going to iOS settings for this app and changing the Location setting.";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Wind Speed Error"
                              message: explanation
                              delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    }
}
@end
