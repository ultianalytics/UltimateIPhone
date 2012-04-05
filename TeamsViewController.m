//
//  TeamsViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeamsViewController.h"
#import "Team.h"
#import "TeamDescription.h"
#import "ColorMaster.h"
#import "TeamViewController.h"

NSArray* teamDescriptions;

@implementation TeamsViewController
@synthesize teamsTableView;


-(void)goToAddTeam {
    Team* team = [[Team alloc] init];
    TeamViewController* teamController = [[TeamViewController alloc] init];
    teamController.team = team;
    [self.navigationController pushViewController:teamController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [teamDescriptions count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    static NSString* STD_ROW_TYPE = @"stdRowType";
    
    TeamDescription* team = [teamDescriptions objectAtIndex:row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = team.name;
    cell.textLabel.textColor = [Team isCurrentTeam:team.teamId]  ? [ColorMaster getActiveGameColor] : [UIColor blackColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    NSUInteger row = [indexPath row]; 
    TeamDescription* teamDescription = [teamDescriptions objectAtIndex:row];
    Team* team = [Team readTeam:teamDescription.teamId];
    TeamViewController* teamController = [[TeamViewController alloc] init];
    teamController.team = team;
    [self.navigationController pushViewController:teamController animated:YES];
} 

-(void)retrieveTeamDescriptions {
    // make array of descriptions so we don't have to crack open the team objects as we scroll the list
    NSArray* descriptions = [Team retrieveTeamDescriptions];
    // sort
    teamDescriptions = [descriptions sortedArrayUsingComparator:^(id a, id b) {
        NSString* first = ((TeamDescription*)a).name;
        NSString* second = ((TeamDescription*)b).name;
        return [first compare:second];
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Teams", @"Teams");
    }
    return self;
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
    UIBarButtonItem *historyNavBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddTeam)];
    self.navigationItem.rightBarButtonItem = historyNavBarItem;    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    [self retrieveTeamDescriptions];
    [self.teamsTableView reloadData];
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