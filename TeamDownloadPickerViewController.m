//
//  TeamDownloadPickerViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/7/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "TeamDownloadPickerViewController.h"
#import "Team.h"
#import "ColorMaster.h"
#import "Constants.h"

@implementation TeamDownloadPickerViewController
@synthesize teamsTableView,teams,selectedTeam;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Team Download", @"Team Download");
    }
    return self;
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [teams count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    Team* team = [teams objectAtIndex:[indexPath row]];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    cell.textLabel.text = team.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"ID %@", team.cloudId];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath { 
    self.selectedTeam = [teams objectAtIndex:[indexPath row]];
    [self.navigationController popViewControllerAnimated:YES];
} 

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSingleSectionGroupedTableSectionHeaderHeight;
}


#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 290, 60)];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = NSLocalizedString(@"Pick a team to download to your iPhone (does not include games)", @"");
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerLabel];
    teamsTableView.tableHeaderView = headerView;

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
