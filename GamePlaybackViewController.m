//
//  GamePlaybackViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/11/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GamePlaybackViewController.h"
#import "Game.h"
#import "Team.h"
#import "Event.h"
#import "GamePlaybackFieldView.h"

@interface GamePlaybackViewController ()

@property (weak, nonatomic) IBOutlet GamePlaybackFieldView *fieldView;
@property (weak, nonatomic) IBOutlet UISlider *gameProgressSlider;
@property (weak, nonatomic) IBOutlet UIButton *backwardButton;
@property (weak, nonatomic) IBOutlet UIButton *fastBackwardButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *fastForwardButton;
@property (weak, nonatomic) IBOutlet UISlider *playbackSpeedSlider;
@property (weak, nonatomic) IBOutlet UIButton *tracerCheckbox;
@property (weak, nonatomic) IBOutlet UIButton *continuousCheckbox;

@end

@implementation GamePlaybackViewController

#pragma mark - Lifecycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Game Playback";
}

#pragma mark - Event Handling

- (IBAction)gameSliderChanged:(id)sender {
    
}

- (IBAction)backwardButtonTapped:(id)sender {
    
}

- (IBAction)fastBackwardButtonTapped:(id)sender {
    
}

- (IBAction)playButtonTapped:(id)sender {
    
}

- (IBAction)fowardButtonTapped:(id)sender {
    
}

- (IBAction)fastForwardButtonTapped:(id)sender {
    
}

- (IBAction)playbackSpeedChanged:(id)sender {
    
}

- (IBAction)tracerCheckboxTapped:(id)sender {
    
}

- (IBAction)continuousCheckboxTapped:(id)sender {
    
}

@end
