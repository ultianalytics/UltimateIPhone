//
//  SecondViewController.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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

#define kConfirmNewGameAlertTitle @"Confirm Game Over"
#define kNotifyNewGameAlertTitle @"Game Over?"
#define kNoInternetAlertTitle @"No Internet Access"

#define kIsNotFirstGameViewUsage @"IsNotFirstGameViewUsage"

@interface GameViewController()

@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;

-(void) goToPlayersOnFieldView;
-(void) goToHistoryView: (BOOL) curl;
-(void) goToHistoryViewRight;
-(void) setOffense: (BOOL) isOffense;
-(PlayerView*) findPlayerView: (Player*) player;
-(PlayerView*) findSelectedPlayerView;
-(void) populatePlayers;
-(void) addEvent: (Event*) event;
-(void) updateEventViews;
-(void) initializeSelected;
-(void) refreshTitle: (Event*) event;
-(void) updateNavBarTitle;
-(void) updateViewFromGame: (Game*) game;
-(void) gameOverConfirm;
-(void) gameOverChallenge;
-(void) updateAutoTweetingNotice;

@end

@implementation GameViewController
@synthesize playerLabel,receiverLabel,throwAwayButton, gameOverButton,playerViews,playerView1,playerView2,playerView3,playerView4,playerView5,playerView6,playerView7,playerViewTeam,otherTeamScoreButton,eventView1,
    eventView2,eventView3, removeEventButton, swipeEventsView, hideReceiverView, tweetingLabel, firstTimeUsageCallouts;

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
        DefenseEvent* event = [[DefenseEvent alloc] initDefender:player action:action];
        [self addEvent: event];                       
    }
}

- (void) passerSelected: (Player*) player view: (PlayerView*) view {
    if (isOffense) {
        self.hideReceiverView.hidden = YES;
    }
    PlayerView* oldSelected = [self findSelectedPlayerView];
    if (oldSelected) {
        [oldSelected makeSelected:NO];
    }
    [view makeSelected:YES];
}

-(void) addEvent: (Event*) event {
    [[Game getCurrentGame] addEvent: event];  
    [self updateEventViews];
    [self refreshTitle: event];
    [[Game getCurrentGame] save]; 
    if ([event causesDirectionChange]) {
        [self setOffense: [[Game getCurrentGame] arePlayingOffense]];
        if ([[Game getCurrentGame] doesGameAppearDone]) {
            [self gameOverChallenge];
        } else if ([event causesLineChange]) {
            [self goToPlayersOnFieldView];
        }
    }
    [self updateViewFromGame:[Game getCurrentGame]];
}

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

-(void) goToPlayersOnFieldView {
    PickPlayersController* pickPlayersController = [[PickPlayersController alloc] init];
    pickPlayersController.game = [Game getCurrentGame];
    [self.navigationController pushViewController:pickPlayersController animated:YES];
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

-(IBAction)switchSidesClicked: (id) sender {
    [self setOffense: !isOffense];
}

-(IBAction) gameOverButtonClicked: (id) sender {
    [self gameOverConfirm];
}

-(IBAction)otherTeamScoreClicked: (id) sender {
    DefenseEvent* event = [[DefenseEvent alloc] initAction:Goal];
    [self addEvent: event];  
}

-(void) setOffense: (BOOL) shouldBeOnOffense {
    isOffense = shouldBeOnOffense;
    self.receiverLabel.hidden = !isOffense;
    self.throwAwayButton.hidden = !isOffense;
    self.otherTeamScoreButton.hidden = isOffense;
    self.hideReceiverView.hidden = YES;
    [self.playerLabel setText: isOffense ? @"Passer" : @"Defender"];
    [self.playerView1 setIsOffense:isOffense];
    [self.playerView2 setIsOffense:isOffense];
    [self.playerView3 setIsOffense:isOffense];
    [self.playerView4 setIsOffense:isOffense];
    [self.playerView5 setIsOffense:isOffense];
    [self.playerView6 setIsOffense:isOffense];
    [self.playerView7 setIsOffense:isOffense];
    [self.playerViewTeam setIsOffense:isOffense];
    [self populatePlayers];
    [self initializeSelected];
     
}

- (void) populatePlayers {
    PlayerView* previousSelected = [self findSelectedPlayerView];
    Player* previousSelectedPlayer = previousSelected ? previousSelected.player : nil;
    NSArray* players = [[Game getCurrentGame] getCurrentLineSorted];
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
            self.hideReceiverView.hidden = NO;
        }
    }
}

-(IBAction)throwAwayButtonClicked: (id) sender {
    PlayerView* oldSelected = [self findSelectedPlayerView];
    if (oldSelected) {
        [oldSelected makeSelected:NO];
    }
    [playerViewTeam makeSelected:YES];
    Player* passer = oldSelected.player;
    OffenseEvent* event = [[OffenseEvent alloc] initPasser:passer action:Throwaway];
    [self addEvent: event];    
}


- (void)moreEventsSwipe:(UISwipeGestureRecognizer *)recognizer { 
    [self goToHistoryView: YES];
}

- (void) updateAutoTweetingNotice {
    self.tweetingLabel.hidden = ![Tweeter getCurrent].isTweetingEvents;
    if ([[Tweeter getCurrent] isTweetingEvents] && 
        [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: kNoInternetAlertTitle
                              message: @"Warning: You are auto-tweeting but we can't reach the internet to send the tweets."
                              delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - View lifecycle

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
    // use a smaller font for nav bat title
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont boldSystemFontOfSize:16.0], UITextAttributeFont, nil]];
    
    self.playerViews = [[NSMutableArray alloc] initWithObjects:self.playerView1, self.playerView2,self.playerView3,self.playerView4,self.playerView5,self.playerView6,self.playerView7,self.playerViewTeam,nil];
    for (PlayerView* playerView in self.playerViews) {
        playerView.actionListener = self;
    }   
    
    UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moreEventsSwipe:)];
    [swipeRecognizer setDirection: UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown];
    [self.swipeEventsView addGestureRecognizer:swipeRecognizer];
    
    UIBarButtonItem *navBarLineButton = [[UIBarButtonItem alloc] initWithTitle: @"Line" style: UIBarButtonItemStyleBordered target:self action:@selector(goToPlayersOnFieldView)];
    self.navigationItem.rightBarButtonItem = navBarLineButton;    
    
    self.throwAwayButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.throwAwayButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    self.gameOverButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.gameOverButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    self.otherTeamScoreButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.otherTeamScoreButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.otherTeamScoreButton setTitle:@"They Scored" forState: UIControlStateNormal];
    
    [self updateEventViews];
    
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
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
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
        [self addInfoButtton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showFirstTimeUsageCallouts];

}

- (void)updateNavBarTitle {
    Score score = [[Game getCurrentGame] getScore];
    NSString* leaderDescription = score.ours == score.theirs ? @"" : score.ours > score.theirs    ? @", us" :  @", them";
    NSString* navBarTitle = [NSString stringWithFormat:@"%@ (%d-%d%@)", NSLocalizedString(@"Game", @"Game"), score.ours, score.theirs, leaderDescription];
    self.navigationItem.title = navBarTitle;
}

-(void) updateViewFromGame: (Game*) game {
    if (!isOffense) {
         self.otherTeamScoreButton.hidden = [game canNextPointBePull] ? YES : NO;
    }
    for (PlayerView* playerView in playerViews) {
        [playerView update:game];
    }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:kConfirmNewGameAlertTitle] || [alertView.title isEqualToString:kNotifyNewGameAlertTitle]) {
        if (buttonIndex == 1) { // confirm game over
            [[Tweeter getCurrent] tweetGameOver: [Game getCurrentGame]];
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([alertView.title isEqualToString:kNotifyNewGameAlertTitle] && [[[Game getCurrentGame] getLastEvent] causesLineChange]) {
            [self goToPlayersOnFieldView];
        }
    } 
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = NSLocalizedString(@"Game", @"Game");
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

-(void) addInfoButtton {
    UIView *navBar = self.navigationController.navigationBar;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, navBar.frame.size.height)];
    button.center = [navBar convertPoint:navBar.center fromView:navBar.superview];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:button];
}

- (void)infoButtonTapped {
    [self showInfoCallouts];
}

-(void)showInfoCallouts {
    if (self.firstTimeUsageCallouts) {
        [self.firstTimeUsageCallouts removeFromSuperview];
    }
    CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
    
    // undo button
    [calloutsView addCallout:@"Tap to undo last event." anchor: CGPointTop(self.removeEventButton.frame) width: 100 degrees: 30 connectorLength: 80];
    // recents list
    [calloutsView addCallout:@"Last 3 actions.  Swipe up to see more events." anchor: CGPointTop(self.eventView2.frame) width: 120 degrees: 45 connectorLength: 80];
    // line button
    CGPoint anchor = CGPointTopRight(self.view.bounds);
    anchor.x = anchor.x - 40;
    [calloutsView addCallout:@"Tap to change players on field." anchor: anchor width: 120 degrees: 225 connectorLength: 80];    
    
    [self.view addSubview:calloutsView];
}

-(void)showFirstTimeUsageCallouts {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kIsNotFirstGameViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstGameViewUsage];
        
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        [calloutsView addNavControllerHelpAvailableCallout];  
        self.firstTimeUsageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
    }

}

@end
