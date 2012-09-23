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

#define kHeaderHeight 50

@interface LeagueVineTeamViewController ()

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) LeaguevineClient* client;

@property (nonatomic, strong) LeaguevineLeague* league;
@property (nonatomic, strong) LeaguevineSeason* season;

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

-(void)setTeam:(LeaguevineTeam *)team {
    _team = team;
    self.season = team.season;
    self.league = team.league;
}


#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {

    [super viewDidUnload];
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
    
    LeaguevineItem* item = indexPath.section == 0 ? self.league : (indexPath.section == 1 ? self.season : self.team);
    
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
            [self handleLeaguevineTeamSelection];
            break;
        case 1:
            [self handleLeaguevineSeasonSelection];
            break;
        default:
            [self handleLeaguevineLeagueSelection];
    }
}

#pragma mark Open selector views

-(void)handleLeaguevineLeagueSelection {
    LeagueVineSelectorLeagueViewController* leagueController = [[LeagueVineSelectorLeagueViewController alloc] init];
    leagueController.leaguevineClient = [self getClient];
    leagueController.selectedBlock = ^(LeaguevineItem* item){
        [self.navigationController popViewControllerAnimated:YES];
        BOOL itemChanged = self.league == nil || self.league.itemId != item.itemId;
        if (itemChanged) {
            _team = nil;
            _season = nil;
            self.league = (LeaguevineLeague*)item;
            [self.mainTableView reloadData];
        }
    };
    [self.navigationController pushViewController:leagueController animated:YES];
}

-(void)handleLeaguevineSeasonSelection {

}

-(void)handleLeaguevineTeamSelection {

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

@end
