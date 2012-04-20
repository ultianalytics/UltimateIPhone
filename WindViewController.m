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

@implementation WindViewController
@synthesize game,playStartSideSegmentedControl,directionView,directionSwipeView,directionArrowView,askWeatherServiceButton,speedSlider,speedLabel;

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
    //NSURL *url = [NSURL URLWithString:@"http://i.wund.com/cgi-bin/findweather/getForecast?brand=iphone&query=44.935760553650894,-93.1225314237645"];
    NSURL *url = [NSURL URLWithString:@"http://i.wund.com"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)windDirectionSwipe:(UISwipeGestureRecognizer *)recognizer 
{ 
    WindDirectionSwipeRecognizer* swipeRecognizer = (WindDirectionSwipeRecognizer*)recognizer;
    self.game.wind.directionDegrees = [swipeRecognizer getDegrees];
    //NSLog(@"Swipe - degrees %d", wind.directionDegrees);
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
    int speedValue = speedSlider.value;
    self.game.wind.mph = speedValue; 
    [self populateSpeedLabel];
}

-(IBAction)speedSliderChangeEnded: (id)sender {
    [self saveChanges];
}

-(void)populateSpeedLabel {
    speedSlider.value = self.game.wind.mph;
    speedLabel.text = [NSString stringWithFormat:@"%d", self.game.wind.mph];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
