//
//  GameDownloadPickerViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/7/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "GameDownloadPickerViewController.h"
#import "GameDescription.h"
#import "ColorMaster.h"
#import "Constants.h"
#import "UIScrollView+Utilities.h"

@implementation GameDownloadPickerViewController
@synthesize gamesTableView,games,selectedGame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Game Download", @"Game Download");
    }
    return self;
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [games count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    GameDescription* game = [games objectAtIndex:[indexPath row]];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    cell.textLabel.text = game.opponent;
    BOOL inTournament = [game.tournamentName isNotEmpty];
    NSString* details = [NSString stringWithFormat:@"%@%@%@", (inTournament ? game.tournamentName : @""), inTournament ? @", " : @"", game.startDate == nil ? @"" : [dateFormat stringFromDate:game.startDate]];
    cell.detailTextLabel.text = details;
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    GameDescription* game = [games objectAtIndex:[indexPath row]];
    if (IS_IPHONE && game.isPositional) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Game not supported on iPhone"
                              message: [NSString stringWithFormat: @"The game you selected has positional data.  It is currently only supported on an iPad."]
                              delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    } else {
        self.selectedGame = game;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSingleSectionGroupedTableSectionHeaderHeight;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d h:mm"];
    self.games = [self.games sortedArrayUsingComparator:^(id a, id b) {
        NSDate *first = ((GameDescription*)a).startDate;
        NSDate *second = ((GameDescription*)b).startDate;
        return [second compare:first];
    }];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 290, 60)];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = [NSString stringWithFormat:@"Pick a game to download to your %@", IS_IPAD ? @"iPad" : @"iPhone"];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerLabel];
    gamesTableView.tableHeaderView = headerView;
    [gamesTableView adjustInsetForTabBar];

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
