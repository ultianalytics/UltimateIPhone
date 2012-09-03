//
//  StatsViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "StatsViewController.h"
#import "ColorMaster.h"
#import "StandardButton.h"
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
#define kAssists @"Assists"
#define kThrows @"Throws"
#define kDrops @"Drops"
#define kThrowaways @"Throwaways"
#define kDs @"Ds"
#define kPulls @"Pulls"

#define kStatRowHieght 30
#define kStatTypeRowHieght 43
#define kButtonMargin 2

#define kIsNotFirstStatsViewUsage @"IsNotFirstStatsViewUsage"

@interface StatsViewController ()

@property (nonatomic, strong) CalloutsContainerView *usageCallouts;
@property (nonatomic) BOOL hasDisplayedUsageCallouts;

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
    [self updatePlayerStats];
}

-(void)initalizeStatTypes {
    self.statTypes = [[NSArray alloc] initWithObjects: kPlusMinusCount,kTotalPoints,kOPoints,kDPoints,kGoals,kAssists,kThrows,kDrops,kThrowaways,kDs,kPulls,nil];
    self.currentStat = kPlusMinusCount;
}

-(void)updatePlayerStats {
    if ([self.currentStat isEqualToString:kPlusMinusCount]) {
        self.playerStats = [Statistics plusMinusCountPerPlayer: self.game team: nil includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kTotalPoints]) {
        self.playerStats = [Statistics pointsPerPlayer: self.game team: nil includeOffense: YES includeDefense: YES includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kOPoints]) {
        self.playerStats = [Statistics pointsPerPlayer: self.game team: nil includeOffense: YES includeDefense: NO includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kDPoints]) {
        self.playerStats = [Statistics pointsPerPlayer: self.game team: nil includeOffense: NO includeDefense: YES includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kGoals]) {
        self.playerStats = [Statistics goalsPerPlayer:self.game team: nil includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kAssists]) {
        self.playerStats = [Statistics assistsPerPlayer:self.game team: nil includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kThrows]) {
        self.playerStats = [Statistics throwsPerPlayer:self.game team: nil includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kDrops]) {
        self.playerStats = [Statistics dropsPerPlayer:self.game team: nil includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kThrowaways]) {
        self.playerStats = [Statistics throwawaysPerPlayer:self.game team: nil includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kDs]) {
        self.playerStats = [Statistics dsPerPlayer:self.game team: nil includeTournament:[self isTournamentLevel]];
    } else if ([self.currentStat isEqualToString:kPulls]) {
        self.playerStats = [Statistics pullsPerPlayer:self.game team: nil includeTournament:[self isTournamentLevel]];
    } else {
        self.playerStats = [[NSArray alloc] init];
    }
    
    [self.playerStatsTableView reloadData];
    [self.playerStatsTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated: YES];
}

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
    
    static NSString* STD_ROW_TYPE = @"stdRowType";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getBenchRowColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIView* contentView = cell.contentView;
        // remove the normal views
        for (UIView *view in [contentView subviews]) {
            [view removeFromSuperview];
        }
        
        // stat type table
        if (tableView == statTypeTableView) {
            CGRect buttonRectangle = CGRectMake(kButtonMargin, kButtonMargin, 125, kStatTypeRowHieght - (kButtonMargin * 2));
            StandardButton* button = [[StandardButton alloc] initWithFrame:buttonRectangle];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:button];
            
        // player stats table
        } else {
            // (0.) name label
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, kStatRowHieght)];
            label.font = [UIFont boldSystemFontOfSize: 16];
            label.backgroundColor = [ColorMaster getBenchRowColor];
            [contentView addSubview:label];
            // (1.) stat label
            label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 50, kStatRowHieght)];
            [label setTextAlignment:UITextAlignmentRight];
            label.textColor = [UIColor blueColor];
            label.backgroundColor = [ColorMaster getBenchRowColor];
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
            [NSString stringWithFormat:@"%f", [playerStat.number floatValue]];
    }
    
    return cell;
}

-(void)buttonClicked: (UIButton*) statTypeButton {
    NSString* statType = statTypeButton.titleLabel.text;
    self.currentStat = statType;
    [statTypeTableView reloadData];
    [statTypeButton setSelected:YES];
    [self updatePlayerStats];
}

-(BOOL)isTournamentLevel {
     return self.statsScopeSegmentedControl.selectedSegmentIndex == 1;
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
    statTypeTableView.backgroundColor = [ColorMaster getBenchRowColor];
    playerStatsTableView.backgroundColor = [ColorMaster getBenchRowColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updatePlayerStats];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self initalizeStatTypes];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    [self showNewLogonUsageCallouts];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Help Callouts


-(BOOL)showNewLogonUsageCallouts {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsNotFirstStatsViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstStatsViewUsage];
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGPoint anchor = CGPointMake(CGRectGetMaxX(self.statTypeTableView.frame), CGRectGetMinY(self.statTypeTableView.frame) + 80);
        
        [calloutsView addCallout:@"Not all stats are viewable on the iPhone.  To see the full stats for your team, upload the team to your website (Cloud tab)."  anchor: anchor width: 150 degrees: 90 connectorLength: 100 font:[UIFont systemFontOfSize:14]];
        
        self.usageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
        return YES;
    } else {
        return NO;
    }
}

@end
