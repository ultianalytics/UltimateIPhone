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
#import "UPoint.h"
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

@property (strong, nonatomic) UIImage* playImage;
@property (strong, nonatomic) UIImage* pauseImage;

@property (strong, nonatomic) UPoint* currentPoint;
@property (strong, nonatomic) Event* currentEvent;  // curent is the last event played

@property (nonatomic) BOOL isPlaying;

// indexes are just used for positioning the game progress slider
@property (nonatomic) int currentPointIndex;
@property (nonatomic) int currentEventIndex;

@end

@implementation GamePlaybackViewController

#pragma mark - Lifecycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Game Playback";
    self.playImage = [UIImage imageNamed:@"play"];
    self.pauseImage = [UIImage imageNamed:@"pause"];
    self.fieldView.displayCompletionBlock = ^{
        [self updateControls];
    };
    [self updateControls];
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
    [self playNextEvent];
}

- (IBAction)fastForwardButtonTapped:(id)sender {
    
}

- (IBAction)playbackSpeedChanged:(id)sender {
    
}

- (IBAction)tracerCheckboxTapped:(id)sender {
    
}

- (IBAction)continuousCheckboxTapped:(id)sender {
    
}

#pragma mark - Playing events

-(void) playNextEvent {
    Event* lastEvent = self.currentEvent;
    UPoint* lastPoint = self.currentPoint;
    [self moveCurrentEventForward];
    if (lastEvent == nil || lastEvent != self.currentEvent) {
        if (lastPoint == nil || lastPoint != self.currentPoint) {
            [self.fieldView resetField];
        }
        [self.fieldView displayNewEvent:self.currentEvent];
    }
}


-(void) moveCurrentEventForward {
    if (!self.currentPoint) {
        [self moveCurrentPointForward];
    } else {
        BOOL nextEventInCurrentPoint = NO;
        for (int i = 0; i < [self.currentPoint.events count] - 1; i++) {  // not including the last event in iteration
            Event* event = self.currentPoint.events[i];
            if (event == self.currentEvent) {
                self.currentEvent = self.currentPoint.events[i + 1];
                nextEventInCurrentPoint = YES;
                break;
            }
        }
        if (!nextEventInCurrentPoint) {
            [self moveCurrentPointForward];
        }
    }
}

-(void) moveCurrentEventBackward {
    if (!self.currentPoint) {
        [self moveCurrentPointBackward];
    } else {
        BOOL nextEventInCurrentPoint = NO;
        for (int i = 1; i < [self.currentPoint.events count]; i++) {  // not including the first event in iteration
            Event* event = self.currentPoint.events[i];
            if (event == self.currentEvent) {
                self.currentEvent = self.currentPoint.events[i - 1];
                nextEventInCurrentPoint = YES;
                break;
            }
        }
        if (!nextEventInCurrentPoint) {
            [self moveCurrentPointBackward];
        }
    }
}

-(void) moveCurrentPointForward {
    if (self.currentPoint) {
        for (int i = 0; i < [self.game.points count] - 1; i++) {  // not including the last point in iteration
            UPoint* point = self.game.points[i];
            if (point == self.currentPoint) {
                self.currentPoint = self.game.points[i + 1];
                if ([self.currentPoint.events count] > 0) {
                    self.currentEvent = self.currentPoint.events[0];
                }
                break;
            }
        }
    } else {
        self.currentPoint = self.game.points[0];
        self.currentEvent = self.currentPoint.events[0];
    }
}

-(void) moveCurrentPointBackward {
    if (self.currentPoint) {
        for (int i = 1; i < [self.game.points count]; i++) {  // not including first point in iteration
            UPoint* point = self.game.points[i];
            if (point == self.currentPoint){
                self.currentPoint = self.game.points[i - 1];
                if ([self.currentPoint.events count] > 0) {
                    self.currentEvent = self.currentPoint.events[0];
                }
                break;
            }
        }
    } else {
        self.currentPoint = self.game.points[0];
        self.currentEvent = self.currentPoint.events[0];
    }
}

#pragma mark - Controls updating

-(void)updateControls {
    [self updateGameProgressSlider];
    [self updateContolButtons];
    // todo: checkboxes
}

-(void)updateGameProgressSlider {
    // update the slider to show game progess.  Each point is an equal increment in progress
    if ([self numberOfPoints] > 0) {
        // start at beginning of current point
        float gameProgressPercent = (float)self.currentPointIndex / (float)[self numberOfPoints];
        float numberOfEvents = [self.currentPoint getNumberOfEvents];
        // add events played in this point
        if (numberOfEvents > 0) {
            float percentPerPoint = 1.f / (float)numberOfEvents;
            float relativeEventPercent = (float)self.currentEventIndex / (float)numberOfEvents;
            gameProgressPercent += (relativeEventPercent * percentPerPoint);
        }
        self.gameProgressSlider.value = gameProgressPercent;
    } else {
        self.gameProgressSlider.value = 0;
    }
}

-(void)updateContolButtons {
    [self.playButton setImage: self.isPlaying ? self.pauseImage : self.playImage forState:UIControlStateNormal];
    BOOL isFirstPoint = self.currentPointIndex == 0;
    BOOL isLastPoint = self.currentPointIndex == [self numberOfPoints] - 1;
    self.fastBackwardButton.enabled = !isFirstPoint;
    self.fastForwardButton.enabled = !isLastPoint;
    // todo enable/disable forward/backward
}

#pragma mark - Misc

-(void)setGame:(Game *)game {
    _game = game;
    self.currentPoint = nil;
    
}

-(void)setCurrentPoint:(UPoint *)currentPoint {
    if (currentPoint == nil || currentPoint != _currentPoint) {
        self.currentEvent = nil;
    }
    _currentPoint = currentPoint;
    self.currentPointIndex = 0;
    if (currentPoint) {
        int index = 0;
        for (UPoint* point in self.game.points) {
            if (point == currentPoint) {
                self.currentPointIndex = index;
                break;
            }
            index++;
        }
    }
}

-(void)setCurrentEvent:(Event *)currentEvent {
    _currentEvent = currentEvent;
    self.currentEventIndex = 0;
    if (currentEvent) {
        int index = 0;
        for (Event* event in self.currentPoint.events) {
            if (event == currentEvent) {
                self.currentEventIndex = index;
                break;
            }
            index++;
        }
    }
}

-(int)numberOfPoints {
    return [self.game getNumberOfPoints];
}




@end
