//
//  GamesPlayedController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GamesPlayedController.h"
#import "Game.h"
#import "GameDescription.h"
#import "ColorMaster.h"
#import "Preferences.h"
#import "GameDetailViewController.h"
#import "Team.h"

@implementation GamesPlayedController
@synthesize gameDescriptions,gamesTableView;

-(void)goToAddGame {
    GameDetailViewController* gameStartController = [[GameDetailViewController alloc] init];
    gameStartController.game = [[Game alloc] init];
    [self.navigationController pushViewController:gameStartController animated:YES]; 
}

-(void)retrieveGameDescriptions {
    // make array of descriptions so we don't have to crack open the game objects as we scroll the list
    self.gameDescriptions = [Game retrieveGameDescriptionsForCurrentTeam];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Games", @"Games");
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gameDescriptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    GameDescription* game = [self.gameDescriptions objectAtIndex:row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView* contentView = cell.contentView;
        // remove the normal views
        for (UIView *view in [contentView subviews]) {
            [view removeFromSuperview];
        }
        
        // (0.) add the opponent label
        CGRect rect = CGRectMake(5, 10, 240, 30);
        UILabel* label = [[UILabel alloc] initWithFrame:rect];
        label.backgroundColor = [UIColor clearColor];
        [contentView addSubview:label];
        label.font = [UIFont boldSystemFontOfSize:18];
        
        // (1.) add the score label
        rect = CGRectMake(225, 10, 55, 30);
        label = [[UILabel alloc] initWithFrame:rect];
        label.backgroundColor = [UIColor clearColor];
        [contentView addSubview:label];
        label.font = [UIFont boldSystemFontOfSize:18];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [ColorMaster getWinScoreColor];
        
        // (2.) add the tournament/time label
        rect = CGRectMake(5, 2, 240, 8);
        label = [[UILabel alloc] initWithFrame:rect];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:10];
        [contentView addSubview:label];
    }
   
    UILabel* opponentLabel = [cell.contentView.subviews objectAtIndex:0];
    UILabel* scoreLabel = [cell.contentView.subviews objectAtIndex:1];
    UILabel* tournamentAndTimeLabel = [cell.contentView.subviews objectAtIndex:2];
    
    opponentLabel.text = [NSString stringWithFormat: @"vs. %@", game.opponent];
    opponentLabel.textColor = [game.gameId isEqualToString:[Preferences getCurrentPreferences].currentGameFileName] ? 
        [ColorMaster getActiveGameColor] : [UIColor blackColor];
    scoreLabel.text = game.formattedScore;
    scoreLabel.textColor = game.score.ours == game.score.theirs ? [UIColor blackColor] : 
        (game.score.ours > game.score.theirs ? [ColorMaster getWinScoreColor] :  [ColorMaster getLoseScoreColor]);
    tournamentAndTimeLabel.text = game.tournamentName == nil? game.formattedStartDate : [NSString stringWithFormat:@"%@, %@", game.formattedStartDate, game.tournamentName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    NSUInteger row = [indexPath row]; 
    GameDescription* gameDesc = [self.gameDescriptions objectAtIndex:row];
    
    GameDetailViewController* gameSummaryController = [[GameDetailViewController alloc] init];
    if (![gameDesc.gameId isEqualToString: [Game getCurrentGameId]]) {
        [Game setCurrentGame:gameDesc.gameId];
    }
    gameSummaryController.game = [Game getCurrentGame];
    [self.navigationController pushViewController:gameSummaryController animated:YES];
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
    UIBarButtonItem *navBarAddButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddGame)];
    self.navigationItem.rightBarButtonItem = navBarAddButton; 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = [NSString stringWithFormat:@"%@: %@", @"Games",[Team getCurrentTeam].name];
    [self retrieveGameDescriptions];
    [self.gamesTableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
