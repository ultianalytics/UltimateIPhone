//
//  TeamsViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/4/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "TeamsViewController.h"
#import "Team.h"
#import "TeamDescription.h"
#import "ColorMaster.h"
#import "TeamViewController.h"
#import "AppDelegate.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "Constants.h"
#import "SHSLogsMailer.h"
#import "UIScrollView+Utilities.h"

#define kIsNotFirstTeamsViewUsage @"IsNotFirstTeamsViewUsage"

@interface TeamsViewController()

@property (nonatomic, strong) IBOutlet UITableView* teamsTableView;
@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;

@end

@implementation TeamsViewController
@synthesize teamsTableView,firstTimeUsageCallouts;

    

-(void)addTeamClicked {
    if (![self showFirstTimeUsageCallouts]) {
        [self goToTeamView: [[Team alloc] init] animated: YES];
    }
}

-(void)goToAddTeam {
    [self goToTeamView: [[Team alloc] init] animated: YES];
}

-(void)goToTeamView: (Team*) team animated: (BOOL) animated {
    if (IS_IPAD) {
        if ([team hasBeenSaved]) {
            [self selectCurrentTeamAnimated: NO];
        } else {
            TeamViewController* addTeamController = [[TeamViewController alloc] init];
            addTeamController.team = team;
            addTeamController.isModalAddMode = YES;
            [self registerDetailControllerListener:addTeamController];
            UINavigationController* addTeamNavController = [[UINavigationController alloc] initWithRootViewController:addTeamController];
            addTeamNavController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:addTeamNavController animated:YES completion:nil];
        }
    } else {
        TeamViewController* teamController = [[TeamViewController alloc] init];
        teamController.team = team;
        [self.navigationController pushViewController:teamController animated:animated];
    }
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

-(void)goToBestView {
    // go to the current team on app start
    if (!isAfterFirstView) {
        isAfterFirstView = YES;
        if ([self isFirstTeamCreation]) {
            TeamViewController* teamController = [[TeamViewController alloc] init];
            teamController.team = [Team getCurrentTeam];
            [self.navigationController pushViewController:teamController animated:NO];
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"My Teams", @"My Teams");
        isAfterFirstView = NO;
    }
    return self;
}

-(BOOL)showFirstTimeUsageCallouts {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kIsNotFirstTeamsViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstTeamsViewUsage];
        
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGPoint anchor = CGPointTopRight(self.view.bounds);
        anchor.x = anchor.x - 40;
        [calloutsView addCallout:@"FYI: You do NOT need to add your opponent teams here. Only add teams for whom you are gathering statistics.\n\nClick on the + again if you are really adding a team for gathering stats." anchor: anchor width: 200 degrees: 210 connectorLength: 150 font: [UIFont systemFontOfSize:16]];

        self.firstTimeUsageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
        return YES;
    } else {
        return NO;
    }
    
}

-(BOOL)isFirstTeamCreation {
    return [TeamViewController isFirstTeamCreation];
}

#pragma mark - iPad (Master/Detail UX)

-(void)setDetailController:(TeamViewController *)detailController {
    _detailController = detailController;
    [self registerDetailControllerListener: detailController];
}

-(void)selectCurrentTeamAnimated: (BOOL)animated {
    if (teamDescriptions) {
        NSString* teamId = [Team getCurrentTeam].teamId;
        int teamIndex = 0;
        for (int row = 0; row < [teamDescriptions count]; row++) {
            if ([[teamDescriptions[row] teamId] isEqualToString:teamId]) {
                teamIndex = row;
                break;
            }
        }
        [self.teamsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:teamIndex inSection:0] animated:animated scrollPosition:UITableViewScrollPositionTop];
        if (![self.detailController.team.teamId isEqualToString:teamId]) {
            self.detailController.team = [Team getCurrentTeam];
        }
    }
}

-(void)registerDetailControllerListener:(TeamViewController *)detailController {
    __typeof(self) __weak weakSelf = self;
    detailController.teamChangedBlock = ^(Team* team) {
        [weakSelf retrieveTeamDescriptions];
        [weakSelf.teamsTableView reloadData];
        [weakSelf selectCurrentTeamAnimated: NO];
    };
}

#pragma mark - Support Tools

-(void)addSupportGestureRecognizer {
    UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(supportSwipe:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizer.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer: swipeRecognizer];
}

- (void)supportSwipe:(UISwipeGestureRecognizer*)gestureRecognizer {
    [[SHSLogsMailer sharedMailer] presentEmailLogsControllerOn:self includeTeamFiles:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *historyNavBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addTeamClicked)];
    self.navigationItem.rightBarButtonItem = historyNavBarItem;
    [self addSupportGestureRecognizer];
    [self.teamsTableView adjustInsetForTabBar];
    if (IS_IPAD) {
        [self retrieveTeamDescriptions];
        [self.teamsTableView reloadData];
        [self selectCurrentTeamAnimated: NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (IS_IPHONE) {
        [self retrieveTeamDescriptions];
        [self.teamsTableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self goToBestView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.firstTimeUsageCallouts removeFromSuperview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [teamDescriptions count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    TeamDescription* team = [teamDescriptions objectAtIndex:row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:STD_ROW_TYPE];
        if (IS_IPHONE) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    cell.textLabel.text = team.name;
    cell.detailTextLabel.text = team.cloudId ? [NSString stringWithFormat:@"ID %@", team.cloudId] : @"Not uploaded yet";
    cell.textLabel.textColor = [Team isCurrentTeam:team.teamId]  ? [ColorMaster getActiveGameColor] : [UIColor blackColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    TeamDescription* teamDescription = [teamDescriptions objectAtIndex:row];
    if (![teamDescription.teamId isEqualToString:[Team getCurrentTeam].teamId]) {
        [Team setCurrentTeam:teamDescription.teamId];
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetCloudTab];
    }
    if (IS_IPAD) {
        [self.teamsTableView reloadData];  // reload to display current team in correct color
    }
    [self goToTeamView: [Team getCurrentTeam] animated: YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSingleSectionGroupedTableSectionHeaderHeight;
}

@end
