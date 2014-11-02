//
//  SecondViewController.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GameViewController.h"
#import "PickPlayersController.h"
#import "GameHistoryController.h"
#import "EventView.h"
#import "PlayerView.h"
#import "Event.h"
#import "Team.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "CessationEvent.h"
#import "Game.h"
#import "GameDetailViewController.h"
#import "ColorMaster.h"
#import "Preferences.h"
#import "Tweeter.h"
#import "Player.h"
#import "Wind.h"
#import "Reachability.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "LeaguevineClient.h"
#import "LeagueVineSignonViewController.h"
#import "PullLandingViewController.h"
#import "UIViewController+Additions.h"
#import "ActionDetailsViewController.h"
#import "TimeoutViewController.h"
#import "LeaguevineEventQueue.h"
#import "LeaguevinePostingLog.h"
#import "UIView+Convenience.h"
#import "GameAutoUploader.h"
#import "CloudRequestStatus.h"


#define kConfirmNewGameAlertTitle @"Confirm Game Over"
#define kNotifyNewGameAlertTitle @"Game Over?"
#define kPromptForOvertimeReceiverTitle @"Overtime: who will receive?"
#define kNoInternetAlertTitle @"No Internet Access"
#define kLeaguevineCredentialsRejected @"Leaguevine Signon Needed"
#define kLeaguevineGameInvalid @"Leaguevine Game Not Valid"
#define kLeaguevineError @"Error Posting To Leaguevine"
#define kAutoUploadErrorTitle @"Upload Errors"

#define kIsNotFirstGameViewUsage @"IsNotFirstGameViewUsage"
#define kHasUserSeenDeLongPressCallout @"HasUserSeenDeLongPressCallout"
#define kHasUserSeenThrowawayLongPressCallout @"HasUserSeenThrowawayLongPressCallout"

@interface GameViewController() <GameHistoryControllerDelegate>

@property (nonatomic) BOOL isOffense;

// iphone only
@property (nonatomic, strong) IBOutlet UIView *normalView;
@property (nonatomic, strong) IBOutlet UIView *detailSelectionView;

// ipad only
@property (nonatomic, strong) IBOutlet UIView *topOrLeftView;
@property (nonatomic, strong) IBOutlet UIView *bottomOrRightView;

// action sub view
@property (nonatomic, strong) IBOutlet UIView* actionSubView;
@property (nonatomic, strong) IBOutlet UILabel* playerLabel;
@property (nonatomic, strong) IBOutlet UILabel* receiverLabel;
@property (nonatomic, strong) IBOutlet UIButton* throwAwayButton;
@property (nonatomic, strong) IBOutlet UIButton* otherTeamThrowAwayButton;
@property (nonatomic, strong) IBOutlet UIButton* otherTeamScoreButton;
@property (nonatomic, strong) IBOutlet PlayerView* playerView1;
@property (nonatomic, strong) IBOutlet PlayerView* playerView2;
@property (nonatomic, strong) IBOutlet PlayerView* playerView3;
@property (nonatomic, strong) IBOutlet PlayerView* playerView4;
@property (nonatomic, strong) IBOutlet PlayerView* playerView5;
@property (nonatomic, strong) IBOutlet PlayerView* playerView6;
@property (nonatomic, strong) IBOutlet PlayerView* playerView7;
@property (nonatomic, strong) IBOutlet PlayerView* playerViewTeam;
@property (nonatomic, strong) IBOutlet UIView* hideReceiverView;
@property (nonatomic, strong) IBOutlet UIImageView* firstPasserBracketImage;

// recent events
@property (nonatomic, strong) IBOutlet UIButton* removeEventButton;
@property (nonatomic, strong) IBOutlet EventView* eventView1;
@property (nonatomic, strong) IBOutlet EventView* eventView2;
@property (nonatomic, strong) IBOutlet EventView* eventView3;
@property (nonatomic, strong) IBOutlet UIView* swipeEventsView;

// game buttons
@property (nonatomic, strong) IBOutlet UIButton* timeoutButton;
@property (nonatomic, strong) IBOutlet UIButton* gameOverButton;

// broadcasting views
@property (nonatomic, strong) IBOutlet UIImageView* broadcast0ImageView;
@property (nonatomic, strong) IBOutlet UIImageView* broadcast1ImageView;
@property (nonatomic, strong) IBOutlet UIImageView* broadcast2ImageView;

// events view controller subview (ipad only)
@property (nonatomic, strong) IBOutlet UIView* eventsSubView;

@property (nonatomic, strong) IBOutlet UILabel* noEventsLabel;

@property (nonatomic, strong) NSMutableArray* playerViews;
@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;
@property (nonatomic, strong) CalloutsContainerView *infoCalloutsView;
@property (nonatomic, strong) LeaguevineClient *leaguevineClient;
@property (nonatomic, strong) ActionDetailsViewController* detailsController;
@property (nonatomic, strong) GameHistoryController* eventsViewController;
@property (nonatomic, strong) NSDate* lastAutoUploadWarning;

@end

@implementation GameViewController
@synthesize playerLabel,receiverLabel,throwAwayButton, gameOverButton,playerViews,playerView1,playerView2,playerView3,playerView4,playerView5,playerView6,playerView7,playerViewTeam,otherTeamScoreButton,eventView1,
    eventView2,eventView3, removeEventButton, swipeEventsView, hideReceiverView, firstTimeUsageCallouts,infoCalloutsView;

#pragma mark  Miscelleanous

-(void)handlePullBegin: (Player*) player {
    double currentTime = CACurrentMediaTime();
    PullLandingViewController* pullLandingVC = [[PullLandingViewController alloc] init];
    pullLandingVC.pullBeginTime = currentTime;
    __typeof(self) __weak weakSelf = self;
    pullLandingVC.completion = ^(BOOL cancelled, BOOL isOutOfBounds, long hangtimeMilliseconds) {
        [self dismissViewControllerAnimated:YES completion:^{
            if(!cancelled) {
                DefenseEvent* event = [[DefenseEvent alloc] initDefender:player action:isOutOfBounds ? PullOb : Pull];
                if (hangtimeMilliseconds > 0) {
                    event.pullHangtimeMilliseconds = (int)hangtimeMilliseconds;
                }
                [weakSelf addEvent: event];
                [weakSelf showActionButtonDidYouKnow];
            }
        }];
    };
    pullLandingVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:pullLandingVC animated:YES completion:nil];
}

-(void) addEvent: (Event*) event {
    [self addEventProperties:event];
    [[Game getCurrentGame] addEvent: event];  
    [self updateEventViews];
    [self refreshTitle: event];
    [self saveGame];
    if ([event causesOffenseDefenseChange]) {
        self.isOffense = [[Game getCurrentGame] arePlayingOffense];
        if ([event isGoal] && [self shouldPublishScoresToLeaguevine]) {
            [self notifyLeaguevineOfScoreIsFinal:NO];
        }
        if ([event isGoal] && [[Game getCurrentGame] isNextEventImmediatelyAfterHalftime] && ![[Game getCurrentGame] isTimeBasedEnd]) {
            [PickPlayersController halftimeWarning];
            [self goToPlayersOnFieldView];
        } else if ([[Game getCurrentGame] doesGameAppearDone]) {
            [self gameOverChallenge];
        } else if ([event causesLineChange]) {
            [self goToPlayersOnFieldViewFlashScore:YES];
        }
    }
    [self updateViewFromGame:[Game getCurrentGame]];
    [self notifyLeaguevineOfNewEvent:event];
    [self eventsUpdated];
    if ([event isGoal]) {
        [self warnAboutAutoGameUploadIfErrors];
    }
}

-(void) addEventProperties: (Event*) event {
    // no-op...subclasses can implement
}

-(void)updateEventViews {
    NSArray* lastFewEvents = [[Game getCurrentGame] getLastEvents:3];
    [self.eventView1 updateEvent: [lastFewEvents count] >= 1 ? [lastFewEvents objectAtIndex:0] : nil];
    [self.eventView2 updateEvent: [lastFewEvents count] >= 2 ? [lastFewEvents objectAtIndex:1] : nil];
    [self.eventView3 updateEvent: [lastFewEvents count] >= 3 ? [lastFewEvents objectAtIndex:2] : nil];
    self.removeEventButton.hidden = [lastFewEvents count] == 0;
    self.noEventsLabel.hidden = !self.removeEventButton.hidden;
}

-(void) refreshTitle: (Event*) event { 
    if ([event isGoal]) {
        [self updateNavBarTitle];
    }
}

- (PlayerView*) findPlayerView: (Player*) player {
    for (PlayerView* playerView in self.playerViews) {
        if ([player isEqual:playerView.player]) {
            return playerView;
        }
    }
    return nil;
}

- (PlayerView*) findSelectedPlayerView {
    for (PlayerView* playerView in self.playerViews) {
        if ([playerView isSelected]) {
            return playerView;
        }
    }
    return nil;
}

- (void) setNeedToSelectPasser: (BOOL) needToSelectPasser {
    if (![[Game getCurrentGame] isPositional]) {
        for (PlayerView* playerView in self.playerViews) {
            [playerView setNeedToSelectPasser: needToSelectPasser];
        }
        self.hideReceiverView.hidden = !needToSelectPasser;
    }
}

-(void)setIsOffense:(BOOL)shouldBeOnOffense {
    _isOffense = shouldBeOnOffense;
    self.receiverLabel.hidden = !_isOffense;
    self.otherTeamScoreButton.hidden = _isOffense;
    [self setNeedToSelectPasser: NO];
    [self.playerLabel setText: _isOffense ? @"Passer" : @"Defender"];
    [self.playerView1 setIsOffense:_isOffense];
    [self.playerView2 setIsOffense:_isOffense];
    [self.playerView3 setIsOffense:_isOffense];
    [self.playerView4 setIsOffense:_isOffense];
    [self.playerView5 setIsOffense:_isOffense];
    [self.playerView6 setIsOffense:_isOffense];
    [self.playerView7 setIsOffense:_isOffense];
    [self.playerViewTeam setIsOffense:_isOffense];
    self.throwAwayButton.visible = _isOffense;
    self.otherTeamThrowAwayButton.hidden = self.throwAwayButton.visible;
    [self populatePlayers];
    [self initializeSelected];
}

- (void) populatePlayers {
    PlayerView* previousSelected = [self findSelectedPlayerView];
    Player* previousSelectedPlayer = previousSelected ? previousSelected.player : nil;
    NSArray* players = [[Game getCurrentGame] currentLineSorted];
    for (int i = 0; i < 7; i++) {
        PlayerView* view = [self.playerViews objectAtIndex: i];
        if (i < [players count]) {
            view.player = [players objectAtIndex:i];
            view.hidden = NO;
        } else {
            view.hidden = YES;
        }
    }
    [previousSelected makeSelected:NO];
    if ([[Game getCurrentGame] hasEvents] && previousSelectedPlayer) {
        PlayerView* newSelected = [self findPlayerView: previousSelectedPlayer];
        [newSelected makeSelected:YES];
    } else {
        [playerViewTeam makeSelected:YES];
    }
}

- (void) initializeSelected {
    if (self.isOffense) {
        PlayerView* previousSelected = [self findSelectedPlayerView];
        if (previousSelected) {
            [previousSelected makeSelected:NO];
        } 
        Event* lastEvent = [[Game getCurrentGame] getLastEvent];
        if (lastEvent !=  nil && lastEvent.action == Catch) {
            OffenseEvent* catchEvent = (OffenseEvent*)lastEvent;
            PlayerView* playerView = [self findPlayerView: catchEvent.receiver];
            if (playerView) {
                [playerView makeSelected:YES];
            } else {
                [playerViewTeam makeSelected:YES];
            }
        } else {
            [self setNeedToSelectPasser: YES];
        }
    }
}

- (void) updateBroacastingNoticesWithWarning: (BOOL)shouldWarn {
    BOOL isAutoTweeting = [Tweeter getCurrent].isTweetingEvents;
    BOOL isLeaguevinePosting = [self shouldPublishToLeaguevine];
    BOOL isAutoGameUploading = [Team getCurrentTeam].isAutoUploading;
    self.broadcast0ImageView.visible = isLeaguevinePosting;
    self.broadcast1ImageView.visible = isAutoGameUploading;
    self.broadcast2ImageView.visible = isAutoTweeting;

    if (shouldWarn) {
        if ((isAutoTweeting || isAutoGameUploading || [self shouldPublishScoresToLeaguevine]) &&
            [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
            NSString* broadcastTarget;
            if ([self shouldPublishScoresToLeaguevine]) {
                broadcastTarget= isAutoTweeting ? isLeaguevinePosting ? @"auto-tweeting and posting scores to Leaguevine" : @"auto-tweeting" :
                @"posting scores to Leaguevine";
            } else {
                broadcastTarget = isAutoTweeting ? isAutoGameUploading ? @"auto-tweeting and auto-uploading games" : @"auto-tweeting" :
                @"auto-uploading games";
            }
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: kNoInternetAlertTitle
                                  message: [NSString stringWithFormat: @"Warning: You are %@ but we can't reach the internet.", broadcastTarget]
                                  delegate: nil
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)updateNavBarTitle {
    
    Score score = [[Game getCurrentGame] getScore];
    NSString* leaderDescription = score.ours == score.theirs ? @"" : score.ours > score.theirs    ? @", us" :  @", them";
    NSString* navBarTitle = [NSString stringWithFormat:@"%@ (%d-%d%@)", NSLocalizedString(@"Action", @"Action"), score.ours, score.theirs, leaderDescription];
    self.navigationItem.title = navBarTitle;
}

-(void) refreshView {
    Game* game = [Game getCurrentGame];
    self.isOffense = [game arePlayingOffense];
    [self updateEventViews];
    [self updateNavBarTitle];
    [[Game getCurrentGame] save];
    [self updateViewFromGame:[Game getCurrentGame]];
    [self updateBroacastingNoticesWithWarning:NO];
    [self updateTimeoutsButton];
}

-(void) updateViewFromGame: (Game*) game {
    self.throwAwayButton.visible = self.isOffense;
    self.otherTeamThrowAwayButton.hidden = self.throwAwayButton.visible;
    if (!self.isOffense) {
        self.otherTeamScoreButton.hidden = [game canNextPointBeDLinePull] ? YES : NO;
        self.otherTeamThrowAwayButton.hidden = [game canNextPointBeDLinePull] ? YES : NO;
    }
    for (PlayerView* playerView in playerViews) {
        [playerView update:game];
    }
    [self updateGameOverButtonForTimeBasedGame];
    [self.eventsViewController refresh];
}

-(void)updateTimeoutsButton {
    NSString* timeoutButtonText = [NSString stringWithFormat:@"Timeouts\n(%d free)", [[Game getCurrentGame] availableTimeouts]];
    [self.timeoutButton setTitle:timeoutButtonText forState:UIControlStateNormal];
    [self.timeoutButton setTitle:timeoutButtonText forState:UIControlStateHighlighted];
}

-(GameHistoryController*)createEventsViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"GameHistoryController" bundle:nil];
    GameHistoryController* historyController = [storyboard instantiateInitialViewController];
    historyController.delegate = self;
    historyController.game = [Game getCurrentGame];
    return historyController;
}

-(void)configureActionView {
    // add the action view
    NSString* actionViewNib = @"GameActionView";
    if (IS_IPHONE) {
        /* iPHone dimensions: 
            6+  540x960
            6   375x667
            5   320x568
            4   320x480
         */
        if ([UIScreen mainScreen].bounds.size.height > 667) {
            actionViewNib = @"GameActionView_iPhone_6Plus";
        } else if ([UIScreen mainScreen].bounds.size.height > 568) {
            actionViewNib = @"GameActionView_iPhone_6";
        } else if ([UIScreen mainScreen].bounds.size.height > 480) {
            actionViewNib = @"GameActionView_iPhone_5";
        }
    }
    
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:actionViewNib owner:self options:nil];
    UIView* actionView = (UIView*)nibViews[0];
    [self.actionSubView addSubview:actionView];
    actionView.backgroundColor = [ColorMaster actionBackgroundColor];
}

-(Event*)removeLastEvent {
    Event* lastEventBefore = [[Game getCurrentGame] getLastEvent];
    [[Game getCurrentGame] removeLastEvent];
    return lastEventBefore;
}

-(void)saveGame {
    [[Game getCurrentGame] saveWithUpload];
}

#pragma mark ActionListener

- (void) action: (Action) action targetPlayer: (Player*) player fromView: (PlayerView*) view {
    if (self.isOffense) {
        PlayerView* oldSelected = [self findSelectedPlayerView];
        if (oldSelected) {
            [oldSelected makeSelected:NO];
        }
        [view makeSelected:YES];
        Player* passer = oldSelected.player;
        OffenseEvent* event = [[OffenseEvent alloc] initPasser:passer action:action receiver:player];
        [self addEvent: event];
    } else {
        if (action == Pull) {
            [self handlePullBegin: player];
        } else {
            DefenseEvent* event = [[DefenseEvent alloc] initDefender:player action:action];
            [self addEvent: event];
        }
    }
}

- (void) passerSelected: (Player*) player view: (PlayerView*) view {
    if (self.isOffense) {
        [self setNeedToSelectPasser: NO];
        [self showActionButtonDidYouKnow];
    }
    PlayerView* oldSelected = [self findSelectedPlayerView];
    if (oldSelected) {
        [oldSelected makeSelected:NO];
    }
    [view makeSelected:YES];
}

#pragma mark Long Press Handling

- (void) passerLongPress: (Player*) player view: (PlayerView*) view {
    [self passerSelected:player view:view];
}


- (void) actionLongPress: (Action) action targetPlayer: (Player*) player fromView: (PlayerView*) view {
    if (action == Pull) {
        [self handlePullBegin: player];
    } else {
        if (self.isOffense) {
            PlayerView* oldSelected = [self findSelectedPlayerView];
            if (oldSelected) {
                [oldSelected makeSelected:NO];
            }
            [view makeSelected:YES];
            Player* passer = oldSelected.player;
            OffenseEvent* defaultEvent = [[OffenseEvent alloc] initPasser:passer action:action receiver:player];
            [self.detailsController setCandidateEvents:@[defaultEvent] initialChosen:defaultEvent];
            self.detailsController.description = @"Only choice for this button is...";
        } else {
            DefenseEvent* defaultEvent = [[DefenseEvent alloc] initDefender:player action:action];
            if (action == De) {
                DefenseEvent* callahan = [[DefenseEvent alloc] initDefender:player action:Callahan];
                [self.detailsController setCandidateEvents:@[defaultEvent, callahan] initialChosen:defaultEvent];
                self.detailsController.description = @"D is...";
            } else {
                [self.detailsController setCandidateEvents:@[defaultEvent] initialChosen:defaultEvent];
                self.detailsController.description = @"Only choice for this button is...";
            }
        }
        GameViewController* __weak weakSelf = self;
        self.detailsController.saveBlock = ^(Event* event){
            [weakSelf addEvent: event];
            [weakSelf showDetailSelectionView:NO];
        };
        [self showDetailSelectionView: YES];
    }
}

-(void)turnoverButtonLongPress: (UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.isOffense) {
            PlayerView* oldSelected = [self findSelectedPlayerView];
            if (oldSelected) {
                [oldSelected makeSelected:NO];
            }
            [playerViewTeam makeSelected:YES];
            Player* passer = oldSelected.player;
            OffenseEvent* throwaway = [[OffenseEvent alloc] initPasser:passer action:Throwaway];
            OffenseEvent* stall = [[OffenseEvent alloc] initPasser:passer action:Stall];
            OffenseEvent* miscPenalty = [[OffenseEvent alloc] initPasser:passer action:MiscPenalty];
            OffenseEvent* callahan = [[OffenseEvent alloc] initPasser:passer action:Callahan];
            [self.detailsController setCandidateEvents:@[throwaway, stall, miscPenalty, callahan] initialChosen:throwaway];
            self.detailsController.description = @"Turnover is...";
        } else {
            DefenseEvent* throwaway = [[DefenseEvent alloc] initAction:Throwaway];
            [self.detailsController setCandidateEvents:@[throwaway] initialChosen:throwaway];
            self.detailsController.description = @"Only choice for this button is...";
        }
        GameViewController* __weak weakSelf = self;
        self.detailsController.saveBlock = ^(Event* event){
            [weakSelf addEvent: event];
            [weakSelf showDetailSelectionView:NO];
        };
        [self showDetailSelectionView: YES];
    }
}

#pragma mark Event Handlers

-(IBAction)removeEventClicked: (id) sender {
    Event* lastEventBefore = [self removeLastEvent];
    [self updateEventViews];
    Event* lastEventAfter = [[Game getCurrentGame] getLastEvent];
    [self refreshTitle: lastEventBefore];
    [self saveGame];
    if ([lastEventBefore causesOffenseDefenseChange]) {
        self.isOffense = [[Game getCurrentGame] arePlayingOffense];
        if ([lastEventAfter causesLineChange]) {
            [self goToPlayersOnFieldView];
        }
    }
    [self initializeSelected];
    [self updateViewFromGame:[Game getCurrentGame]];
    [self notifyLeaguevineOfRemovedEvent:lastEventBefore];
    [self eventsUpdated];
}

-(IBAction)throwAwayButtonClicked: (id) sender {
    if (self.isOffense) {
        PlayerView* oldSelected = [self findSelectedPlayerView];
        if (oldSelected) {
            [oldSelected makeSelected:NO];
        }
        [playerViewTeam makeSelected:YES];
        Player* passer = oldSelected.player;
        OffenseEvent* event = [[OffenseEvent alloc] initPasser:passer action:Throwaway];
        [self addEvent: event];
    } else {
        DefenseEvent* event = [[DefenseEvent alloc] initAction:Throwaway];
        [self addEvent: event];
    }
}

-(IBAction)switchSidesClicked: (id) sender {
    self.isOffense = !self.isOffense;
}

-(IBAction) gameOverButtonClicked: (id) sender {
    if ([[Game getCurrentGame] isTimeBasedEnd]) {
        Action nextPeriodEnd = [[Game getCurrentGame] nextPeriodEnd];
        if (nextPeriodEnd == EndOfFourthQuarter || nextPeriodEnd == EndOfOvertime) {
            [self overtimeReceiverPrompt];
        } else if (nextPeriodEnd != GameOver) {
            [self addEvent:[self createNextPeriodEndEvent]];
        } else {
            [self gameOverConfirm];
        }
    } else {
        [self gameOverConfirm];
    }
}

-(IBAction) timeoutButtonClicked: (id) sender {
    [self goToTimeoutView];
}

-(IBAction)otherTeamScoreClicked: (id) sender {
    DefenseEvent* event = [[DefenseEvent alloc] initAction:Goal];
    [self addEvent: event];
}

-(void)undoButtonTapped {
    
}

- (void)moreEventsSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self goToHistoryView: YES];
}

#pragma mark Go To Other views

-(void) goToPlayersOnFieldView {
    [self goToPlayersOnFieldViewFlashScore: NO];
}

-(void) goToPlayersOnFieldViewFlashScore: (BOOL) newPoint {
    PickPlayersController* pickPlayersController = [[PickPlayersController alloc] init];
    pickPlayersController.flashGoal = newPoint;
    pickPlayersController.game = [Game getCurrentGame];
    if (IS_IPAD) {
        __typeof(self) __weak weakSelf = self;
        pickPlayersController.controllerClosedBlock = ^{
            [weakSelf refreshView];
        };
        UINavigationController* pickGamesNavController = [[UINavigationController alloc] initWithRootViewController:pickPlayersController];
        pickGamesNavController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:pickGamesNavController animated:YES completion:nil];
    } else {
        pickPlayersController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pickPlayersController animated:YES];
    }
}

-(void) goToTimeoutView {
    TimeoutViewController* timeoutController = [[TimeoutViewController alloc] init];
    timeoutController.game = [Game getCurrentGame];
    if (IS_IPAD) {
        timeoutController.modalMode = YES;
        __typeof(self) __weak weakSelf = self;
        timeoutController.timeoutsUpdatedBlock = ^{
            [weakSelf updateTimeoutsButton];
        };
        UINavigationController* timeoutNavController = [[UINavigationController alloc] initWithRootViewController:timeoutController];
        timeoutNavController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:timeoutNavController animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:timeoutController animated:YES];
    }
}

-(void) goToHistoryViewRight {
    [self goToHistoryView:NO];
}

-(void) goToHistoryView: (BOOL) curl {
    GameHistoryController* historyController   = [self createEventsViewController];
    if (curl) {
        historyController.isCurlAnimation = YES;
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
        [self.navigationController pushViewController:historyController animated:NO];
        [UIView commitAnimations];
    } else {
        [self.navigationController pushViewController:historyController animated:YES];
    }
}

#pragma mark Game Over handling 

-(void)updateGameOverButtonForTimeBasedGame {
    if ([[Game getCurrentGame] isTimeBasedEnd]) {
        Action nextPeriodEnd = [[Game getCurrentGame] nextPeriodEnd];
        NSString* buttonText;
        switch (nextPeriodEnd) {
            case EndOfFirstQuarter:
                buttonText = @"End 1st Quarter";
                break;
            case Halftime:
                buttonText = @"Halftime";
                break;
            case EndOfThirdQuarter:
                buttonText = @"End 3rd Quarter";
                break;
            case EndOfFourthQuarter:
                buttonText = @"End 4th Quarter";
                break;
            case EndOfOvertime:
                buttonText = @"End Overtime";
                break;
            default:
                buttonText = @"Game Over";
                break;
        }
        [self.gameOverButton setTitle:buttonText forState:UIControlStateNormal];
        [self.gameOverButton setTitle:buttonText forState:UIControlStateHighlighted];
    }
}

-(CessationEvent*)createNextPeriodEndEvent {
    Action nextPeriodEnd = [[Game getCurrentGame] nextPeriodEnd];
    return [CessationEvent eventWithAction:nextPeriodEnd];
}

-(void)gameOverConfirm {
    // Show the confirmation.
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: NSLocalizedString(kConfirmNewGameAlertTitle,nil)
                          message: NSLocalizedString(@"You clicked Game Over.  Please confirm.",nil)
                          delegate: self
                          cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
                          otherButtonTitles: NSLocalizedString(@"Confirm",nil), nil];
    [alert show];
}

-(void)gameOverChallenge {
    // Ask if complete
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: NSLocalizedString(kNotifyNewGameAlertTitle,nil)
                          message: NSLocalizedString(@"This game appears to be over.  Please confirm.",nil)
                          delegate: self
                          cancelButtonTitle: NSLocalizedString(@"No, not yet",nil)
                          otherButtonTitles: NSLocalizedString(@"Yes, done",nil), nil];
    [alert show];
}

-(void)overtimeReceiverPrompt {
    // Ask if we are receiving or pulling
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: NSLocalizedString(kPromptForOvertimeReceiverTitle,nil)
                          message: NSLocalizedString(@"You are about to begin an overtime period.\n\nWill our team receive or pull?",nil)
                          delegate: self
                          cancelButtonTitle: NSLocalizedString(@"Receive",nil)
                          otherButtonTitles: NSLocalizedString(@"Pull",nil), nil];
    [alert show];
}

-(void) addInfoButton {
    int buttonTag = 989898;
    UIView *navBar = self.navigationController.navigationBar;
    if (![navBar viewWithTag:buttonTag]) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 0)];
        button.center = navBar.center;  // move to center of nav bar
        button.frameY = 0;
        button.frameHeight = navBar.frameHeight;
        button.tag = 98989;

        button.backgroundColor = [UIColor clearColor];  // should sit over the title transparently
        
        [button addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [navBar addSubview:button];
    }
}

#pragma mark Leaguevine

-(void)notifyLeaguevineOfScoreIsFinal: (BOOL)isFinal {
    [self.leaguevineClient postGameScore:[Game getCurrentGame].leaguevineGame score:[[Game getCurrentGame] getScore] isFinal:isFinal completion: ^(LeaguevineInvokeStatus status, id result) {
        if (status != LeaguevineInvokeOK) {
            [Game getCurrentGame].publishScoreToLeaguevine = NO;
            [[Game getCurrentGame] save];
            NSString *message, *title;
            if (status == LeaguevineInvokeCredentialsRejected) {
                title = kLeaguevineCredentialsRejected;
                message = @"You have asked to post game scores to Leaguevine but you are not signed on.  \n\nScore publishing has been turned off for this game.  Return to game view to turn on score publishing again.";
            } else if (status == LeaguevineInvokeInvalidGame) {
                title = kLeaguevineGameInvalid;
                message = @"You have asked to post game scores to Leaguevine but your team is not associated with this game.  \n\nScore publishing has been turned off for this game.  Return to game view to turn on choose another Leaguevine game.";
            } else {
                title = kLeaguevineError;
                message = @"We receieved an error while trying to post to Leaguevine. \n\nScore publishing has been turned off for this game.  Return to game view to turn on score publishing again.";
            }
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: title
                                  message: message
                                  delegate: nil
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        }
    }];
}
        
-(void)notifyLeaguevineOfNewEvent: (Event*)event {
    if ([self shouldPublishStatsToLeaguevine]) {
        if ([[Game getCurrentGame] hasOneEvent]) {
            [[LeaguevineEventQueue sharedQueue] submitLineChangeForGame:[Game getCurrentGame]];  // submit initial line
        }
        [[LeaguevineEventQueue sharedQueue] submitNewEvent:event forGame:[Game getCurrentGame] isFirstEventAfterPull:[[Game getCurrentGame] wasLastPointPull]];
        
        if ([event isGoal]) {
            [self checkForLeaguevinePostingError];
        }
    }
}

-(void)checkForLeaguevinePostingError {
    NSString* postingError = [[LeaguevineEventQueue sharedQueue].postingLog readErrorMessage];
    if (postingError) {
        [[LeaguevineEventQueue sharedQueue].postingLog deleteErrorMessage];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Warning: failed publishing to leaguevine"
                              message: postingError
                              delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    }
}

-(void)notifyLeaguevineOfRemovedEvent: (Event*)event {
    if ([self shouldPublishStatsToLeaguevine]) {
        [[LeaguevineEventQueue sharedQueue] submitDeletedEvent:event forGame:[Game getCurrentGame] wasFirstEventAfterPull:[[Game getCurrentGame] canNextPointBePull]];
    }
}

-(LeaguevineClient*)leaguevineClient {
    if (!_leaguevineClient) {
        _leaguevineClient = [[LeaguevineClient alloc] init];
    }
    return _leaguevineClient;
}

-(void)askUserForLeauguevineCredentials: (void (^)(BOOL hasLeaguevineCredentials)) completion {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    LeagueVineSignonViewController* lvController = [[LeagueVineSignonViewController alloc] init];
    lvController.finishedBlock = ^(BOOL isSignedOn, LeagueVineSignonViewController* signonController) {
        [signonController dismissViewControllerAnimated:YES completion:^{
            completion(isSignedOn);
        }];
    };
    [self presentViewController:lvController animated:YES completion:nil];
}

-(BOOL)shouldPublishToLeaguevine {
    return [self shouldPublishScoresToLeaguevine] || [self shouldPublishStatsToLeaguevine];
}

-(BOOL)shouldPublishStatsToLeaguevine {
    return [Game getCurrentGame].publishStatsToLeaguevine && [Game getCurrentGame].isLeaguevineGame && [Team getCurrentTeam].isLeaguevineTeam && [Team getCurrentTeam].arePlayersFromLeagueVine;
}

-(BOOL)shouldPublishScoresToLeaguevine {
    return [Game getCurrentGame].publishScoreToLeaguevine && [Game getCurrentGame].isLeaguevineGame && [Team getCurrentTeam].isLeaguevineTeam;
}

#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    
    // use a smaller font for nav title
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont boldSystemFontOfSize:16.0], NSFontAttributeName, nil]];
    
    [self configureActionView];
    self.hideReceiverView.backgroundColor = [ColorMaster actionBackgroundColor];
    
    self.playerViews = [[NSMutableArray alloc] initWithObjects:self.playerView1, self.playerView2,self.playerView3,self.playerView4,self.playerView5,self.playerView6,self.playerView7,self.playerViewTeam,nil];
    for (PlayerView* playerView in self.playerViews) {
        playerView.actionListener = self;
    }
    
    UILongPressGestureRecognizer* turnoverLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(turnoverButtonLongPress:)];
    [self.throwAwayButton addGestureRecognizer:turnoverLongPressRecognizer];
    
    UILongPressGestureRecognizer* otherTeamTurnoverLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(turnoverButtonLongPress:)];
    [self.otherTeamThrowAwayButton addGestureRecognizer:otherTeamTurnoverLongPressRecognizer];
    
    UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moreEventsSwipe:)];
    [swipeRecognizer setDirection: UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown];
    [self.swipeEventsView addGestureRecognizer:swipeRecognizer];
    
    UIBarButtonItem *navBarLineButton = [[UIBarButtonItem alloc] initWithTitle: @"Line" style: UIBarButtonItemStyleBordered target:self action:@selector(goToPlayersOnFieldView)];
    self.navigationItem.rightBarButtonItem = navBarLineButton;
    
    self.throwAwayButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.throwAwayButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.throwAwayButton setTitle:@"T\nh\nr\no\nw\na\nw\na\ny" forState:UIControlStateNormal];
    
    self.otherTeamThrowAwayButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.otherTeamThrowAwayButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.otherTeamThrowAwayButton setTitle:@"T\nh\nr\no\nw\na\nw\na\ny" forState:UIControlStateNormal];
    
    self.gameOverButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.gameOverButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.gameOverButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    
    self.timeoutButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.timeoutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.timeoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    
    self.otherTeamScoreButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.otherTeamScoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.otherTeamScoreButton setTitle:@"They Scored" forState: UIControlStateNormal];
    
    self.removeEventButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    
    if (IS_IPAD) {
        self.eventsViewController = [self createEventsViewController];
        self.eventsViewController.embeddedMode = YES;
        [self addChildViewController:self.eventsViewController inSubView:self.eventsSubView];
    }
    [self updateEventViews];
    
    [self initializeDetailSelectionViewController];
    
    [self updateBroacastingNoticesWithWarning:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self addInfoButton];
    [self refreshView];
    [self configureForOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self toggleFirstTimeUsageCallouts];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = NSLocalizedString(@"Action", @"Action");
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (IS_IPAD) {
        [self configureForOrientation:toInterfaceOrientation];
    }
}

- (void)configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.topOrLeftView.frame = CGRectMake(0, 0, 500, 654);
        self.bottomOrRightView.frame = CGRectMake(501, 0, 523, 654);
        // shift action view to left
        self.actionSubView.transform = CGAffineTransformMakeTranslation(-120.0, 0.0);
    } else {
        self.topOrLeftView.frame = CGRectMake(0, 0, 768, 580);
        self.bottomOrRightView.frame = CGRectMake(0, 580, 768, 331);
        // shift action view to normal position
        self.actionSubView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    }
}

#pragma mark AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:kConfirmNewGameAlertTitle] || [alertView.title isEqualToString:kNotifyNewGameAlertTitle]) {
        if (buttonIndex == 1) { // confirmed game over
            if ([[Game getCurrentGame] isTimeBasedEnd]) {
                [[Game getCurrentGame] addEvent: [self createNextPeriodEndEvent]];
                    [self saveGame];
            }
            [[Tweeter getCurrent] tweetGameOver: [Game getCurrentGame]];
            if ([self shouldPublishToLeaguevine]) {
                [self notifyLeaguevineOfScoreIsFinal:YES];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([alertView.title isEqualToString:kNotifyNewGameAlertTitle] && [[[Game getCurrentGame] getLastEvent] causesLineChange]) {
            [self goToPlayersOnFieldView];
        }
    } else if ([alertView.title isEqualToString:kPromptForOvertimeReceiverTitle]) {  // only for time-based games
        Action nextPeriodEnd = [[Game getCurrentGame] nextPeriodEnd];
        CessationEvent* periodEndEvent;
        BOOL isReceiving = buttonIndex == 0;
        if (nextPeriodEnd == EndOfFourthQuarter) {
            periodEndEvent = [CessationEvent endOfFourthQuarterWithOlineStartNextPeriod:isReceiving];
        } else {
            periodEndEvent = [CessationEvent endOfOvertimeWithOlineStartNextPeriod:isReceiving];
        }
        [self addEvent:periodEndEvent];
    }
}

#pragma mark Detail Selection View

-(void)initializeDetailSelectionViewController {
    self.detailsController = [[ActionDetailsViewController alloc] init];
    // iphone uses a child controller to show the details VC.  ipad presents it modally.
    if (IS_IPAD) {
        self.detailsController.modalPresentationStyle = UIModalPresentationFormSheet;
    } else {
        [self addChildViewController:self.detailsController inSubView:self.detailSelectionView];
    }
    GameViewController* __weak weakSelf = self;
    self.detailsController.cancelBlock = ^{
        [weakSelf showDetailSelectionView:NO];
    };
}

-(void)showDetailSelectionView: (BOOL) show {
    if (IS_IPAD) {
        if (show) {
            [self presentViewController:self.detailsController animated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        if (show) {
            [UIView transitionFromView:self.normalView toView:self.detailSelectionView duration:.3 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            }];
        } else {
            [UIView transitionFromView:self.detailSelectionView toView:self.normalView duration:.3 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            }];
        }
    }
}

#pragma mark Callouts

-(BOOL)isFirstTimeGameViewUsage {
    return ![[NSUserDefaults standardUserDefaults] boolForKey: kIsNotFirstGameViewUsage];
}

- (void)infoButtonTapped {
    [self toggleInfoCallouts];
}

-(void)toggleFirstTimeUsageCallouts {
    if (self.firstTimeUsageCallouts) {
        [self.firstTimeUsageCallouts removeFromSuperview];
        self.firstTimeUsageCallouts = nil;
    } else if ([self isFirstTimeGameViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstGameViewUsage];
        
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        [calloutsView addNavControllerHelpAvailableCallout];
        self.firstTimeUsageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
    }
}

-(void)toggleInfoCallouts {
    [self toggleFirstTimeUsageCallouts];
    
    if (self.infoCalloutsView) {
        [self.infoCalloutsView removeFromSuperview];
        self.infoCalloutsView = nil;
    } else {
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        UIFont *textFont = [UIFont systemFontOfSize:14];
        if ([[Game getCurrentGame] hasEvents]) {
            if (IS_IPHONE) {
                // undo button
                [calloutsView addCallout:@"Tap to undo last event." anchor: CGPointTop(self.removeEventButton.frame) width: 100 degrees: 30 connectorLength: 80 font: textFont];
                // recents list
                [calloutsView addCallout:@"Last 3 actions.  Swipe up to see more events and make corrections." anchor: CGPointTop(self.eventView2.frame) width: 120 degrees: 50 connectorLength: 100 font: textFont];
            }
            // long press
            if (![Game getCurrentGame].isPositional) {
                CGPoint anchor = [self.view convertPoint:CGPointLeft(self.playerView2.firstButton.frame) fromView:self.playerView2];
                [calloutsView addCallout:@"Press and hold action buttons to see other options." anchor: anchor width: 90 degrees: 270 connectorLength: 70 font: textFont];
            }
        }
        // line button
        CGPoint anchor = CGPointTopRight(self.view.bounds);
        anchor.x = anchor.x - 40;
        [calloutsView addCallout:@"Tap to change players on field." anchor: anchor width: 120 degrees: 225 connectorLength: 80 font: textFont];
        
        self.infoCalloutsView = calloutsView;
        [self.view addSubview:calloutsView];
        // move the callouts off the screen and then animate their return.
        [self.infoCalloutsView slide: YES animated: NO];
        [self.infoCalloutsView slide: NO animated: YES];
    }
}

-(void)showActionButtonDidYouKnow {
    if (![Game getCurrentGame].isPositional) {
        if (self.isOffense && ![[Game getCurrentGame] hasEvents] && !self.throwAwayButton.hidden) {
            [self showThrowawayPressCallout];
        } else if (!self.isOffense && [[Game getCurrentGame] hasOneEvent]) {
            [self showDeLongPressCallout];
        }
    }
}

-(void)showDeLongPressCallout {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kHasUserSeenDeLongPressCallout]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kHasUserSeenDeLongPressCallout];
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];

        CGPoint anchor = [self.playerView3 convertPoint:[self.playerView3 firstButtonCenter] toView:self.view];
        [calloutsView addCallout:@"Did you know?\nYou can record a Callahan by tap-and-holding the D button." anchor: anchor width: 120 degrees: 110 connectorLength: 95 font: [UIFont systemFontOfSize:14]];
        
        self.infoCalloutsView = calloutsView;
        [self.view addSubview:calloutsView];
        // move the callouts off the screen and then animate their return.
        [self.infoCalloutsView slide: YES animated: NO];
        [self.infoCalloutsView slide: NO animated: YES];
    }
}

-(void)showThrowawayPressCallout {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kHasUserSeenThrowawayLongPressCallout]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kHasUserSeenThrowawayLongPressCallout];
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGPoint anchor = CGPointMake(CGRectGetMaxX([self.playerView3 convertRect:self.playerView3.frame toView:self.view]), self.throwAwayButton.center.y);
        [calloutsView addCallout:@"Did you know?\nYou can record other turnover types by tap-and-holding the Throwaway button." anchor: anchor width: 140 degrees: 250 connectorLength: 125 font: [UIFont systemFontOfSize:14]];
        
        self.infoCalloutsView = calloutsView;
        [self.view addSubview:calloutsView];
        // move the callouts off the screen and then animate their return.
        [self.infoCalloutsView slide: YES animated: NO];
        [self.infoCalloutsView slide: NO animated: YES];
    }
}


#pragma mark - Game Auto Upload

- (void) warnAboutAutoGameUploadIfErrors {
    if ([[GameAutoUploader sharedUploader] isAutoUploading] && [GameAutoUploader sharedUploader].errorOnLastUpload) {
        CloudRequestStatus* errorStatus = [GameAutoUploader sharedUploader].lastUploadStatus;
        [[GameAutoUploader sharedUploader] resetErrorsOnLastUpload];
        
        // only warn the user if it is a recent error (don't want to bother them about ancient history)
        BOOL isRecentError = ABS([errorStatus.timestamp timeIntervalSinceNow]) < 3600 * 3; // within 3 hours
        // don't warn the user again if we just warned them
        BOOL wasJustWarned = self.lastAutoUploadWarning != nil && ABS([self.lastAutoUploadWarning timeIntervalSinceNow]) < 60; // 1 minute
        
        if (isRecentError && !wasJustWarned) {
            NSString* instructions = (errorStatus.code == CloudRequestStatusCodeUnauthorized) ?
                @"It appears you need to refresh your signon.  Please go to the Website tab and toggle the Game Uploading switch" :
                @"Please check your network connectivity or turn-off auto-uploading (Website tab, Game Uploading switch)";
            self.lastAutoUploadWarning = [NSDate date];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: kAutoUploadErrorTitle
                                  message: [NSString stringWithFormat: @"Game Uploading is set to \"Auto\" but we are receiving errors when attempting to upload the game.\n\n%@.", instructions]
                                  delegate: nil
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
            
        };
    }
}

#pragma mark - GameHistoryControllerDelegate

- (void) eventHistoryUndoRequested {
    [self removeEventClicked: nil];
}

- (void) eventHistoryUpdated {
    [self eventsUpdated];
}

#pragma mark - Subclass support

-(void)eventsUpdated {
    // no-op...subclasses can re-implement
}

@end
    
