//
//  TeamViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "Constants.h"
#import "TeamViewController.h"
#import "Team.h"
#import "TeamDescription.h"
#import "SoundPlayer.h"
#import "Preferences.h"
#import "ColorMaster.h"
#import "TeamPlayersViewController.h"
#import "PlayersMasterDetailViewController.h"
#import "AppDelegate.h"
#import "UltimateSegmentedControl.h"
#import "NSString+manipulations.h"
#import "LeagueVineTeamViewController.h"
#import "LeaguevineTeam.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "UIView+Convenience.h"
#import "UIViewController+Additions.h"

#define kIsNotFirstGameDetailViewUsage @"IsNotFirstGameDetailViewUsage"

@interface TeamViewController()

@property (nonatomic, strong) IBOutlet UITableView* teamTableView;
@property (nonatomic, strong) IBOutlet UITableViewCell* nameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* typeCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* displayCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* playersCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* leagueVineCell;
@property (nonatomic, strong) IBOutlet UITextField* teamNameField;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* teamTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* playerDisplayTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UILabel *leagueVineDescriptionLabel;
@property (nonatomic, strong) IBOutlet UIView* deleteButtonView;
@property (nonatomic, strong) IBOutlet UIView* teamCopyButtonView;
@property (nonatomic, strong) IBOutlet UIAlertView* deleteAlertView;
@property (nonatomic, strong) IBOutlet UIButton *clearCloudIdButton;
@property (strong, nonatomic) IBOutlet UIView *customFooterView;

@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;

@end

@implementation TeamViewController


+(BOOL)isFirstTeamCreation {
    return [[Team getCurrentTeam].name isEqualToString:kAnonymousTeam] && [[Team getAllTeamFileNames] count] == 1;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(void)populateViewFromModel {
    [self.teamNameField setText:([self.team.name isEqualToString: kAnonymousTeam] ? @"" : self.team.name)];
    if ([self.team isLeaguevineTeam] && self.team.arePlayersFromLeagueVine) {
        self.team.isMixed = NO;
        self.teamTypeSegmentedControl.enabled = NO;
    } else {
        self.teamTypeSegmentedControl.enabled = YES;
    }
    [self.teamTypeSegmentedControl setSelection: self.team.isMixed ? @"Mixed" : @"Uni"];
    [self.playerDisplayTypeSegmentedControl setSelection: self.team.isDiplayingPlayerNumber ? @"Number" : @"Name"];
    [self populateLeagueVineTeamCell];
    self.teamCopyButtonView.visible = [self.team hasBeenSaved] && [self.teamNameField.text isNotEmpty];
    if ([[self class] isFirstTeamCreation]) {
        self.deleteButtonView.visible = NO;
    } else {
        self.deleteButtonView.visible = [self.team hasBeenSaved];
    }
#ifdef DEBUG
    self.clearCloudIdButton.hidden = NO;
#endif
}

-(void)populateModelFromView {
    self.team.name = [self.teamNameField.text trim];
    self.team.isMixed =  [[self.teamTypeSegmentedControl getSelection] isEqualToString: @"Mixed"] ? YES : NO;
    self.team.isDiplayingPlayerNumber =  [[self.playerDisplayTypeSegmentedControl getSelection] isEqualToString: @"Number"] ? YES : NO;
}

-(void)saveAndContinue {
    if ([self saveChanges]) {
        [self dismissKeyboard];
        if (IS_IPHONE) {
            [self goToPlayersView:YES];
        } else {
            [self notifyChangeListener];
            if (self.isModalAddMode) {
                [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

-(BOOL)saveChanges {
    if ([self verifyTeamName]) {
        [self populateModelFromView];
        [self.team save];
        [Team setCurrentTeam:nil];
        [Team setCurrentTeam:self.team.teamId];
        self.team = [Team getCurrentTeam];
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
        return YES;
    }
    return NO;
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

-(void)verifyAndDelete {
    if ([[Team retrieveTeamDescriptions] count] < 2) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Delete not allowed"
                              message:@"You cannot delete this team because it is the only team remaining."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    } else {
        self.deleteAlertView = [[UIAlertView alloc]
                                initWithTitle: NSLocalizedString(@"Delete Team",nil)
                                message: NSLocalizedString(@"Are you sure you want to delete this team?",nil)
                                delegate: self
                                cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
                                otherButtonTitles: NSLocalizedString(@"Delete",nil), nil];
        [self.deleteAlertView show];
    } 
}

-(NSString*) getText: (UITextField*) textField {
    return textField.text == nil ? @"" : [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(BOOL) isDuplicateTeamName: (NSString*) newTeamName {
    return [Team isDuplicateTeamName: newTeamName notIncluding: self.team];
}

-(void)goToPlayersView: (BOOL) animated {
    if (IS_IPAD) {
        if (self.playersViewRequestedBlock) {
            self.playersViewRequestedBlock();
        }
    } else {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Team" style:UIBarButtonItemStyleBordered target:nil action:nil];
        [[self navigationItem] setBackBarButtonItem:backButton];
        TeamPlayersViewController* playersController = [[TeamPlayersViewController alloc] init];
        [self.navigationController pushViewController:playersController animated:animated];
    }
}

- (void)handlePlayersCellSelected {
    if ([self saveChanges]) {
        [Team setCurrentTeam: self.team.teamId];
        [self goToPlayersView: YES];
    }
}


-(IBAction)nameChanged: (id) sender {
    
}

-(IBAction)deleteClicked: (id) sender {
    [self verifyAndDelete];
}

- (IBAction)copyClicked:(id)sender {
    if (self.team.arePlayersFromLeagueVine) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Cannot copy team with leaguevine players"
                              message:@"This team cannot be copied because the players are downloaded from leaguevine.\n\nPlease create a new team instead."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    Team* teamCopy = [self.team copy];
    [teamCopy save];
    [Team setCurrentTeam:teamCopy.teamId];
    self.team = teamCopy;
    [self populateViewFromModel];
    if (IS_IPAD) {
        [self notifyChangeListener];
    }
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Team Copied"
                          message:@"The team (and all players) have been copied and saved.  Consider entering a better team name before leaving this view."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)clearCloudIdClicked:(id)sender {
    self.team.cloudId = nil;
}

-(IBAction)teamTypeChanged: (id) sender {
    [self dismissKeyboard];
}

-(IBAction)playerDisplayChanged: (id) sender {
    [self dismissKeyboard];
}


#pragma mark Keyboard

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

-(void)dismissKeyboard {
    [self.teamNameField resignFirstResponder];
}

#pragma AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.deleteAlertView) {
        switch (buttonIndex) {
            case 0: 
            {       
                //SHSLog(@"Delete was cancelled by the user");
            }
                break;
                
            case 1: 
            {
                [self.team delete];
                [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
                if (IS_IPHONE) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [self notifyChangeListener];
                }
            }
                break;
        }
    }
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.isModalAddMode ? @"New Team" : @"Team";
    self.teamTableView.tableFooterView = self.customFooterView;
    self.clearCloudIdButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.clearCloudIdButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.teamNameField.delegate = self;
    [self.teamNameField addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
    UIBarButtonItem *saveBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStyleBordered target:self action:@selector(saveAndContinue)];
    self.navigationItem.rightBarButtonItem = saveBarItem;
    if (self.isModalAddMode) {
        UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelModalDialog)];
        self.navigationItem.leftBarButtonItem = cancelBarItem;
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populateViewFromModel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.team.teamId isEqualToString:[Team getCurrentTeam].teamId] && [self.team hasBeenSaved]) {
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self registerForKeyboardNotifications];
        [self showFirstTimeUsageCallouts];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.cells) {
        if (self.isModalAddMode) {
            self.cells = [[NSArray alloc] initWithObjects:self.nameCell, self.typeCell, self.displayCell, nil];
        } else {
            self.cells = [[NSArray alloc] initWithObjects:self.nameCell, self.typeCell, self.displayCell, self.leagueVineCell, self.playersCell, nil];
        }
    }
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.cells objectAtIndex: [indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissKeyboard];
    if ([self.cells objectAtIndex:[indexPath row]] == self.playersCell) {
        [self handlePlayersCellSelected];
    } else if ([self.cells objectAtIndex:[indexPath row]] == self.leagueVineCell) {
        [self handleLeaguevineTeamNeedsSelection];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSingleSectionGroupedTableSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kFormCellHeight;
}

#pragma mark Leaguevine

-(void)handleLeaguevineTeamNeedsSelection {
    if (self.team.leaguevineTeam && [self.team hasGames]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Cannot change leaguevine team now"
                              message:@"The leaguevine team can no longer be changed because games have been created using this team.\n\nPlease create a new team instead."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    LeagueVineTeamViewController* leagueController = [[LeagueVineTeamViewController alloc] init];
    leagueController.team = self.team;
    leagueController.selectedBlock = ^(LeaguevineTeam* leaguevineTeam) {
        self.team.leaguevineTeam = leaguevineTeam;
        if (![self.teamNameField.text isNotEmpty]) {
            self.teamNameField.text = leaguevineTeam.name;
        }
        [self saveChanges];
        [self.navigationController popViewControllerAnimated:YES];
    };
    if (IS_IPAD) {
        leagueController.isModalMode = YES;
        UINavigationController* leagueNavController = [[UINavigationController alloc] initWithRootViewController:leagueController];
        leagueNavController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:leagueNavController animated:YES completion:nil];
    } else {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
        [[self navigationItem] setBackBarButtonItem:backButton];
        [self.navigationController pushViewController:leagueController animated:YES];
    }
}

-(void)populateLeagueVineTeamCell {
    self.leagueVineDescriptionLabel.text = self.team.leaguevineTeam == nil ? @"NO TEAM PICKED" : self.team.leaguevineTeam.name;
}

#pragma mark - Callouts


-(BOOL)showFirstTimeUsageCallouts {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kIsNotFirstGameDetailViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstGameDetailViewUsage];
        
        [self performSelector:@selector(displayFirstTimeCallouts) withObject:nil afterDelay:.1];

        return YES;
    } else {
        return NO;
    }
    
}

-(void)displayFirstTimeCallouts {
    CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
    
    CGPoint anchor = CGPointBottom([self.leagueVineCell convertRect:self.leagueVineCell.bounds toView:self.view]);
    [calloutsView addCallout:@"Connect your team to Leaguevine if you would like scores posted there as games progress." anchor: anchor width: 200 degrees: 180 connectorLength: 60 font: [UIFont systemFontOfSize:16]];
    
    self.firstTimeUsageCallouts = calloutsView;
    [self.view addSubview:calloutsView];
    
    // move the callouts off the screen and then animate their return.
    [self.firstTimeUsageCallouts slide: YES animated: NO];
    [self.firstTimeUsageCallouts slide: NO animated: YES];
}

#pragma mark - Keyboard Up/Down Handling

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    // make the view port smaller so the user can scroll up to see all of the view
    CGFloat keyboardY = [self calcKeyboardOrigin:aNotification];
    CGFloat tableBottom = CGRectGetMaxY(self.teamTableView.frame);
    CGFloat newBottomInset = MAX(tableBottom - keyboardY, 0);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, newBottomInset, 0.0);
    self.teamTableView.contentInset = contentInsets;
    self.teamTableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    // undo the view port
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.teamTableView.contentInset = contentInsets;
    self.teamTableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - iPad only (Master/Detail UX)

-(void)notifyChangeListener {
    if (self.teamChangedBlock) {
        self.teamChangedBlock(self.team);
    }
}

-(void)setTeam:(Team *)team {
    _team = team;
    [self populateViewFromModel];
}

-(void)cancelModalDialog {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


@end
