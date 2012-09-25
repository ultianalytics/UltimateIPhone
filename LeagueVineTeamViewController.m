//
//  LeagueVineTeamViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineTeamViewController.h"
#import "ColorMaster.h"
#import "LeaguevineItem.h"
#import "LeaguevineClient.h"
#import "LeagueVineSelectorLeagueViewController.h"
#import "LeagueVineSelectorSeasonViewController.h"
#import "LeagueVineSelectorTeamViewController.h"
#import "LeaguevineSelectorAbstractViewController.h"
#import "CloudClient.h"
#import "Team.h"
#import "LeaguevineTeam.h"
#import "LeaguevineSeason.h"
#import "LeaguevineLeague.h"

#define kHeaderHeight 30

@interface LeagueVineTeamViewController ()

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIButton *clearLeaguevineButton;

@property (strong, nonatomic) LeaguevineClient* client;
@property (nonatomic, strong) LeaguevineLeague* league;
@property (nonatomic, strong) LeaguevineSeason* season;
@property (nonatomic, strong) LeaguevineTeam* leaguevineTeam;

- (IBAction)clearLeaguevinePressed:(id)sender;

@end

@implementation LeagueVineTeamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Leaguevine Team";
    }
    return self;
}

#pragma mark - Custom accessors

-(void)setTeam:(Team *)team {
    _team = team;
    self.leaguevineTeam = team.leaguevineTeam;
    self.season = self.leaguevineTeam.season;
    self.league = self.leaguevineTeam.league;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearLeaguevineButton.hidden = !self.team.leaguevineTeam;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {

    [self setClearLeaguevineButton:nil];
    [super viewDidUnload];
}

#pragma mark Event handling

-(void)doneButtonPressed {
    if (self.selectedBlock) {
        self.season.league = self.league;
        self.leaguevineTeam.season = self.season;
        self.selectedBlock(self.leaguevineTeam);
    }
}

- (IBAction)clearLeaguevinePressed:(id)sender {
    if (self.selectedBlock) {
        self.selectedBlock(nil);
    }
}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.league ? (self.season ? 3 : 2) : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* STD_ROW_TYPE = @"stdRowType";
    
    LeaguevineItem* item = indexPath.section == 0 ? self.league : (indexPath.section == 1 ? self.season : self.leaguevineTeam);
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }

    cell.textLabel.text = item ? item.name : [NSString stringWithFormat: @"%@ not selected", [self sectionName:indexPath.section]];
    cell.textLabel.textColor = item ? [UIColor blackColor] : [UIColor grayColor];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, kHeaderHeight)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, kHeaderHeight)];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.text = [NSString stringWithFormat:@"%@:", [self sectionName:section]];
    [headerView addSubview:headerLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case 2:
            [self handleLeaguevineTeamNeedsSelection];
            break;
        case 1:
            [self handleLeaguevineSeasonNeedsSelection];
            break;
        default:
            [self handleLeaguevineLeagueNeedsSelection];
    }
}

#pragma mark Open selector views

-(void)handleLeaguevineLeagueNeedsSelection {
    if ([self verifyConnected]) {
        LeagueVineSelectorLeagueViewController* selectionController = [[LeagueVineSelectorLeagueViewController alloc] init];
        selectionController.leaguevineClient = [self getClient];
        selectionController.selectedBlock = ^(LeaguevineItem* item){
            [self.navigationController popViewControllerAnimated:YES];
            BOOL itemChanged = self.league == nil || self.league.itemId != item.itemId;
            if (itemChanged) {
                self.leaguevineTeam = nil;
                self.season = nil;
                self.league = (LeaguevineLeague*)item;
                [self refresh];
            }
        };
        [self pushSelectorController:selectionController];
    }
}

-(void)handleLeaguevineSeasonNeedsSelection {
    if ([self verifyConnected]) {
        LeagueVineSelectorSeasonViewController* selectionController = [[LeagueVineSelectorSeasonViewController alloc] init];
        selectionController.leaguevineClient = [self getClient];
        selectionController.league = self.league;
        selectionController.selectedBlock = ^(LeaguevineItem* item){
            [self.navigationController popViewControllerAnimated:YES];
            BOOL itemChanged = self.season == nil || self.season.itemId != item.itemId;
            if (itemChanged) {
                self.leaguevineTeam = nil;
                self.season = (LeaguevineSeason*)item;
                [self refresh];
            }
        };
        [self pushSelectorController:selectionController];
    }
}

-(void)handleLeaguevineTeamNeedsSelection {
    if ([self verifyConnected]) {
        LeagueVineSelectorTeamViewController* selectionController = [[LeagueVineSelectorTeamViewController alloc] init];
        selectionController.leaguevineClient = [self getClient];
        selectionController.season = self.season;
        selectionController.selectedBlock = ^(LeaguevineItem* item){
            [self.navigationController popViewControllerAnimated:YES];
            BOOL itemChanged = self.leaguevineTeam == nil || self.leaguevineTeam.itemId != item.itemId;
            if (itemChanged) {
                self.leaguevineTeam = (LeaguevineTeam*)item;
                [self refresh];
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
    return section == 0 ? @"League" : (section == 1 ? @"Season" : @"Team");
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
    if (self.leaguevineTeam) {
        [self addDoneButton];
    } else {
        [self removeDoneButton];
    }
}


@end
