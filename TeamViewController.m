//
//  FirstViewController.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TeamViewController.h"
#import "Team.h"
#import "PlayerDetailsViewController.h"
#import "ImageMaster.h"
#import "SoundPlayer.h"
#import "Preferences.h"
#import "ColorMaster.h"

@implementation TeamViewController
@synthesize playersTableView, teamNameField,teamTypeSegmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Team", @"Team");
    }
    return self;
}

-(IBAction)nameChanged: (id) sender {
    [Team getCurrentTeam].name = teamNameField.text;
    [[Team getCurrentTeam] save];
}

-(IBAction)teamTypeChanged: (id) sender {
    [Team getCurrentTeam].isMixed =  self.teamTypeSegmentedControl.selectedSegmentIndex == 0 ? NO : YES;
    [[Team getCurrentTeam] save];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    BOOL isTooLong = (newLength > 8);
    if (isTooLong) {
        [SoundPlayer playKeyIgnored];
    }
    return !isTooLong;
}

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
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playersTableView.separatorColor = [ColorMaster getTableListSeparatorColor];
    
    self.teamNameField.delegate = self; 
    
    [self.teamNameField addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
    
    UIBarButtonItem *historyNavBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddItem)];
    self.navigationItem.rightBarButtonItem = historyNavBarItem;    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[Team getCurrentTeam] sortPlayers];
    [self.playersTableView reloadData];
    [self.teamNameField setText:[Team getCurrentTeam].name];
    self.teamTypeSegmentedControl.selectedSegmentIndex = [Team getCurrentTeam].isMixed ? 1 : 0;
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    self.teamTypeSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
