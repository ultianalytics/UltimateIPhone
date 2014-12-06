//
//  GamesViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/10/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "GamesViewController.h"
#import "Game.h"
#import "GameDescription.h"
#import "ColorMaster.h"
#import "Preferences.h"
#import "GameDetailViewController.h"
#import "Team.h"
#import "UIScrollView+Utilities.h"
#import "GameTableViewCell.h"
#import "GameViewController.h"
#import "GameAutoUploader.h"
#import "WindSpeedClient.h"

@interface GamesViewController ()

@property (nonatomic, strong) NSArray* gameDescriptions;
@property (nonatomic, strong) IBOutlet UITableView* gamesTableView;
@property (nonatomic, strong) IBOutlet UILabel* noGamesLabel;

@end

@implementation GamesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)goToAddGame {
    [self goToGameAsNew:YES];
}

-(void)goToGameAsNew: (BOOL)isNew {
    [[GameAutoUploader sharedUploader] flush]; // before we switch games, make sure we don't have another game with data that still needs to be posted
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
    self.navigationItem.title = [NSString stringWithFormat:@"%@: %@", @"Games",[Team getCurrentTeam].name];
    [self retrieveGameDescriptions];
    BOOL hasGames = [self.gameDescriptions count] > 0;
    if (hasGames) {
        if (![Game getCurrentGameId]) {
            [Game setCurrentGame:[self.gameDescriptions[0] gameId]];
        }
        [self.gamesTableView reloadData];
        if (IS_IPAD) {
            [self selectCurrentGameAnimated: NO];
        }
    }
    self.gamesTableView.hidden = !hasGames;
    self.noGamesLabel.hidden = hasGames;
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
    
    GameTableViewCell* cell = (GameTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GameCell"];

    cell.opponentLabel.text = [NSString stringWithFormat: @"vs. %@", game.opponent];
    cell.gameInfoLabel.text = game.tournamentName == nil? game.formattedStartDate : [NSString stringWithFormat:@"%@, %@", game.formattedStartDate, game.tournamentName];
    cell.scoreLabel.text = game.formattedScore;
    
    cell.opponentLabel.textColor = [game.gameId isEqualToString:[Preferences getCurrentPreferences].currentGameFileName] ? [ColorMaster getActiveGameColor] : [UIColor blackColor];
    cell.scoreLabel.textColor = game.score.ours == game.score.theirs ? [UIColor grayColor] :
        (game.score.ours > game.score.theirs ? [UIColor blackColor] :  [ColorMaster getLoseScoreColor]);
    
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
    UIBarButtonItem *navBarAddButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddGame)];
    self.navigationItem.rightBarButtonItem = navBarAddButton;
    [self.gamesTableView adjustInsetForTabBar];
    if (IS_IPAD) {
        [self reset];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[WindSpeedClient shared] updateWindSpeed];
    self.title = NSLocalizedString(@"Games", @"Games");
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
            [weakSelf notifyGamesChangedListener];
        }
        if (crud == CRUDAdd) {
            [self dismissViewControllerAnimated:NO completion:^{
                if (self.detailController) {
                   [self.detailController goToActionView];
                } else {
                    GameViewController* gameController = [GameDetailViewController createActionViewController];
                    UINavigationController* topNavigationController = self.topViewController ? self.topViewController.navigationController : self.navigationController;
                    [topNavigationController pushViewController:gameController animated:YES];
                }

            }];
        }
    };
}

-(void)notifyGamesChangedListener {
    if (self.gamesChangedBlock) {
        self.gamesChangedBlock();
    }
}


@end
