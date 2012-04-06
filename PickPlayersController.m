//
//  PickPlayersController.m
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PickPlayersController.h"
#import "Team.h"
#import "Game.h"
#import "PlayerButton.h"
#import "SoundPlayer.h"
#import "Statistics.h"
#import "ColorMaster.h"

@implementation PickPlayersController
@synthesize benchTableView, benchTableCells, fieldView, fieldButtons, benchButtons, lastLineButton, pointsPerPlayer, pointFactorPerPlayer,errorMessageLabel,game;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString* title = [self shouldDisplayOline] ? @"O-Line" :  @"D-Line";
        self.title = NSLocalizedString(title, title);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) intializeForLineType {
    NSString* title = [self shouldDisplayOline] ? @"Last O-Line" :  @"Last D-Line";
    [self.lastLineButton setTitle:title forState:UIControlStateNormal];
}

-(void) loadPlayerButtons {
    self.fieldButtons = [self initializePlayersViewCount: 7 players: 
                         [[Game getCurrentGame] getCurrentLineSorted] isField: true];
    self.benchButtons = [self initializePlayersViewCount: [[Team getCurrentTeam].players count] players: [self getCurrentTeamPlayers] isField: false];
    
}

-(void)updateBenchView {
    NSArray* allPlayers = [self getCurrentTeamPlayers];
    NSSet* currentFieldPlayers = [[NSSet alloc] initWithArray:[[Game getCurrentGame] getCurrentLineSorted]]; 
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

- (void)clearClicked:(id)button
{
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

- (void)fieldPlayerClicked:(id)fieldButton
{
    Player* player = [fieldButton getPlayer];
    [[[Game getCurrentGame] getCurrentLine] removeObject:player];

    [fieldButton setPlayer:nil];
    
    PlayerButton* benchButton = [self findBenchButton:player];
    if (benchButton != nil) {  // if user deleted the player we just drop the player now
        [self setPlayer:player inButton:benchButton];
    }
}

- (void)benchPlayerClicked:(id)benchButton {
    if ([[[Game getCurrentGame] getCurrentLine] count] >= 7) {
        [SoundPlayer playMaxPlayersAlreadyOnField];
    } else if (![self willGenderBeUnbalanced: [benchButton getPlayer]]) {
        for (int i = 0; i < 7; i++) {
            PlayerButton* fieldButton = [fieldButtons objectAtIndex:i];
            if (![fieldButton getPlayer]) {
                Player* player = [benchButton getPlayer];
                [self setPlayer:player inButton:fieldButton];
                [self setPlayer:nil inButton:benchButton];
                [self updateGameCurrentLineFromView];
                break;
            }
        }
    } 
}

-(BOOL)willGenderBeUnbalanced: (Player*) newPlayer {
    if ([Team getCurrentTeam].isMixed) {
        int male = 0;
        int female = 0;
        newPlayer.isMale ? male++ : female++;
        for (int i = 0; i < 7; i++) {
            PlayerButton* fieldButton = [fieldButtons objectAtIndex:i];
            Player* player = [fieldButton getPlayer];
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
        if ([playerButton getPlayer] != nil) {
            [[[Game getCurrentGame] getCurrentLine] addObject:[playerButton getPlayer]];
        }
    }
}

-(PlayerButton*) findBenchButton: (Player*) player {
     int playerCount = [[Team getCurrentTeam].players count];
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

- (NSMutableArray*) initializePlayersViewCount: (int)numberOfButtons players: (NSArray*) players isField: (BOOL)isField {
    NSMutableArray* buttons = [[NSMutableArray alloc] init];
    if (isField) {
        [self clearFieldView];
    } else {
        self.benchTableView.backgroundColor = [ColorMaster getBenchRowColor];
        benchTableCells = [[NSMutableArray alloc] init];
    }
    
    int maxColumns = 4;
    int leftSlackMargin = 1;
    int buttonMargin = 2;
    int buttonWidth = 77;
    int buttonHeight = 40;
    int rowWidth = leftSlackMargin + (maxColumns * (buttonWidth + buttonMargin));
    int rowHeight = buttonHeight + buttonMargin;

    int y = buttonMargin;
    int x = isField ?  leftSlackMargin + buttonMargin + buttonWidth + buttonMargin : leftSlackMargin + buttonMargin;
    int columnCount = isField ? 1 : 0;
    UIView* rowView = nil;
    UITableViewCell* tableCell = nil;
    for (int i = 0; i <numberOfButtons; i++) {
        if (columnCount >= maxColumns) {
            columnCount = 0;
            x = buttonMargin + leftSlackMargin;
            y = y + buttonMargin + buttonHeight;
            rowView = nil;
        }
        if (rowView == nil) {
            rowView = [[UIView alloc] initWithFrame:CGRectMake(0, isField ? y : 0, rowWidth, rowHeight)];
            if (isField) {
                [fieldView addSubview:rowView];
            } else {
                tableCell = [[UITableViewCell alloc] init];
                [tableCell addSubview:rowView];
                rowView.backgroundColor = [ColorMaster getBenchRowColor];
                tableCell.backgroundColor = [ColorMaster getBenchRowColor];
                [benchTableCells addObject: tableCell];
            }
        }
        CGRect buttonRectangle = CGRectMake(x, 0, buttonWidth, buttonHeight);
        PlayerButton* button = [[PlayerButton alloc] init];
        [button setOnField:isField];
        [button setFrame:buttonRectangle];
        [self setPlayer: i < [players count] ? [players objectAtIndex:i] : nil inButton: button];
        [button setClickListener: self];
        [buttons addObject:button];
        [rowView addSubview:button];
        x = x + buttonWidth + buttonMargin;
        columnCount++;
    }
    
    if (!isField) {
        [self.benchTableView reloadData];
    }
    return buttons;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [benchTableCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    return [benchTableCells objectAtIndex: row];
}

-(void)setPlayer: (Player*) player inButton: (PlayerButton*) button {
    if (player == nil) {
        [button setPlayer:nil];
    } else {
        PlayerStat* playerPoints = [pointsPerPlayer objectForKey: [player getId]];
        NSNumber* pointFactor = [pointFactorPerPlayer objectForKey: [player getId]];
        [button setPlayer:player points:(playerPoints == nil ? 0 : playerPoints.number.intValue) pointFactor:(pointFactor == nil ? 0 : pointFactor.floatValue)];
    }
    
}

- (void) loadPlayerStats {
    self.pointsPerPlayer = [Statistics pointsPerPlayer:[Game getCurrentGame] includeOffense:YES includeDefense:YES];
    self.pointFactorPerPlayer = [Statistics pointsPlayedFactorPerPlayer:[Game getCurrentGame] team:[Team getCurrentTeam]];
}

- (NSArray*) getCurrentTeamPlayers {
    return [[Team getCurrentTeam].players sortedArrayUsingSelector:@selector(compare:)];
}

-(void)dumpBenchView {
    NSLog(@".");
    NSLog(@"************* Current bench view buttons ***************");
    NSLog(@".");
    for (int i = 0; i < [self.benchButtons count]; i++) {
        PlayerButton* button = [self.benchButtons objectAtIndex:i];
        NSLog(@"%@", button);
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([Game getCurrentGame] !=  nil && [[Game getCurrentGame].gameId isEqualToString: game.gameId]) {
        [super viewWillAppear:animated];
        [self loadPlayerStats];
        [self loadPlayerButtons];
        [self updateBenchView];
        [self intializeForLineType];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void) showGenderImbalanceIndicator: (BOOL) isMaleImbalance {
    [errorMessageLabel setTextColor: isMaleImbalance ? [UIColor blueColor] : [UIColor redColor]];
    errorMessageLabel.text = isMaleImbalance ? @"too many guys" : @"too many gals";
    errorMessageLabel.alpha = 1;
    [UIView animateWithDuration:1.5 animations:^{errorMessageLabel.alpha = 0;}];
}


@end


