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
#import "Player.h"
#import "UltimateSegmentedControl.h"
#import "ColorMaster.h"

@interface TeamPlayersViewController ()

@property (nonatomic, strong) IBOutlet UITableView* playersTableView;
@property (nonatomic, strong) IBOutlet UILabel* playersTypeLabel;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* playersTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UIButton* leagueVineTeamRefresh;

@end

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
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    NSUInteger row = [indexPath row]; 
    NSArray* players = [Team getCurrentTeam].players;
    Player* player = [players objectAtIndex:row];
    
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

-(void)updateViewAnimated: (BOOL) animate {
    self.playersTypeSegmentedControl.selectedSegmentIndex = [[Team getCurrentTeam] arePlayersFromLeagueVine] ? 1 : 0;
    CGFloat y = 0;
    if ([[Team getCurrentTeam] isLeaguevineTeam]) {
        if ([[Team getCurrentTeam] arePlayersFromLeagueVine]) {
            y = 111;
        } else {
            y = 54;
        }
    }
    CGRect newRect = self.view.bounds;
    newRect.origin.y = y;
    newRect.size.height = newRect.size.height - y;
    if (animate) {
        [self animateTableViewResizeFrom:self.playersTableView.frame to:newRect];
    } else {
        self.playersTableView.frame = newRect;
    }
    [self.playersTableView reloadData];
}

-(void)animateTableViewResizeFrom: (CGRect)oldRect to: (CGRect)newRect {
    // TODO...animate
    self.playersTableView.frame = newRect;
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
    [[Team getCurrentTeam] sortPlayers];
    [self updateViewAnimated: NO];
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

#pragma mark - Event Handlers

- (IBAction)playersTypeChanged:(id)sender {
    if (self.playersTypeSegmentedControl.selectedSegmentIndex == 1) {
        // TODO...warn that players will be replaced and replace if team has players
        [Team getCurrentTeam].arePlayersFromLeagueVine = YES;
        [self updateViewAnimated:YES];
    } else {
        // TODO...warn that players will be removed?
        [Team getCurrentTeam].arePlayersFromLeagueVine = NO;
        [self updateViewAnimated:YES];
    }
}

- (IBAction)refreshButtonPressed:(id)sender {
}


@end
