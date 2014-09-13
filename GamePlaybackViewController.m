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

#define kNormalDelayBetweenEvents 1
#define kProgressSliderAnimationDuration .5

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

@property (strong, nonatomic) UIImage* playImage;
@property (strong, nonatomic) UIImage* pauseImage;
@property (strong, nonatomic) UIImage* checkboxCheckedImage;
@property (strong, nonatomic) UIImage* checkboxUnCheckedImage;

@property (strong, nonatomic) UPoint* currentPoint;
@property (strong, nonatomic) Event* currentEvent;  // curent is the last event played

@property (nonatomic) BOOL isPlaying;

// indexes are just used for positioning the game progress slider
@property (nonatomic) int currentPointIndex;
@property (nonatomic) int currentEventIndex; // 0 implies no event

@end

@implementation GamePlaybackViewController

#pragma mark - Lifecycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Game Playback";
    self.playImage = [UIImage imageNamed:@"play"];
    self.pauseImage = [UIImage imageNamed:@"pause"];
    self.checkboxCheckedImage = [UIImage imageNamed:@"checkbox-checked-white-border.png"];
    self.checkboxUnCheckedImage = [UIImage imageNamed:@"checkbox-unchecked-white-border.png"];
    self.fieldView.tracerArrowsHidden = NO;
    [self updateControls];
}

#pragma mark - Event Handling

- (IBAction)gameSliderChanged:(id)sender {
    
}

- (IBAction)backwardButtonTapped:(id)sender {
    [self moveCurrentEventBackward];
    [self displayCurrentEvent];
    [self updateControls];
}

- (IBAction)fastBackwardButtonTapped:(id)sender {
    [self moveCurrentPointBackward];
    self.currentEvent = nil;  // move to the FIRST event of the point
    [self displayCurrentEvent];
    [self updateControls];
}

- (IBAction)playButtonTapped:(id)sender {
    self.isPlaying = !self.isPlaying;
    [self updateControls];
    if (self.isPlaying) {
        [self playNextEvent];
    }
}

- (IBAction)fowardButtonTapped:(id)sender {
    [self playNextEvent];
}

- (IBAction)fastForwardButtonTapped:(id)sender {
    [self moveCurrentPointForward];
    [self displayCurrentEvent];
    [self updateControls];
}


- (IBAction)tracerCheckboxTapped:(id)sender {
    self.fieldView.tracerArrowsHidden = !self.fieldView.tracerArrowsHidden;
    [self updateTracerArrowCheckbox];
}


#pragma mark - Playing events

-(void)handleNewEventDisplayComplete {
    [self updateControls];
    if (self.isPlaying) {
        if (!([self.game getLastEvent] == self.currentEvent)) {
            [self performSelector:@selector(playNextEvent) withObject:nil afterDelay:[self delayBetweenEvents]];
        } else {
            self.isPlaying = NO;
            [self updateControlButtons];
        }
    }
}

-(void) playNextEvent {
    Event* lastEvent = self.currentEvent;
    UPoint* lastPoint = self.currentPoint;
    [self moveCurrentEventForward];
    if (self.currentEvent) {
        if (lastEvent == nil || lastEvent != self.currentEvent) {
            if (lastPoint == nil || lastPoint != self.currentPoint) {
                [self.fieldView resetField];
            }
            if (self.currentEvent.beginPosition) {
                [self displayNewBeginEvent:self.currentEvent];
            } else {
                [self displayNewEvent:self.currentEvent];
            }
        }
    } else {
        [self.fieldView resetField];
        [self handleNewEventDisplayComplete];
    }
}

-(void)displayNewEvent: (Event*)event {
    [self.fieldView displayNewEvent:event atRelativeSpeed: [self playbackSpeedFactor] complete:^{
        [self handleNewEventDisplayComplete];
    }];
}

-(void)displayNewBeginEvent: (Event*)event {
    Event* beginEvent = [event asBeginEvent];
    [self.fieldView displayNewEvent:beginEvent atRelativeSpeed: [self playbackSpeedFactor] complete:^{
        [self performSelector:@selector(displayNewEvent:) withObject:event afterDelay:[self delayBetweenEvents]];
    }];
}


-(void) moveCurrentEventForward {
    if (!self.currentPoint) {
        self.currentPoint = self.game.points[0];
    }
    if (self.currentEvent) {
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
    } else {
        self.currentEvent = self.currentPoint.events[0];
    }
}

-(void) moveCurrentEventBackward {
    if (!self.currentEvent) {
        [self moveCurrentPointBackward];
    } else {
        for (int i = 0; i < [self.currentPoint.events count]; i++) {
            Event* event = self.currentPoint.events[i];
            if (event == self.currentEvent) {
                self.currentEvent = i == 0 ? nil : self.currentPoint.events[i - 1];
                break;
            }
        }
    }
}

-(void) moveCurrentPointForward {
    if (self.currentPoint) {
        for (int i = 0; i < [self.game.points count] - 1; i++) {  // not including the last point in iteration
            UPoint* point = self.game.points[i];
            if (point == self.currentPoint) {
                self.currentPoint = self.game.points[i + 1];
                break;
            }
        }
    } else {
        self.currentPoint = self.game.points[0];
        
    }
    self.currentEvent = nil;
}

-(void) moveCurrentPointBackward {
    if (self.currentPoint) {
        for (int i = 1; i < [self.game.points count]; i++) {  // not including first point in iteration
            UPoint* point = self.game.points[i];
            if (point == self.currentPoint){
                self.currentPoint = self.game.points[i - 1];
                if ([self.currentPoint.events count] > 0) {
                    self.currentEvent = self.currentPoint.events[[self.currentPoint.events count] - 1];
                }
                break;
            }
        }
    } else {
        self.currentPoint = self.game.points[0];
        self.currentEvent = nil;
    }
}

-(void)displayCurrentEvent {
    [self.fieldView resetField];
    if (self.currentEvent) {
        for (Event* event in self.currentPoint.events) {
            if (event.beginPosition) {
                Event* beginEvent = [event asBeginEvent];
                [self.fieldView displayEvent:beginEvent];
            }
            [self.fieldView displayEvent:event];
            if (event == self.currentEvent) { // only go until we hit our event
                break;
            };
        }
    }
}

#pragma mark - Controls updating

-(void)updateControls {
    [self updateGameProgressSlider];
    [self updateControlButtons];
    [self updateTracerArrowCheckbox];
}

-(void)updateGameProgressSlider {
    float gameProgressPercent = 0;
    // update the slider to show game progess.  Each point is an equal increment in progress
    if ([self numberOfPoints] > 0) {
        // start at beginning of current point
        gameProgressPercent = (float)self.currentPointIndex / (float)[self numberOfPoints];
        if (self.currentEvent) {
            float numberOfEvents = [self.currentPoint getNumberOfEvents];
            // add events played in this point
            if (numberOfEvents > 0) {
                float percentPerPoint = 1.f / (float)[self numberOfPoints];
                float relativeEventPercent = (float)(self.currentEventIndex) / (float)numberOfEvents;
                gameProgressPercent += (relativeEventPercent * percentPerPoint);
            }
        }
    }
    [UIView animateWithDuration:[self scaleDuration:kProgressSliderAnimationDuration] animations:^{
        [self.gameProgressSlider setValue:gameProgressPercent animated:YES];
    }];
}

-(void)updateControlButtons {
    [self.playButton setImage: self.isPlaying ? self.pauseImage : self.playImage forState:UIControlStateNormal];
    BOOL isFirstPoint = self.currentPointIndex == 0;
    BOOL isLastPoint = self.currentPointIndex == [self numberOfPoints] - 1;
    BOOL isFirstEventOfPoint = self.currentEventIndex == 0;
    BOOL isLastEventOfPoint = self.currentEvent && self.currentEventIndex == [self.currentPoint.events count];
    self.fastBackwardButton.enabled = !isFirstPoint;
    self.fastForwardButton.enabled = !isLastPoint;
    self.backwardButton.enabled = !isFirstPoint || !isFirstEventOfPoint;
    self.forwardButton.enabled = !isLastPoint || !isLastEventOfPoint;
}

-(void)updateTracerArrowCheckbox {
    [self.tracerCheckbox setImage:self.fieldView.tracerArrowsHidden ? self.checkboxUnCheckedImage : self.checkboxCheckedImage forState:UIControlStateNormal];
}

#pragma mark - Playback Speed

// answers between 0.0 and 1.0 (.5 is normal speed)
-(float)playbackSpeedFactor {
    return 1 - self.playbackSpeedSlider.value;
}

-(NSTimeInterval)delayBetweenEvents {
    return [self scaleDuration:kNormalDelayBetweenEvents];
}

-(NSTimeInterval)scaleDuration: (float)standardDuration {
    float normal = standardDuration * 2.f;
    NSTimeInterval duration = MAX(standardDuration * .1f, normal * [self playbackSpeedFactor]);
    return duration;
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
    self.currentEventIndex = 0;  // 0 implies no event
    if (currentEvent) {
        int index = 0;
        for (Event* event in self.currentPoint.events) {
            if (event == currentEvent) {
                self.currentEventIndex = index;
                self.currentEventIndex++;
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
