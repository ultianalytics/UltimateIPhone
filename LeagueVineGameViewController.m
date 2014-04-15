//
//  LeagueVineGameViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineGameViewController.h"
#import "ColorMaster.h"
#import "LeaguevineItem.h"
#import "LeaguevineClient.h"
#import "LeagueVineSelectorTournamentViewController.h"
#import "LeagueVineSelectorGameViewController.h"
#import "LeaguevineSelectorAbstractViewController.h"
#import "CloudClient.h"
#import "Team.h"
#import "LeaguevineTeam.h"
#import "LeaguevineTournament.h"
#import "LeaguevineGame.h"
#import "Game.h"
#import "Constants.h"

#define kHeaderHeight 30

@interface LeagueVineGameViewController ()

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIView *clearLeaguevineButtonView;
@property (strong, nonatomic) IBOutlet UIView *websiteButtonView;

@property (strong, nonatomic) LeaguevineClient* client;
@property (nonatomic, strong) LeaguevineTournament* leaguevineTournament;
@property (nonatomic, strong) LeaguevineGame* leaguevineGame;

- (IBAction)clearLeaguevinePressed:(id)sender;

@end

@implementation LeagueVineGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Leaguevine Game";
    }
    return self;
}

#pragma mark - Custom accessors

-(void)setGame:(Game *)game {
    _game = game;
    self.leaguevineGame = game.leaguevineGame;
    self.leaguevineTournament = self.leaguevineGame.tournament;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
}

-(void)viewDidAppear:(BOOL)animated {
    [self refresh];
}

#pragma mark Event handling

-(void)doneButtonPressed {
    if (self.selectedBlock) {
        self.selectedBlock(self.leaguevineGame);
    }
}

- (IBAction)clearLeaguevinePressed:(id)sender {
    if (self.selectedBlock) {
        self.selectedBlock(nil);
    }
}

- (IBAction)websiteButtonPressed:(id)sender {
    NSURL* url =[ NSURL URLWithString: [NSString stringWithFormat:@"http://www.leaguevine.com/games/%d/",self.leaguevineGame.itemId]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LeaguevineItem* item = indexPath.section == 0 ? self.leaguevineTournament : self.leaguevineGame;
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }

    if (indexPath.section == 0) {
        cell.textLabel.text = item ? [item listDescription] : @"Any tournament";
    } else {
        cell.textLabel.text = item ? [item shortDescription] : [NSString stringWithFormat: @"%@ not selected", [self sectionName:(int)indexPath.section]];
    }
    cell.textLabel.textColor = item ? [UIColor blackColor] : [UIColor grayColor];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, kHeaderHeight)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, kHeaderHeight)];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = uirgb(134,134,134);
    headerLabel.shadowColor = [UIColor whiteColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.text = [self sectionName:(int)section];
    [headerView addSubview:headerLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self handleLeaguevineTournamentNeedsSelection];
    } else {
        [self handleLeaguevineGameNeedsSelection];
    }
}

#pragma mark Open selector views

-(void)handleLeaguevineTournamentNeedsSelection {
    if ([self verifyConnected]) {
        LeagueVineSelectorTournamentViewController* selectionController = [[LeagueVineSelectorTournamentViewController alloc] init];
        selectionController.leaguevineClient = [self getClient];
        selectionController.season = self.team.leaguevineTeam.season;
        selectionController.selectedBlock = ^(LeaguevineItem* item){
            [self.navigationController popViewControllerAnimated:YES];
            BOOL itemChanged = self.leaguevineTournament == nil || self.leaguevineTournament.itemId != item.itemId;
            if (itemChanged) {
                self.leaguevineGame = nil;
                self.leaguevineTournament = (LeaguevineTournament*)item;
            }
        };
        [self pushSelectorController:selectionController];
    }
}

-(void)handleLeaguevineGameNeedsSelection {
    if ([self verifyConnected]) {
        LeagueVineSelectorGameViewController* selectionController = [[LeagueVineSelectorGameViewController alloc] init];
        selectionController.leaguevineClient = [self getClient];
        selectionController.tournament = self.leaguevineTournament;
        selectionController.season = self.team.leaguevineTeam.season;
        selectionController.myTeam = self.team.leaguevineTeam;
        selectionController.selectedBlock = ^(LeaguevineItem* item){
            [self.navigationController popViewControllerAnimated:YES];
            BOOL itemChanged = self.leaguevineGame == nil || self.leaguevineGame.itemId != item.itemId;
            if (itemChanged) {
                self.leaguevineGame = (LeaguevineGame*)item;
            }
        };
        [self pushSelectorController:selectionController];
    }
}


-(void)pushSelectorController: (UIViewController*) selectorController {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    [self.navigationController pushViewController:selectorController animated:YES];
}

#pragma mark - Error alerting

-(BOOL)verifyConnected {
    if ([CloudClient isConnected]) {
        return YES;
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"Error talking to Leaguevine"
                                                            message: @"Network error detected...are you connected to the internet?"
                                                           delegate: nil
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
}

#pragma mark Miscellaneous

-(LeaguevineClient*)getClient {
    if (!self.client) {
        self.client = [[LeaguevineClient alloc] init];
    }
    return self.client;
}

-(NSString*)sectionName: (int) section {
    return section == 0 ? @"Tournament" : @"Game";
}

-(void)addDoneButton {
    UINavigationItem* currentNavItem = self.navigationController.navigationBar.topItem;
    currentNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
}

-(void)removeDoneButton {
    UINavigationItem* currentNavItem = self.navigationController.navigationBar.topItem;
    currentNavItem.rightBarButtonItem = nil;
}

-(void)refresh {
    [self.mainTableView reloadData];
    if (self.leaguevineGame) {
        [self addDoneButton];
    } else {
        [self removeDoneButton];
    }
    self.clearLeaguevineButtonView.hidden = !self.game.leaguevineGame;
    self.websiteButtonView.hidden = !self.leaguevineGame;
}


@end
