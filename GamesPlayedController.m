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

-(void)retrieveGameDescriptions {
    // make array of descriptions so we don't have to crack open the game objects as we scroll the list
    NSMutableArray* descriptions = [[NSMutableArray alloc] init];
    NSArray* fileNames = [Game getAllGameFileNames: [Team getCurrentTeam].teamId];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE MMM d h:mm a"];
    for (NSString* gameId in fileNames) {
        Game* game = [Game readGame:gameId];
        GameDescription* gameDesc = [[GameDescription alloc] init];
        gameDesc.gameId = game.gameId;
        gameDesc.startDate = game.startDateTime;
        gameDesc.formattedStartDate = [dateFormat stringFromDate:game.startDateTime];
        gameDesc.opponent = game.opponentName;
        gameDesc.score = [game getScore];
        gameDesc.formattedScore = [NSString stringWithFormat:@"%d-%d", gameDesc.score.ours, gameDesc.score.theirs];
        [descriptions addObject:gameDesc];
        NSString* tournament = game.tournamentName;
        gameDesc.tournamentName = tournament == nil ? nil : [tournament stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    // sort
    self.gameDescriptions = [descriptions sortedArrayUsingComparator:^(id a, id b) {
        NSDate *first = ((GameDescription*)a).startDate;
        NSDate *second = ((GameDescription*)b).startDate;
        return [first compare:second];
    }];
    // descending
    self.gameDescriptions = [[self.gameDescriptions reverseObjectEnumerator] allObjects];
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
    
    static NSString* STD_ROW_TYPE = @"stdRowType";
    
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
        label.textAlignment = UITextAlignmentRight;
        label.textColor = [ColorMaster getWinScoreColor];
        
        // (2.) add the tournament/time label
        rect = CGRectMake(5, 2, 200, 8);
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
    tournamentAndTimeLabel.text = game.tournamentName == nil? game.formattedStartDate : [NSString stringWithFormat:@"%@, %@", game.tournamentName, game.formattedStartDate];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    NSUInteger row = [indexPath row]; 
    GameDescription* gameDesc = [self.gameDescriptions objectAtIndex:row];
    
    GameDetailViewController* gameSummaryController = [[GameDetailViewController alloc] init];
    Game* gameToView = [gameDesc.gameId isEqualToString: [Game getCurrentGameId]] ? [Game getCurrentGame] : [Game readGame:gameDesc.gameId];
    gameSummaryController.game = gameToView;
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
    self.gamesTableView.separatorColor = [ColorMaster getTableListSeparatorColor];
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont boldSystemFontOfSize:16.0], UITextAttributeFont, nil]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Games", @"Games"),[Team getCurrentTeam].name];
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
