//
//  SecondViewController.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

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
#import <QuartzCore/QuartzCore.h>

#define kConfirmNewGameAlertTitle @"Confirm Game Over"
#define kNotifyNewGameAlertTitle @"Game Over?"
#define kPromptForOvertimeReceiverTitle @"Overtime: who will receive?"
#define kNoInternetAlertTitle @"No Internet Access"
#define kLeaguevineCredentialsRejected @"Leaguevine Signon Needed"
#define kLeaguevineGameInvalid @"Leaguevine Game Not Valid"
#define kLeaguevineError @"Error Posting To Leaguevine"

#define kIsNotFirstGameViewUsage @"IsNotFirstGameViewUsage"
#define kHasUserSeenDeLongPressCallout @"HasUserSeenDeLongPressCallout"
#define kHasUserSeenThrowawayLongPressCallout @"HasUserSeenThrowawayLongPressCallout"

@interface GameViewController()

@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;
@property (nonatomic, strong) CalloutsContainerView *infoCalloutsView;
@property (nonatomic, strong) LeaguevineClient *leaguevineClient;
@property (nonatomic, strong) IBOutlet UIView *normalView;
@property (nonatomic, strong) IBOutlet UIView *detailSelectionView;
@property (nonatomic, strong) ActionDetailsViewController* detailsController;

@end

@implementation GameViewController
@synthesize playerLabel,receiverLabel,throwAwayButton, gameOverButton,playerViews,playerView1,playerView2,playerView3,playerView4,playerView5,playerView6,playerView7,playerViewTeam,otherTeamScoreButton,eventView1,
    eventView2,eventView3, removeEventButton, swipeEventsView, hideReceiverView, firstTimeUsageCallouts,infoCalloutsView;

#pragma mark  Miscelleanous

-(void)handlePullBegin: (Player*) player {
    double currentTime = CACurrentMediaTime();
    PullLandingViewController* pullLandingVC = [[PullLandingViewController alloc] init];
    pullLandingVC.pullBeginTime = currentTime;
    pullLandingVC.completion = ^(BOOL cancelled, BOOL isOutOfBounds, long hangtimeMilliseconds) {
        [self dismissViewControllerAnimated:YES completion:^{
            if(!cancelled) {
                DefenseEvent* event = [[DefenseEvent alloc] initDefender:player action:isOutOfBounds ? PullOb : Pull];
                if (hangtimeMilliseconds > 0) {
                    event.pullHangtimeMilliseconds = hangtimeMilliseconds;
                }
                [self addEvent: event];
                [self showDidYouKnow];
            }
        }];
    };
    [self presentViewController:pullLandingVC animated:YES completion:nil];
}

-(void) addEvent: (Event*) event {
    [[Game getCurrentGame] addEvent: event];  
    [self updateEventViews];
    [self refreshTitle: event];
    [[Game getCurrentGame] save]; 
    if ([event causesDirectionChange]) {
        [self setOffense: [[Game getCurrentGame] arePlayingOffense]];
        if ([event isGoal] && [self shouldPublishScoresToLeaguevine]) {
            [self notifyLeaguevineOfScoreIsFinal:NO];
        }
        if ([event isGoal] && [[Game getCurrentGame] isNextEventImmediatelyAfterHalftime] && ![[Game getCurrentGame] isTimeBasedEnd]) {
            [PickPlayersController halftimeWarning];
            [self goToPlayersOnFieldView];
        } else if ([[Game getCurrentGame] doesGameAppearDone]) {
            [self gameOverChallenge];
        } else if ([event causesLineChange]) {
            [self goToPlayersOnFieldView];
        }
    }
    [self updateViewFromGame:[Game getCurrentGame]];
    [self notifyLeaguevineOfNewEvent:event];
}

-(void)updateEventViews {
    NSArray* lastFewEvents = [[Game getCurrentGame] getLastEvents:3];
    [self.eventView1 updateEvent: [lastFewEvents count] >= 1 ? [lastFewEvents objectAtIndex:0] : nil];
    [self.eventView2 updateEvent: [lastFewEvents count] >= 2 ? [lastFewEvents objectAtIndex:1] : nil];
    [self.eventView3 updateEvent: [lastFewEvents count] >= 3 ? [lastFewEvents objectAtIndex:2] : nil];
    self.removeEventButton.hidden = [lastFewEvents count] == 0;
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
    for (PlayerView* playerView in self.playerViews) {
        [playerView setNeedToSelectPasser: needToSelectPasser];
    }
    self.hideReceiverView.hidden = !needToSelectPasser;
}

-(void) setOffense: (BOOL) shouldBeOnOffense {
    isOffense = shouldBeOnOffense;
    self.receiverLabel.hidden = !isOffense;
    self.otherTeamScoreButton.hidden = isOffense;
    [self setNeedToSelectPasser: NO];
    [self.playerLabel setText: isOffense ? @"Passer" : @"Defender"];
    [self.playerView1 setIsOffense:isOffense];
    [self.playerView2 setIsOffense:isOffense];
    [self.playerView3 setIsOffense:isOffense];
    [self.playerView4 setIsOffense:isOffense];
    [self.playerView5 setIsOffense:isOffense];
    [self.playerView6 setIsOffense:isOffense];
    [self.playerView7 setIsOffense:isOffense];
    [self.playerViewTeam setIsOffense:isOffense];
    self.throwAwayButton.hidden = NO;
    [self setThrowAwayButtonPosition];
    [self populatePlayers];
    [self initializeSelected];
     
}

-(void)setThrowAwayButtonPosition {
    CGAffineTransform transform = isOffense ? CGAffineTransformMakeTranslation(0.0, 0.0) : CGAffineTransformMakeTranslation(-100.0, 0.0);
    self.throwAwayButton.transform = transform;
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
    if (isOffense) {
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

- (void) updateAutoTweetingNotice {
    BOOL isAutoTweeting = [Tweeter getCurrent].isTweetingEvents;
    BOOL isLeaguevinePosting = [self shouldPublishToLeaguevine];
    self.broadcast1Label.hidden = !isAutoTweeting;
    self.broadcast2Label.hidden = !isLeaguevinePosting;

    if ((isAutoTweeting || [self shouldPublishScoresToLeaguevine]) &&
        [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        NSString* broadcastTarget = isAutoTweeting ?
            isLeaguevinePosting ? @"auto-tweeting and posting scores to Leaguevine" : @"auto-tweeting" :
            @"posting scores to Leaguevine";
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: kNoInternetAlertTitle
                              message: [NSString stringWithFormat: @"Warning: You are %@ but we can't reach the internet.", broadcastTarget]
                              delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)updateNavBarTitle {
    Score score = [[Game getCurrentGame] getScore];
    NSString* leaderDescription = score.ours == score.theirs ? @"" : score.ours > score.theirs    ? @", us" :  @", them";
    NSString* navBarTitle = [NSString stringWithFormat:@"%@ (%d-%d%@)", NSLocalizedString(@"Action", @"Action"), score.ours, score.theirs, leaderDescription];
    self.navigationItem.title = navBarTitle;
}

-(void) updateViewFromGame: (Game*) game {
    if (!isOffense) {
        self.otherTeamScoreButton.hidden = [game canNextPointBeDLinePull] ? YES : NO;
        self.throwAwayButton.hidden = [game canNextPointBeDLinePull] ? YES : NO;
    }
    for (PlayerView* playerView in playerViews) {
        [playerView update:game];
    }
    [self updateGameOverButtonForTimeBasedGame];
}


#pragma mark ActionListener

- (void) action: (Action) action targetPlayer: (Player*) player fromView: (PlayerView*) view {
    if (isOffense) {
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
    if (isOffense) {
        [self setNeedToSelectPasser: NO];
        [self showDidYouKnow];
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
        if (isOffense) {
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
        if (isOffense) {
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
    Event* lastEventBefore = [[Game getCurrentGame] getLastEvent];
    [[Game getCurrentGame] removeLastEvent];
    [self updateEventViews];
    Event* lastEventAfter = [[Game getCurrentGame] getLastEvent];
    [self refreshTitle: lastEventBefore];
    [[Game getCurrentGame] save];
    if ([lastEventBefore causesDirectionChange]) {
        [self setOffense: [[Game getCurrentGame] arePlayingOffense]];
        if ([lastEventAfter causesLineChange]) {
            [self goToPlayersOnFieldView];
        }
    }
    [self initializeSelected];
    [self updateViewFromGame:[Game getCurrentGame]];
    [self notifyLeaguevineOfRemovedEvent:lastEventBefore];
}

-(IBAction)throwAwayButtonClicked: (id) sender {
    if (isOffense) {
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
    [self setOffense: !isOffense];
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

- (void)moreEventsSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self goToHistoryView: YES];
}

#pragma mark Go To Other views

-(void) goToPlayersOnFieldView {
    PickPlayersController* pickPlayersController = [[PickPlayersController alloc] init];
    pickPlayersController.hidesBottomBarWhenPushed = YES;
    pickPlayersController.game = [Game getCurrentGame];
    [self.navigationController pushViewController:pickPlayersController animated:YES];
}

-(void) goToTimeoutView {
    TimeoutViewController* timeoutController = [[TimeoutViewController alloc] init];
    timeoutController.game = [Game getCurrentGame];
    [self.navigationController pushViewController:timeoutController animated:YES];
}

-(void) goToHistoryViewRight {
    [self goToHistoryView:NO];
}

-(void) goToHistoryView: (BOOL) curl {
    GameHistoryController* historyController = [[GameHistoryController alloc] init];
    historyController.game = [Game getCurrentGame];
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

-(void) addInfoButtton {
    UIView *navBar = self.navigationController.navigationBar;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, navBar.frame.size.height)];
    button.center = [navBar convertPoint:navBar.center fromView:navBar.superview];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:button];
}

-(void)resizeForLongDisplay {
    // resize and repositon the player views to take advantage of the extra space
    CGFloat extraHeight = (568 - 480) / 8; // iphone 5 length - iphone 4 length / number of player views
    CGFloat addedHeight = 0;
    for (PlayerView* playerView in self.playerViews) {
        CGRect pvRect = playerView.frame;
        CGFloat idealViewHeight = pvRect.size.height + extraHeight;
        idealViewHeight = MIN(idealViewHeight, 40.0f);
        pvRect.size.height = idealViewHeight;
        pvRect.origin.y = pvRect.origin.y + addedHeight;
        playerView.frame = pvRect;
        addedHeight += extraHeight;
    }
    
    // resize the throwaway button to match the margins of the first and last buttons
    CGRect buttonRect = self.throwAwayButton.frame;
    buttonRect.size.height = CGRectGetMaxY(self.playerViewTeam.frame) - CGRectGetMinY(self.playerView1.frame);
    self.throwAwayButton.frame = buttonRect;
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
    
    self.playerViews = [[NSMutableArray alloc] initWithObjects:self.playerView1, self.playerView2,self.playerView3,self.playerView4,self.playerView5,self.playerView6,self.playerView7,self.playerViewTeam,nil];
    for (PlayerView* playerView in self.playerViews) {
        playerView.actionListener = self;
    }
    
    if ([UIScreen mainScreen].bounds.size.height > 480) {
        [self resizeForLongDisplay];
    }
    
    // TODO...comment to turn off long press when long press handling done
    UILongPressGestureRecognizer* turnoverLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(turnoverButtonLongPress:)];
    [self.throwAwayButton addGestureRecognizer:turnoverLongPressRecognizer];
    
    UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moreEventsSwipe:)];
    [swipeRecognizer setDirection: UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown];
    [self.swipeEventsView addGestureRecognizer:swipeRecognizer];
    
    UIBarButtonItem *navBarLineButton = [[UIBarButtonItem alloc] initWithTitle: @"Line" style: UIBarButtonItemStyleBordered target:self action:@selector(goToPlayersOnFieldView)];
    self.navigationItem.rightBarButtonItem = navBarLineButton;
    
    self.throwAwayButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.throwAwayButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.throwAwayButton setTitle:@"T\nh\nr\no\nw\na\nw\na\ny" forState:UIControlStateNormal];
    
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
    
    [self updateEventViews];
    
    [self initializeDetailSelectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateAutoTweetingNotice)
                                                 name: @"UIApplicationWillEnterForegroundNotification"
                                               object: nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![Game hasCurrentGame]) {
        GameDetailViewController* gameStartController = [[GameDetailViewController alloc] init];
        gameStartController.game = [[Game alloc] init];
        gameStartController.navigationItem.hidesBackButton = YES;
        [self.navigationController pushViewController:gameStartController animated:YES];
    } else {
        Game* game = [Game getCurrentGame];
        [self setOffense: [game arePlayingOffense]];
        [self updateEventViews];
        [self updateNavBarTitle];
        [[Game getCurrentGame] save];
        [self updateViewFromGame:[Game getCurrentGame]];
        [self updateAutoTweetingNotice];
    }
    NSString* timeoutButtonText = [NSString stringWithFormat:@"Timeouts (%d free)", [[Game getCurrentGame] availableTimeouts]];
    [self.timeoutButton setTitle:timeoutButtonText forState:UIControlStateNormal];
    [self.timeoutButton setTitle:timeoutButtonText forState:UIControlStateHighlighted];    
    [self addInfoButtton];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:kConfirmNewGameAlertTitle] || [alertView.title isEqualToString:kNotifyNewGameAlertTitle]) {
        if (buttonIndex == 1) { // confirmed game over
            if ([[Game getCurrentGame] isTimeBasedEnd]) {
                [[Game getCurrentGame] addEvent: [self createNextPeriodEndEvent]];
                [[Game getCurrentGame] save];
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

-(void)initializeDetailSelectionView {
    self.detailsController = [[ActionDetailsViewController alloc] init];
    [self addChildViewController:self.detailsController inSubView:self.detailSelectionView];
    GameViewController* __weak weakSelf = self;
    self.detailsController.cancelBlock = ^{
        [weakSelf showDetailSelectionView:NO];
    };
}

-(void)showDetailSelectionView: (BOOL) show {
    if (show) {
        [UIView transitionFromView:self.normalView toView:self.detailSelectionView duration:.3 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        }];
    } else {
        [UIView transitionFromView:self.detailSelectionView toView:self.normalView duration:.3 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        }];
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
            // undo button
            [calloutsView addCallout:@"Tap to undo last event." anchor: CGPointTop(self.removeEventButton.frame) width: 100 degrees: 30 connectorLength: 80 font: textFont];
            // recents list
            [calloutsView addCallout:@"Last 3 actions.  Swipe up to see more events and make corrections." anchor: CGPointTop(self.eventView2.frame) width: 120 degrees: 50 connectorLength: 100 font: textFont];
            // long press
            [calloutsView addCallout:@"Press and hold to see other options for an action." anchor: CGPointMake(140, 100) width: 100 degrees: 270 connectorLength: 80 font: textFont];
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

-(void)showDidYouKnow {
    if (isOffense && ![[Game getCurrentGame] hasEvents] && !self.throwAwayButton.hidden) {
        [self showThrowawayPressCallout];
    } else if (!isOffense && [[Game getCurrentGame] hasOneEvent]) {
        [self showDeLongPressCallout];
    }
}

-(void)showDeLongPressCallout {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kHasUserSeenDeLongPressCallout]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kHasUserSeenDeLongPressCallout];
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];

        CGPoint anchor = CGPointMake(155,70);
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
        
        CGPoint anchor = CGPointMake(300,70);
        [calloutsView addCallout:@"Did you know?\nYou can record other turnover types by tap-and-holding the Throwaway button." anchor: anchor width: 140 degrees: 250 connectorLength: 125 font: [UIFont systemFontOfSize:14]];
        
        self.infoCalloutsView = calloutsView;
        [self.view addSubview:calloutsView];
        // move the callouts off the screen and then animate their return.
        [self.infoCalloutsView slide: YES animated: NO];
        [self.infoCalloutsView slide: NO animated: YES];
    }
}

@end
    
