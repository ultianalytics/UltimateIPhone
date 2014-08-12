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
#import "UIScrollView+Utilities.h"

@implementation GamesPlayedController
@synthesize gameDescriptions,gamesTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Games", @"Games");
    }
    return self;
}

-(void)goToAddGame {
    [self goToGameAsNew:YES];
}

-(void)goToGameAsNew: (BOOL)isNew {
    Game* game = isNew ? [[Game alloc] init] : [Game getCurrentGame];
    if (IS_IPAD) {
        if (isNew) {
            GameDetailViewController* addGameController = [[GameDetailViewController alloc] init];
            addGameController.game= game;
            addGameController.isModalAddMode = YES;
            [self registerDetailControllerListener:addGameController];
            UINavigationController* addGameNavController = [[UINavigationController alloc] initWithRootViewController:addGameController];
            addGameNavController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:addGameNavController animated:YES completion:nil];
        } else {
            [self selectCurrentGameAnimated: NO];
        }
    } else {
        GameDetailViewController* gameSummaryController = [[GameDetailViewController alloc] init];
        gameSummaryController.game = game;
        [self.navigationController pushViewController:gameSummaryController animated:YES];
    }
}

-(void)reset {
    [self retrieveGameDescriptions];
    if (![Game getCurrentGameId] && [self.gameDescriptions count] > 0) {
        [Game setCurrentGame:[self.gameDescriptions[0] gameId]];
    }
    [self.gamesTableView reloadData];
    if (IS_IPAD) {
        [self selectCurrentGameAnimated: NO];
    }
}

-(void)retrieveGameDescriptions {
    // make array of descriptions so we don't have to crack open the game objects as we scroll the list
    self.gameDescriptions = [Game retrieveGameDescriptionsForCurrentTeam];
}

#pragma mark - Table delegate

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
        CGRect rect = CGRectMake(16, 16, 210, 30);
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
        rect = CGRectMake(16, 6, 210, 14);
        label = [[UILabel alloc] initWithFrame:rect];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:12];
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
    
    if (![gameDesc.gameId isEqualToString: [Game getCurrentGameId]]) {
        [Game setCurrentGame:gameDesc.gameId];
    }
    
    if (IS_IPAD) {
        [self.gamesTableView reloadData];  // reload to display current team in correct color
    }
    
    [self goToGameAsNew:NO];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"%@: %@", @"Games",[Team getCurrentTeam].name];
    UIBarButtonItem *navBarAddButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddGame)];
    self.navigationItem.rightBarButtonItem = navBarAddButton;
    [self.gamesTableView adjustInsetForTabBar];
    if (IS_IPAD) {
        [self reset];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if (IS_IPHONE) {
        [self reset];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - iPad (Master/Detail UX)

-(void)setDetailController:(GameDetailViewController *)detailController {
    _detailController = detailController;
    [self registerDetailControllerListener: detailController];
}

-(void)selectCurrentGameAnimated: (BOOL)animated {
    if ([self.gameDescriptions count] > 0) {
        NSString* gameId = [Game getCurrentGame].gameId;
        int gameIndex = 0;
        for (int row = 0; row < [self.gameDescriptions count]; row++) {
            if ([[self.gameDescriptions[row] gameId] isEqualToString:gameId]) {
                gameIndex = row;
                break;
            }
        }
        [self.gamesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:gameIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        if (![self.detailController.game.gameId isEqualToString:gameId]) {
            self.detailController.game = [Game getCurrentGame];
        }
    }
}

-(void)registerDetailControllerListener:(GameDetailViewController *)detailController {
    __typeof(self) __weak weakSelf = self;
    detailController.gameChangedBlock = ^(CRUD crud) {
        GameDescription* existingGameDescription = nil;
        int existingGameDescriptonIndex = 0;
        if (crud == CRUDUpdate) {
            NSString* currentGameId = [Game getCurrentGameId];
            for (GameDescription* gameDescription in self.gameDescriptions) {
                if ([gameDescription.gameId isEqualToString:currentGameId]) {
                    existingGameDescription = gameDescription;
                    break;
                }
                existingGameDescriptonIndex++;
            }
            [existingGameDescription populateFromGame:[Game getCurrentGame] usingDateFormatter:[GameDescription startDateFormatter]];
            [self.gamesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:existingGameDescriptonIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [weakSelf reset];
        }
        if (crud == CRUDAdd) {
            [self dismissViewControllerAnimated:NO completion:^{
                [self.detailController goToActionView];
            }];
        }
    };
}


@end
