//
//  StatsViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "StatsViewController.h"
#import "ColorMaster.h"
#import "ImageMaster.h"
#import "Statistics.h"
#import "PlayerStat.h"
#import "Game.h"
#import "Player.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "UltimateSegmentedControl.h"
#import "Preferences.h"

#define kPlusMinusCount @"+/- Count"
#define kTotalPoints @"Points Played"
#define kOPoints @"O Points Played"
#define kDPoints @"D Points Played"
#define kGoals @"Goals"
#define kCallahans @"Callahans"
#define kCallahaneds @"Callahan'd"
#define kAssists @"Assists"
#define kThrows @"Throws"
#define kDrops @"Drops"
#define kThrowaways @"Throwaways"
#define kStalls @"Stalled"
#define kMiscPenalties @"Penalties (turns)"
#define kDs @"Ds"
#define kPulls @"Pulls"
#define kPullsOb @"Pulls OB"

#define kStatRowHieght 30
#define kStatTypeRowHieght 37
#define kButtonMargin 2

#define kIsNotFirstStatsViewUsage @"IsNotFirstStatsViewUsage"

@interface StatsViewController ()

@property (nonatomic, strong) CalloutsContainerView *usageCallouts;

@end

@implementation StatsViewController
@synthesize statsScopeSegmentedControl;
@synthesize statTypeTableView,playerStatsTableView,statTypes,playerStats,game,currentStat;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Game Stats", @"Game Stats");
        statTypes = [[NSArray alloc] init];
        playerStats = [[NSArray alloc] init];
        [self initalizeStatTypes];
    }
    return self;
}

- (IBAction)statsScopeChanged:(id)sender {
    if ([self isTournamentLevel]) {
        [self showBusyIndicator:YES];
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updatePlayerStats) userInfo:nil repeats:NO];
    } else {
        [self updatePlayerStats];
    }
}

-(void)initalizeStatTypes {
    self.statTypes = [[NSArray alloc] initWithObjects: kPlusMinusCount,kTotalPoints,kOPoints,kDPoints,kGoals,kAssists,kCallahans,kThrows,kDrops,kThrowaways,kStalls,kMiscPenalties,kCallahaneds,kDs,kPulls,kPullsOb, nil];
    self.currentStat = kPlusMinusCount;
}

-(void)updatePlayerStats {
    if ([self.currentStat isEqualToString:kPlusMinusCount]) {
        self.playerStats = [Statistics plusMinusCountPerPlayer: self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kTotalPoints]) {
        self.playerStats = [Statistics pointsPerPlayer: self.game includeOffense: YES includeDefense: YES includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kOPoints]) {
        self.playerStats = [Statistics pointsPerPlayer: self.game includeOffense: YES includeDefense: NO includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kDPoints]) {
        self.playerStats = [Statistics pointsPerPlayer: self.game includeOffense: NO includeDefense: YES includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kGoals]) {
        self.playerStats = [Statistics goalsPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kCallahans]) {
        self.playerStats = [Statistics callahansPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kAssists]) {
        self.playerStats = [Statistics assistsPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kThrows]) {
        self.playerStats = [Statistics throwsPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kDrops]) {
        self.playerStats = [Statistics dropsPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kThrowaways]) {
        self.playerStats = [Statistics throwawaysPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kStalls]) {
        self.playerStats = [Statistics stallsPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kMiscPenalties]) {
        self.playerStats = [Statistics miscPenaltiesPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kCallahaneds]) {
        self.playerStats = [Statistics callahanedPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kDs]) {
        self.playerStats = [Statistics dsPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kPulls]) {
        self.playerStats = [Statistics pullsPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kPullsOb]) {
        self.playerStats = [Statistics pullsObPerPlayer:self.game includeTournament:[self isTournamentLevel]];
    } else {
        self.playerStats = [[NSArray alloc] init];
    }
    
    [self.playerStatsTableView reloadData];
    if ([playerStats count] > 0) {
        [self.playerStatsTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated: YES];
    }
    [self showBusyIndicator:NO];
}


-(void)buttonClicked: (UIButton*) statTypeButton {
    if ([self isTournamentLevel]) {
        [self showBusyIndicator:YES];
    }
    NSString* statType = statTypeButton.titleLabel.text;
    self.currentStat = statType;
    [statTypeTableView reloadData];
    [statTypeButton setSelected:YES];
    
    if ([self isTournamentLevel]) {
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updatePlayerStats) userInfo:nil repeats:NO];
    } else {
        [self updatePlayerStats];
    }
}

 -(void)showBusyIndicator: (BOOL)show {
     if (show) {
         [self.activityIndicator startAnimating];
     } else {
         [self.activityIndicator stopAnimating];
     }
 }
     
-(BOOL)isTournamentLevel {
     return self.statsScopeSegmentedControl.selectedSegmentIndex == 1;
}

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    // add insets to handle tab bar
    self.statTypeTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    self.playerStatsTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    if (IS_IPAD) {
        // shift the players table over a bit to it doesn't look so empty in the view
        self.playerStatsTableView.transform = CGAffineTransformMakeTranslation(120.0, 0.0);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updatePlayerStats];
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    [self initalizeStatTypes];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showNewLogonUsageCallouts];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView == statTypeTableView ? kStatTypeRowHieght : kStatRowHieght;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == statTypeTableView ? [statTypes count] : [playerStats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView* contentView = cell.contentView;
        // remove the normal views
        for (UIView *view in [contentView subviews]) {
            [view removeFromSuperview];
        }
        cell.backgroundColor = [UIColor clearColor];
        
        // stat type table
        if (tableView == statTypeTableView) {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(kButtonMargin, kButtonMargin, 140, kStatTypeRowHieght - (kButtonMargin * 2));
            [button setBackgroundImage:[ImageMaster stretchableWhite100Radius3] forState:UIControlStateNormal];
            [button setBackgroundImage:[ImageMaster stretchableWhite200Radius3] forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
            [contentView addSubview:button];
            
        // player stats table
        } else {
            // (0.) name label
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, kStatRowHieght)];
            label.adjustsFontSizeToFitWidth = YES;
            label.font = [UIFont boldSystemFontOfSize: 16];
            [contentView addSubview:label];
            // (1.) stat label
            label = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 40, kStatRowHieght)];
            [label setTextAlignment:NSTextAlignmentRight];
            label.textColor = [UIColor blackColor];
            [contentView addSubview:label];
        }
    }
    
    // stat type table
    if (tableView == statTypeTableView) {
        UIButton* statTypeButton = [cell.contentView.subviews objectAtIndex:0];
        NSString* statType = [self.statTypes objectAtIndex:row];
        [statTypeButton setTitle:statType forState:UIControlStateNormal];
        [statTypeButton setSelected: [statType isEqualToString: self.currentStat]];
        
    // player stats table
    } else {
        UILabel* nameLabel = [cell.contentView.subviews objectAtIndex:0];
        UILabel* statLabel = [cell.contentView.subviews objectAtIndex:1];
        PlayerStat* playerStat = [self.playerStats objectAtIndex:row];
        nameLabel.text = playerStat.player.name;
        statLabel.text = playerStat.type == IntStat ? [NSString stringWithFormat:@"%d", [playerStat.number intValue]] :
        [NSString stringWithFormat:@"%.1f", [playerStat.number floatValue]];
    }
    
    return cell;
}

#pragma mark - Help Callouts


-(BOOL)showNewLogonUsageCallouts {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsNotFirstStatsViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstStatsViewUsage];
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGPoint anchor = CGPointMake(CGRectGetMaxX(self.statTypeTableView.frame), CGRectGetMinY(self.statTypeTableView.frame) + 80);
        
        [calloutsView addCallout:@"Not all stats are viewable on the iPhone or iPad.  To see the full stats for your team, upload the team to your website (Website tab)."  anchor: anchor width: 150 degrees: 90 connectorLength: 100 font:[UIFont systemFontOfSize:14]];
        
        self.usageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
        return YES;
    } else {
        return NO;
    }
}
     

@end
