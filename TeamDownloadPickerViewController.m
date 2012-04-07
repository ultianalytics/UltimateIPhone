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

@implementation TeamDownloadPickerViewController
@synthesize teamsTableView,teams,selectedTeam;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [teams count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Pick the team to download";
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* STD_ROW_TYPE = @"stdRowType";
   
    Team* team = [teams objectAtIndex:[indexPath row]];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
    }
    cell.textLabel.text = team.name;
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath { 
    self.selectedTeam = [teams objectAtIndex:[indexPath row]];
} 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Team Download", @"Team Download");
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
    // Do any additional setup after loading the view from its nib.
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
