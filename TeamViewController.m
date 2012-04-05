//
//  FirstViewController.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "TeamViewController.h"
#import "Team.h"
#import "TeamDescription.h"
#import "SoundPlayer.h"
#import "Preferences.h"
#import "ColorMaster.h"
#import "TeamPlayersViewController.h"

@implementation TeamViewController
@synthesize team,teamTableView, teamNameField,teamTypeSegmentedControl,playerDisplayTypeSegmentedControl,nameCell,typeCell,displayCell,playersCell;

NSArray* cells;

-(void)saveAndReturn {
    if ([self verifyTeamName]) {
        [self.team save];  
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)saveChanges {
    if ([self.team hasBeenSaved]) {
        [self.team save];  
    }
}

-(IBAction)nameChanged: (id) sender {
    team.name = teamNameField.text;
    [self saveChanges];
}

-(IBAction)teamTypeChanged: (id) sender {
    [self dismissKeyboard];
    team.isMixed =  self.teamTypeSegmentedControl.selectedSegmentIndex == 0 ? NO : YES;
    [self saveChanges];
}

-(IBAction)playerDisplayChanged: (id) sender {
    [self dismissKeyboard];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    BOOL isTooLong = (newLength > kMaxTeamNameLength);
    if (isTooLong) {
        [SoundPlayer playKeyIgnored];
    }
    return !isTooLong;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [cells objectAtIndex: [indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    [self dismissKeyboard];
    if ([cells objectAtIndex:[indexPath row]] == playersCell) {
        if ([self verifyTeamName]) {
            [self.team save]; 
            [Team setCurrentTeam: team.teamId];
            TeamPlayersViewController* playersController = [[TeamPlayersViewController alloc] init];
            [self.navigationController pushViewController:playersController animated:YES];
        }
    };
} 

-(void)dismissKeyboard {
    [teamNameField resignFirstResponder];
}

-(BOOL)verifyTeamName {
    NSString* teamName = [self getText: self.teamNameField];
    if ([teamName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Invalid Team Name" 
                              message:@"Team name is required"
                              delegate:self 
                              cancelButtonTitle:@"Try Again" 
                              otherButtonTitles:nil]; 
        [alert show];
        return NO;
    } else if ([self isDuplicateTeamName:teamName]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Duplicate Team Name" 
                              message:@"Each team must have a unique name"
                              delegate:self 
                              cancelButtonTitle:@"Try Again" 
                              otherButtonTitles:nil]; 
        [alert show];
        return NO;  
    } else {
        return YES;
    } 
}


-(NSString*) getText: (UITextField*) textField {
    return textField.text == nil ? @"" : [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(BOOL) isDuplicateTeamName: (NSString*) newTeamName {
    NSArray* teamDescriptions = [Team retrieveTeamDescriptions];
    for (TeamDescription* desc in teamDescriptions) {
        if (![desc.teamId isEqualToString: self.team.teamId] && [desc.name caseInsensitiveCompare:newTeamName] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Team", @"Team");
    }
    return self;
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
    
    cells = [[NSArray alloc] initWithObjects:nameCell, typeCell, displayCell, playersCell, nil];
    
    self.teamNameField.delegate = self; 
    
    [self.teamNameField addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
  

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
    [self.teamNameField setText:team.name];
    self.teamTypeSegmentedControl.selectedSegmentIndex = team.isMixed ? 1 : 0;
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    self.teamTypeSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
    self.playerDisplayTypeSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
    
    if (![self.team hasBeenSaved]) {
        UIBarButtonItem *saveBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStyleBordered target:self action:@selector(saveAndReturn)];
        self.navigationItem.rightBarButtonItem = saveBarItem;    
    }
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
