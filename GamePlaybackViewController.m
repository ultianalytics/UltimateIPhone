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
#import "PlayerSubstitution.h"
#import "Player.h"

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
@property (weak, nonatomic) IBOutlet UILabel *gameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gameInstructionsImageView;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@property (strong, nonatomic) UIImage* playImage;
@property (strong, nonatomic) UIImage* pauseImage;
@property (strong, nonatomic) UIImage* checkboxCheckedImage;
@property (strong, nonatomic) UIImage* checkboxUnCheckedImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fieldViewHeightConstraint;

@property (strong, nonatomic) UPoint* currentPoint;
@property (strong, nonatomic) NSArray* currentEvents;
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
    self. currentEvents = @[];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"Game Playback";
    self.playImage = [UIImage imageNamed:@"play"];
    self.pauseImage = [UIImage imageNamed:@"pause"];
    self.checkboxCheckedImage = [UIImage imageNamed:@"checkbox-checked-white-border.png"];
    self.checkboxUnCheckedImage = [UIImage imageNamed:@"checkbox-unchecked-white-border.png"];
    self.fieldView.tracerArrowsHidden = NO;
    [self populateGameTitleAndDate];
    [self updateScoreAnimated: NO];
    [self updateControls];
    [self updateLine];
    self.gameInstructionsImageView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureForOrientation:self.interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self configureForOrientation:toInterfaceOrientation];
}

#pragma mark - Event Handling

- (IBAction)gameSliderChanged:(id)sender {
    [self handleGameProgessSliderChanged];
}

- (IBAction)gameSliderReleased:(id)sender {
    [self updateControls];
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
    [self updateScoreAnimated:YES];
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
            [self displayNewEvent:self.currentEvent];
        }
    } else {
        [self.fieldView resetField];
        [self handleNewEventDisplayComplete];
    }
}

-(void)displayNewEvent: (Event*)event {
    self.gameInstructionsImageView.hidden = YES;
    [self.fieldView displayNewEvent:event atRelativeSpeed: [self playbackSpeedFactor] complete:^{
        [self handleNewEventDisplayComplete];
    }];
}

-(void) moveCurrentEventForward {
    if (!self.currentPoint) {
        self.currentPoint = self.game.points[0];
    }
    if (self.currentEvent) {
        BOOL nextEventInCurrentPoint = NO;
        for (int i = 0; i < [self.currentEvents count] - 1; i++) {  // not including the last event in iteration
            Event* event = self.currentEvents[i];
            if (event == self.currentEvent) {
                self.currentEvent = self.currentEvents[i + 1];
                nextEventInCurrentPoint = YES;
                break;
            }
        }
        if (!nextEventInCurrentPoint) {
            [self moveCurrentPointForward];
        }
    } else {
        self.currentEvent = self.currentEvents[0];
    }
}

-(void) moveCurrentEventBackward {
    if (!self.currentEvent) {
        [self moveCurrentPointBackward];
    } else {
        for (int i = 0; i < [self.currentEvents count]; i++) {
            Event* event = self.currentEvents[i];
            if (event == self.currentEvent) {
                self.currentEvent = i == 0 ? nil : self.currentEvents[i - 1];
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
                if ([self.currentEvents count] > 0) {
                    self.currentEvent = self.currentEvents[[self.currentEvents count] - 1];
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
    self.gameInstructionsImageView.hidden = YES;
    [self.fieldView resetField];
    if (self.currentEvent) {
        for (Event* event in self.currentEvents) {
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
    [self updateScoreAnimated:NO];
}

#pragma mark - Controls updating

-(void)updateControls {
    [self updateGameProgressSlider];
    [self updateControlButtons];
    [self updateTracerArrowCheckbox];
}

-(void)updateControlButtons {
    [self.playButton setImage: self.isPlaying ? self.pauseImage : self.playImage forState:UIControlStateNormal];
    BOOL isFirstPoint = self.currentPointIndex == 0;
    BOOL isLastPoint = self.currentPointIndex == [self numberOfPoints] - 1;
    BOOL isFirstEventOfPoint = self.currentEventIndex == 0;
    BOOL isLastEventOfPoint = self.currentEvent && self.currentEventIndex == [self.currentEvents count];
    self.fastBackwardButton.enabled = !isFirstPoint;
    self.fastForwardButton.enabled = !isLastPoint;
    self.backwardButton.enabled = !isFirstPoint || !isFirstEventOfPoint;
    self.forwardButton.enabled = !isLastPoint || !isLastEventOfPoint;
}

-(void)updateTracerArrowCheckbox {
    [self.tracerCheckbox setImage:self.fieldView.tracerArrowsHidden ? self.checkboxUnCheckedImage : self.checkboxCheckedImage forState:UIControlStateNormal];
}

-(void)updateScoreAnimated: (BOOL)animateUpdate {
    UPoint* scorePoint;
    if ([self.currentEvent isGoal]) {
        scorePoint = self.currentPoint;
    } else {
        scorePoint = [self.game findPreviousPoint:self.currentPoint];
    }
    
    NSString* scoreText = @"";
    if (scorePoint) {
        Score score = scorePoint.summary.score;
        NSString* formattedScore = [NSString stringWithFormat:@"%d-%d", score.ours, score.theirs];
        NSString* winningTeam = score.ours > score.theirs ? self.team.name : (score.ours < score.theirs ? self.game.opponentName : @"");
        scoreText = [NSString stringWithFormat:@"%@ %@", formattedScore, winningTeam];
    } else {
        scoreText = @"0-0";
    }
    NSString* newScoreText = [NSString stringWithFormat:@"Score: %@",scoreText];
    NSString* oldText = self.scoreLabel.text;
    self.scoreLabel.text = newScoreText;
    if (animateUpdate && ![oldText isEqualToString:newScoreText]) {
        CGFloat swellFactor = 1.5;
        [UIView animateWithDuration:.3 animations:^{
            self.scoreLabel.transform = CGAffineTransformScale(self.scoreLabel.transform, swellFactor, swellFactor);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3 animations:^{
                self.scoreLabel.transform = CGAffineTransformScale(self.scoreLabel.transform, 1/swellFactor, 1/swellFactor);
            }];
        }];
    }
}

-(void)updateLine {
    NSMutableAttributedString* lineText;
    if (self.currentPoint) {
        UPoint* point = self.currentPoint;
        NSMutableSet* allPlayerNames = [NSMutableSet setWithArray:[point.line valueForKeyPath: @"name"]];
        for (PlayerSubstitution* substitution in point.substitutions) {
            [allPlayerNames addObject:substitution.fromPlayer.name];
            [allPlayerNames addObject:substitution.toPlayer.name];
        }
        for (PlayerSubstitution* substitution in point.substitutions) {
            if ([allPlayerNames containsObject:substitution.fromPlayer.name]) {
                [allPlayerNames removeObject:substitution.fromPlayer.name];
                [allPlayerNames addObject: [NSString stringWithFormat:@"%@ (partial)", substitution.fromPlayer.name]];
            }
            if ([allPlayerNames containsObject:substitution.toPlayer.name]) {
                [allPlayerNames removeObject:substitution.toPlayer.name];
                [allPlayerNames addObject: [NSString stringWithFormat:@"%@ (partial)", substitution.toPlayer.name]];
            }
        }
        NSString* playerNames = [[allPlayerNames allObjects] componentsJoinedByString: @", "];
        NSString* lineType = point.summary.isOline ? @"O-line: " : @"D-line: ";
        lineText = [[NSMutableAttributedString alloc] initWithString:lineType attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:19]}];
        [lineText appendAttributedString:[[NSMutableAttributedString alloc] initWithString:playerNames]];
    } else {
        lineText = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    self.lineLabel.attributedText = lineText;
    [UIView transitionWithView:self.lineLabel duration:.5 options:UIViewAnimationOptionTransitionFlipFromBottom animations:nil completion:nil];
}

#pragma mark - Game Progress Slider

-(void)updateGameProgressSlider {
    float gameProgressPercent = 0;
    // update the slider to show game progess.  Each point is an equal increment in progress
    if ([self numberOfPoints] > 0) {
        // start at beginning of current point
        gameProgressPercent = (float)self.currentPointIndex / (float)[self numberOfPoints];
        if (self.currentEvent) {
            float numberOfEvents = [self.currentEvents count];
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

- (void)handleGameProgessSliderChanged {
    float gameProgessPercent = self.gameProgressSlider.value;
    float gameProgresPercentPerPoint = 1.0f / (float)[self numberOfPoints];
    int pointIndex = gameProgessPercent * [self numberOfPoints];
    if (pointIndex < [self.game.points count]) {
        // set point
        UPoint* point = self.game.points[pointIndex];
        [self setCurrentPoint:point];
        
        // set event
        float numberOfEvents = [self.currentEvents count] + 1;
        float progressPercentPerEvent = (float)(gameProgresPercentPerPoint) / (float)numberOfEvents;
        float eventProgressPercentInPoint = gameProgessPercent - (pointIndex * gameProgresPercentPerPoint);
        int eventIndex = progressPercentPerEvent > 0 ? (eventProgressPercentInPoint / progressPercentPerEvent) : 0;
        self.currentEvent = eventIndex == 0 ? nil : (eventIndex < [self.currentEvents count] ? self.currentEvents[eventIndex] : [self.currentEvents lastObject]);
        [self displayCurrentEvent];
        //    NSLog(@"pointIndex = %d, eventIndex = %d", pointIndex, eventIndex);
    }
    
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
    if (currentPoint == _currentPoint) {
        return;
    }
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
    [self updateCurrentEventsFromCurrentPoint];
    [self updateLine];
}

-(void)updateCurrentEventsFromCurrentPoint {
    NSMutableArray* events = [NSMutableArray array];
    if (self.currentPoint) {
        for (Event* event in self.currentPoint.events) {
            if (event.beginPosition) {
                [events addObject:[event asBeginEvent]];
                [events addObject:event];
            } else {
                [events addObject:event];
            }
        }
    }
    self.currentEvents = events;
}

-(void)setCurrentEvent:(Event *)currentEvent {
    _currentEvent = currentEvent;
    self.currentEventIndex = 0;  // 0 implies no event
    if (currentEvent) {
        int index = 0;
        for (Event* event in self.currentEvents) {
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

-(void)populateGameTitleAndDate {
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE MMM d h:mm a"];
    NSString* dateString = self.game.startDateTime ? [dateFormat stringFromDate:self.game.startDateTime] : @"Start Time Unknown";
    NSString* titleString = [NSString stringWithFormat:@"%@ vs. %@", self.team.name, self.game.opponentName];
    self.gameTitleLabel.text = titleString;
    self.gameDateLabel.text = dateString;
}

- (void)configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.fieldViewHeightConstraint.constant = 300;
    } else {
        self.fieldViewHeightConstraint.constant = 420;
    }
}

@end
