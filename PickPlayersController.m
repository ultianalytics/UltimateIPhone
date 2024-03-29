//
//  PickPlayersController.m
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "PickPlayersController.h"
#import "Team.h"
#import "Game.h"
#import "PlayerButton.h"
#import "SoundPlayer.h"
#import "Statistics.h"
#import "ColorMaster.h"
#import "Player.h"
#import "PlayerButton.h"
#import "PlayerStat.h"
#import "Event.h"
#import "Wind.h"
#import "Tweeter.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "UPoint.h"
#import "SubstitutionViewController.h"
#import "PlayerSubstitution.h"
#import "UIView+Convenience.h"
#import "LeaguevineEventQueue.h"
#import "NSArray+Utilities.h"
#import "PickPlayersRowView.h"

#define kIsNotFirstPickPlayerViewUsage @"IsNotFirstPickPlayerViewUsage"
#define kSetHalfimeText @"Halftime"
#define kUndoHalfimeText @"Undo Half"

@interface PickPlayersController()

@property (nonatomic, weak) IBOutlet UITableView* benchTableView;
@property (nonatomic, weak) IBOutlet UIView *substitutionsView;
@property (nonatomic, weak) IBOutlet UIButton *undoSubstitutionButton;
@property (nonatomic, weak) IBOutlet UITableView *substitutionTableView;
@property (nonatomic, weak) IBOutlet UIView* fieldView;
@property (nonatomic, weak) IBOutlet UIButton* lastLineButton;
@property (nonatomic, weak) IBOutlet UIButton *clearButton;
@property (nonatomic, weak) IBOutlet UIButton *substitutionButton;
@property (nonatomic, weak) IBOutlet UILabel* errorMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel* goalScoredOverlay;

@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;
@property (nonatomic, strong) CalloutsContainerView *infoCalloutsView;

@end

@implementation PickPlayersController
@synthesize benchTableView, benchTableCells, fieldView, fieldButtons, benchButtons, lastLineButton, pointsPerPlayer, pointFactorPerPlayer,errorMessageLabel,game,firstTimeUsageCallouts,infoCalloutsView;


#pragma mark Initializtion

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)populateUI {
    [[Game getCurrentGame] resetCurrentLine];
    [self loadPlayerButtons];
    [self updateBenchView];
    [self populateLineType];
    [self showHideButtons];
    [self configureSubstitutionsView];
}

-(void)showHideButtons {
    BOOL hasPointStarted = [self.game isPointInProgress];
    self.lastLineButton.hidden = hasPointStarted;
    self.clearButton.hidden = hasPointStarted;
    self.substitutionButton.hidden = !hasPointStarted;
}

- (void) populateLineType {
    NSString* title = [self shouldDisplayOline] ? @"Last O-Line" :  @"Last D-Line";
    [self.lastLineButton setTitle:title forState:UIControlStateNormal];
    NSString* viewTitle = [self shouldDisplayOline] ? @"O-Line" :  @"D-Line";
    self.title = viewTitle;
}

-(void) loadPlayerButtons {
    self.fieldButtons = [self initializePlayersViewCount: 7 players: 
                         [[Game getCurrentGame] currentLineSorted] isField: true];
    NSArray* currentPlayers = [self getCurrentTeamPlayers];
    currentPlayers = [Team getCurrentTeam].isDiplayingPlayerNumber ?
        [currentPlayers sortedArrayUsingSelector:@selector(compareUsingNumber:)] :
        [currentPlayers sortedArrayUsingSelector:@selector(compare:)];
    self.benchButtons = [self initializePlayersViewCount: (int)[currentPlayers count] players: currentPlayers isField: false];
}

- (void) loadPlayerStats {
    self.pointsPerPlayer = [Statistics pointsPerPlayer:[Game getCurrentGame] includeOffense:YES includeDefense:YES];
    self.pointFactorPerPlayer = [Statistics pointsPlayedFactorPerPlayer:[Game getCurrentGame]];
}

- (NSMutableArray*) initializePlayersViewCount: (int)numberOfButtons players: (NSArray*) players isField: (BOOL)isField {
    NSMutableArray* buttons = [[NSMutableArray alloc] init];
    if (isField) {
        [self clearFieldView];
    } else {
        benchTableCells = [[NSMutableArray alloc] init];
    }
    
    int maxButtonsPerRow = IS_IPAD ? 6 : 4;
    int buttonMargin = 2;
    int buttonHeight = 40;
    int rowWidth = self.view.boundsWidth;
    int rowHeight = buttonHeight + buttonMargin;
    
    int y = buttonMargin;
    int columnCount = isField ? 1 : 0;
    PickPlayersRowView* rowView = nil;
    UITableViewCell* tableCell = nil;
    for (int i = 0; i <numberOfButtons; i++) {
        if (columnCount >= maxButtonsPerRow) {
            columnCount = 0;
            y = y + buttonMargin + buttonHeight;
            rowView = nil;
        }
        if (rowView == nil) {
            rowView = [[PickPlayersRowView alloc] initWithFrame:CGRectMake(0, isField ? y : 0, rowWidth, rowHeight)];
            rowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            rowView.maxButtonsPerRow = maxButtonsPerRow;
            rowView.buttonHeight = 40;
            rowView.buttonMargin = buttonMargin;
            if (isField) {
                [fieldView addSubview:rowView];
            } else {
                tableCell = [[UITableViewCell alloc] init];
                [tableCell.contentView addSubview:rowView];
                rowView.backgroundColor = self.benchTableView.backgroundColor;
                [benchTableCells addObject: tableCell];
            }
        }
        PlayerButton* button = [self createPlayerButton];
        button.tag = columnCount;
        [button setOnField:isField];
        [self setPlayer: i < [players count] ? [players objectAtIndex:i] : nil inButton: button];
        [button setClickListener: self];
        [buttons addObject:button];
        [rowView addSubview:button];
        columnCount++;
    }
    
    if (!isField) {
        [self.benchTableView reloadData];
    }
    return buttons;
}

-(PlayerButton*)createPlayerButton {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerButton class]) owner:nil options:nil];
    return (PlayerButton*)nibViews[0];
}

#pragma mark Field <--> Bench

-(void)updateBenchView {
    NSArray* allPlayers = [self getCurrentTeamPlayers];
    NSSet* currentFieldPlayers = [[NSSet alloc] initWithArray:[[Game getCurrentGame] currentLineSorted]];
    for (int i = 0; i < [allPlayers count]; i++) {
        Player* player = [allPlayers objectAtIndex:i];
        PlayerButton* button = [self.benchButtons objectAtIndex:i];
        [self setPlayer:[currentFieldPlayers containsObject:player] ? nil : player inButton:button];
    }
}

-(void) clearFieldView {
    NSEnumerator *e = [self.fieldView.subviews objectEnumerator];
    id playerButton;
    while (playerButton = [e nextObject]) {
        [playerButton removeFromSuperview];
    }
}

-(BOOL)willGenderBeUnbalanced: (Player*) newPlayer {
    if ([Team getCurrentTeam].isMixed) {
        int male = 0;
        int female = 0;
        newPlayer.isMale ? male++ : female++;
        for (int i = 0; i < 7; i++) {
            PlayerButton* fieldButton = [fieldButtons objectAtIndex:i];
            Player* player = fieldButton.player;
            if (player) {
                player.isMale ? male++ : female++;
                if ((male > 4 && newPlayer.isMale) || (female > 4 && !newPlayer.isMale)) {
                    [SoundPlayer playMaxPlayersAlreadyOnField];
                    [self showGenderImbalanceIndicator: male > 4];
                    return true;
                }
            }
        }
        return false;
    } 
    return false;
}

- (void) updateGameCurrentLineFromView {
    [[Game getCurrentGame] clearCurrentLine];
    for (PlayerButton* playerButton in self.fieldButtons) {
        if (playerButton.player != nil) {
            [[[Game getCurrentGame] currentLine] addObject:playerButton.player];
        }
    }
}

-(PlayerButton*) findBenchButton: (Player*) player {
     int playerCount = (int)[[self getCurrentTeamPlayers]  count];
     for (int i = 0; i < playerCount; i++) {
         PlayerButton* button = [self.benchButtons objectAtIndex:i];
         if ([[button getPlayerName] isEqualToString: player.name]) {
             return button;
         }
     }
     return nil;
}

-(BOOL)shouldDisplayOline {
    return [[Game getCurrentGame] isCurrentlyOline];
}

#pragma mark Table Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.benchTableView) {
        return [benchTableCells count];
    } else {
        return [[self.game substitutionsForCurrentPoint] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.benchTableView) {
        NSUInteger row = [indexPath row];
        return [benchTableCells objectAtIndex: row];
    } else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
        if (cell == nil) {
            cell = [self createSubstitutionTableCell];
        }
        PlayerSubstitution* playerSub = [[self.game substitutionsForCurrentPoint] objectAtIndex:[indexPath row]];
        cell.textLabel.text = [playerSub description];
        return cell;
    }
}

#pragma mark Lifecycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.substitutionsView.hidden = YES;
    self.benchTableView.rowHeight = 41;
    if (IS_IPAD) {
        [self addDoneButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([Game getCurrentGame] !=  nil && [[Game getCurrentGame].gameId isEqualToString: game.gameId]) {
        [self loadPlayerStats];
        [self populateUI];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
    [self addInfoButtton];
    if (IS_IPAD && self.flashGoal) {
        [self flashGoalScoredOverlay];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self toggleFirstTimeUsageCallouts];
    if (IS_IPAD && self.flashGoal) {
        [self performSelector:@selector(hideGoalScoredOverlay) withObject:nil afterDelay:1];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    if (self.controllerClosedBlock) {
        self.controllerClosedBlock();
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    // parent is nil if this view controller was removed (back button pressed)
    if (!parent && [self.game isLeaguevineGame] &&  self.game.publishStatsToLeaguevine) {
        [[LeaguevineEventQueue sharedQueue] submitLineChangeForGame:self.game];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark Event Handlers

- (void)clearClicked:(id)button {
    [[Game getCurrentGame] clearCurrentLine];
    [self loadPlayerButtons];
}

- (void)lastLineClicked:(id)button {
    [[Game getCurrentGame] makeCurrentLineLastLine:[self shouldDisplayOline]];
    [self loadPlayerButtons];
    [self updateBenchView];
}

- (void) buttonClicked: (id)playerButton isOnField: (BOOL) isOnField {
    if (isOnField) {
        [self fieldPlayerClicked: playerButton];
    } else {
        [self benchPlayerClicked: playerButton];
    }
}

- (void)fieldPlayerClicked:(PlayerButton*)fieldButton
{
    Player* player = fieldButton.player;
    [[[Game getCurrentGame] currentLine] removeObject:player];
    
    [fieldButton setPlayer:nil];
    
    PlayerButton* benchButton = [self findBenchButton:player];
    if (benchButton != nil) {  // if user deleted the player we just drop the player now
        [self setPlayer:player inButton:benchButton];
    }
}

- (void)benchPlayerClicked:(PlayerButton*)benchButton {
    if ([[[Game getCurrentGame] currentLine] count] >= 7) {
        [SoundPlayer playMaxPlayersAlreadyOnField];
    } else if (![self willGenderBeUnbalanced: benchButton.player]) {
        for (int i = 0; i < 7; i++) {
            PlayerButton* fieldButton = [fieldButtons objectAtIndex:i];
            if (!fieldButton.player) {
                Player* player = benchButton.player;
                [self setPlayer:player inButton:fieldButton];
                [self setPlayer:nil inButton:benchButton];
                [self updateGameCurrentLineFromView];
                break;
            }
        }
    }
}

- (IBAction)halftimeButtonClicked:(UIButton*)button {
    Event* lastEvent = [game getLastEvent];
    if ([lastEvent isGoal]) {
        [game getLastEvent].isHalftimeCause = [button.titleLabel.text isEqualToString:kSetHalfimeText];
        [self populateUI];
        if ([game getLastEvent].isHalftimeCause) {
            [[self class] halftimeWarning];
        }
    }
}

- (IBAction)substitutionButtonClicked:(id)sender {
    [self goToAddSubstitutionView];
}

- (IBAction)substitutionUndoButtonClicked:(id)sender {
    [self removeLastSubstitution];
}


#pragma mark Callouts

-(void) addInfoButtton {
    UIView *navBar = self.navigationController.navigationBar;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, navBar.frame.size.height)];
    button.center = [navBar convertPoint:navBar.center fromView:navBar.superview];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:button];
}

- (void)infoButtonTapped {
    [self toggleInfoCallouts];
}

-(void)toggleInfoCallouts {
    [self toggleFirstTimeUsageCallouts];
    
    if (self.infoCalloutsView) {
        [self.infoCalloutsView removeFromSuperview];
        self.infoCalloutsView = nil;
    } else {
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        UIFont *textFont = [UIFont systemFontOfSize:14];
        // Button color variations
        [calloutsView addCallout:@"Buttons become darker as players have more points on field." anchor: CGPointMake(100, 40) width: 110 degrees: 190 connectorLength: 150 font: textFont];
        // Prevent unbalanced teams
        [calloutsView addCallout:@"App will not allow unbalanced sexes on field if team is mixed." anchor: CGPointBottom(self.fieldView.bounds) width: 150 degrees: 150 connectorLength: 120 font: textFont];
        
        self.infoCalloutsView = calloutsView;
        [self.view addSubview:calloutsView];
        // move the callouts off the screen and then animate their return.
        [self.infoCalloutsView slide: YES animated: NO];
        [self.infoCalloutsView slide: NO animated: YES];
    }
}

-(void)toggleFirstTimeUsageCallouts {
    if (self.firstTimeUsageCallouts) {  
        [self.firstTimeUsageCallouts removeFromSuperview];
        self.firstTimeUsageCallouts = nil;
    } else if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsNotFirstPickPlayerViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstPickPlayerViewUsage];
        
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        [calloutsView addNavControllerHelpAvailableCallout];  
        self.firstTimeUsageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
    }
}

#pragma mark Goal Scored overlay (iPad only) 

-(void)flashGoalScoredOverlay {
    Event* lastEvent = [self.game getLastEvent];
    if ([lastEvent isGoal]) {
        self.goalScoredOverlay.attributedText = [self goalMessage:lastEvent];
        self.goalScoredOverlay.frame = self.navigationController.view.bounds;
        [self.navigationController.view addSubview:self.goalScoredOverlay];
    }
}

-(void)hideGoalScoredOverlay {
    [UIView transitionFromView:self.goalScoredOverlay toView:self.navigationController.view duration:.5 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCurlUp completion:^(BOOL finished) {
        [self.goalScoredOverlay removeFromSuperview];
    }];
}

-(NSAttributedString*)goalMessage: (Event*)goalEvent {
    NSString* title = [NSString stringWithFormat:@"%@ Goal%@", [goalEvent isOffense] ? [Team getCurrentTeam].name : self.game.opponentName, [goalEvent isOffense] ? @"!!" : @""];
    NSMutableAttributedString* message = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24]}];
    
    Score score = [self.game getScore];
    NSString* leaderDescription = score.ours == score.theirs ? @"tied" : score.ours > score.theirs ? [Team getCurrentTeam].name :  self.game.opponentName;
    NSString* scoreDescription = [NSString stringWithFormat:@"\n\n\nNew Score: %d-%d (%@)\n\n", score.ours, score.theirs, leaderDescription];
    NSMutableAttributedString* details = [[NSMutableAttributedString alloc] initWithString:scoreDescription attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18]}];
    
    [message appendAttributedString:details];
    
    return message;
}

#pragma mark Miscellaneous

-(void)setPlayer: (Player*) player inButton: (PlayerButton*) button {
    if (player == nil) {
        [button setPlayer:nil];
    } else {
        PlayerStat* playerPoints = [pointsPerPlayer objectForKey: [player getId]];
        NSNumber* pointFactor = [pointFactorPerPlayer objectForKey: [player getId]];
        [button setPlayer:player points:(playerPoints == nil ? 0 : playerPoints.number.floatValue) pointFactor:(pointFactor == nil ? 0 : pointFactor.floatValue)];
    }
}

- (NSArray*) getCurrentTeamPlayers {
    NSArray* activePlayers = [[Team getCurrentTeam].players filter:^BOOL(id player) {
        return ![player isAbsent];
    }];
    if ([Team getCurrentTeam].isDiplayingPlayerNumber) {
        return [activePlayers sortedArrayUsingSelector:@selector(compareUsingNumber:)];
    } else {
        return [activePlayers sortedArrayUsingSelector:@selector(compare:)];
    }
    
}

- (void) showGenderImbalanceIndicator: (BOOL) isMaleImbalance {
    [errorMessageLabel setTextColor: [ColorMaster getPlayerImbalanceColor: isMaleImbalance]];
    errorMessageLabel.backgroundColor = [UIColor blackColor];
    errorMessageLabel.text = isMaleImbalance ? @" too many males" : @" too many females";
    errorMessageLabel.alpha = 1;
    errorMessageLabel.hidden = NO;
    [UIView animateWithDuration:1.5 animations:^{
        errorMessageLabel.alpha = 0;
    } completion:^(BOOL finished) {
        errorMessageLabel.hidden = YES;
    }];
}


+(void)halftimeWarning {
    NSString* message = [[Game getCurrentGame] isCurrentlyOline] ? @"Our team will RECEIVE on the next point" : @"Our team will DEFEND on the next point";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Half Time!"
                          message: message
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    if ([[Tweeter getCurrent] isTweetingEvents]) {
        [[Tweeter getCurrent] tweetHalftimeWithoutEvent];
    }
}

#pragma mark Substitutions View

-(UITableViewCell*)createSubstitutionTableCell {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:STD_ROW_TYPE];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    return cell;
}

-(void)configureSubstitutionsView {
    self.undoSubstitutionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.undoSubstitutionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if ([[self.game substitutionsForCurrentPoint] count] > 0) {
        if (self.substitutionsView.hidden) {
        
            // move the subsitutions view below the window
            self.substitutionsView.frameY = self.substitutionsView.frameY + self.substitutionsView.frameHeight;
            
            // animate it back to the original position (and move up the bench view)
            self.substitutionsView.hidden = NO;
            [UIView animateWithDuration:1 animations:^{
                self.substitutionsView.frameY = self.substitutionsView.frameY - self.substitutionsView.frameHeight;
                self.benchTableView.frameHeight = self.benchTableView.frameHeight - self.substitutionsView.frameHeight;
            }];
        }
        [self.substitutionTableView reloadData];
    } else {
        if (!self.substitutionsView.hidden) {
            // animate the substitutions view below the window
            [UIView animateWithDuration:1 animations:^{
                self.substitutionsView.frameY = self.substitutionsView.frameY + self.substitutionsView.frameHeight;
                self.benchTableView.frameHeight = self.benchTableView.frameHeight + self.substitutionsView.frameHeight;
            } completion:^(BOOL finished) {
                // hide the window
                self.substitutionsView.hidden = YES;
                
                // reset the substitutions window to it's original location
                self.substitutionsView.frameY = self.substitutionsView.frameY - self.substitutionsView.frameHeight;
            }];
        } else {
            self.substitutionsView.hidden = YES;
        }
    }
}

-(void)goToAddSubstitutionView {
    SubstitutionViewController* subVC = [[SubstitutionViewController alloc] init];
    subVC.playersOnField = self.game.currentLine;
    subVC.completion = ^(PlayerSubstitution* addedPlayerSubstitution) {
        if (addedPlayerSubstitution) {
            [self.game addSubstitution:addedPlayerSubstitution];
            [self populateUI];
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    subVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:subVC animated:YES];
}

-(void)removeLastSubstitution {
    BOOL lineCorrectlyAdjusted = [self.game removeLastSubstitutionForCurrentPoint];
    if (!lineCorrectlyAdjusted) {
        [SoundPlayer playMaxPlayersAlreadyOnField];
        [self displayVerifyLine];
    }
    [self populateUI];
}

-(void)displayVerifyLine {
    [errorMessageLabel setTextColor: [UIColor whiteColor]];
    errorMessageLabel.backgroundColor = [UIColor blackColor];
    errorMessageLabel.text =  @"Verify Line!!";
    errorMessageLabel.alpha = 1;
    [UIView animateWithDuration:1.5 animations:^{errorMessageLabel.alpha = 0;}];
}

#pragma mark iPad only

-(void)addDoneButton {
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(closeModalDialog)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

-(void)closeModalDialog {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Debugging

-(void)dumpBenchView {
    SHSLog(@".");
    SHSLog(@"************* Current bench view buttons ***************");
    SHSLog(@".");
    for (int i = 0; i < [self.benchButtons count]; i++) {
        PlayerButton* button = [self.benchButtons objectAtIndex:i];
        SHSLog(@"%@", button);
    }
}


@end


