//
//  LeagueVineTeamViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineTeamViewController.h"
#import "ColorMaster.h"

@interface LeagueVineTeamViewController ()

@property (strong, nonatomic) NSArray* cells;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *leagueCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *teamCell;
@property (strong, nonatomic) IBOutlet UILabel *leagueSelectedLabel;
@property (strong, nonatomic) IBOutlet UILabel *teamSelectedLabel;

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

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cells = @[self.leagueCell, self.teamCell];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setLeagueCell:nil];
    [self setTeamCell:nil];
    [self setLeagueSelectedLabel:nil];
    [self setTeamSelectedLabel:nil];
    [super viewDidUnload];
}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.cells objectAtIndex: [indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

@end
