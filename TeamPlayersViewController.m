//
//  TeamPlayersViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeamPlayersViewController.h"
#import "PlayerDetailsViewController.h"
#import "Team.h"
#import "ImageMaster.h"

@implementation TeamPlayersViewController
@synthesize playersTableView;

-(void)goToAddItem {
    PlayerDetailsViewController* playerController = [[PlayerDetailsViewController alloc] init];
    [self.navigationController pushViewController:playerController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[Team getCurrentTeam] players] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    static NSString* STD_ROW_TYPE = @"stdRowType";
    
    Player* player = [[[Team getCurrentTeam] players] objectAtIndex:row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.backgroundColor = [UIColor clearColor];
    }
    cell.imageView.image = player.isMale ?[ImageMaster getMaleImage] : [ImageMaster getFemaleImage];
    
    NSString* text = player.name;
    if (player.number != nil && ![player.number isEqualToString:@""]) {
        text = [NSString stringWithFormat:@"%@ (%@)", text, player.number];
    }
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    NSUInteger row = [indexPath row]; 
    Player* player = [[[Team getCurrentTeam] players] objectAtIndex:row];
    
    PlayerDetailsViewController* playerController = [[PlayerDetailsViewController alloc] init];
    playerController.player = player;
    [self.navigationController pushViewController:playerController animated:YES];
} 


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.title = NSLocalizedString(@"Players", @"Players");
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
    UIBarButtonItem *addNavBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddItem)];
    self.navigationItem.rightBarButtonItem = addNavBarItem;  
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont boldSystemFontOfSize:16.0], UITextAttributeFont, nil]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Players", @"Players"),[Team getCurrentTeam].name];
    [self.playersTableView reloadData];
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
