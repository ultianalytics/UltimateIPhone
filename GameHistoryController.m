//
//  GameHistoryController.m
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "GameHistoryController.h"
#import "GameViewController.h"
#import "Game.h"
#import "Event.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "ColorMaster.h"
#import "ImageMaster.h"
#import "Event.h"
#import "UPoint.h"
#import <QuartzCore/QuartzCore.h>
#import "EventChangeViewController.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "GameHistoryHeaderView.h"
#import "UIView+Convenience.h"

#define kIsNotFirstGameHistoryViewUsage @"IsNotFirstGameHistoryViewUsage"

@interface GameHistoryController()

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (nonatomic) CGFloat headerHeight;

@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;

@end

@implementation GameHistoryController
@synthesize game,isCurlAnimation;


#pragma mark Table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.game getNumberOfPoints];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.game getPointAtMostRecentIndex:section] getNumberOfEvents];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    UPoint* point = [self.game getPointAtMostRecentIndex:section];
    Event* event = [point getEventAtMostRecentIndex:row];
    
    
    static NSString* OffenseRowType = @"OffenseRow";
    static NSString* DefenseRowType = @"DefenseRow";
    NSString* rowType = [event isOffense] ? OffenseRowType : DefenseRowType;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: rowType];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:rowType];
        UIColor* color = [event isOffense] ? [ColorMaster getOffenseEventColor] : [ColorMaster getDefenseEventColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = color;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.imageView.image = [ImageMaster getImageForEvent: event];
    cell.textLabel.text = [event getDescription];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UPoint* point = [self.game getPointAtMostRecentIndex:[indexPath section]];
    Event* event = [point getEventAtMostRecentIndex:[indexPath row]];
    
    EventChangeViewController* changeController = [[EventChangeViewController alloc] init];
    changeController.event = event;
    changeController.pointDescription = [self.game getPointNameAtMostRecentIndex:[indexPath section]];
    changeController.playersInPoint = point.line;
    NSIndexPath* topVisibleRow = [self.eventTableView indexPathForCell:[self.eventTableView.visibleCells objectAtIndex:0]];
    changeController.completion = ^{
        [self.navigationController popViewControllerAnimated:YES];
        [self.game save];
        [self.eventTableView reloadData];
        [self.eventTableView scrollToRowAtIndexPath:topVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    };
    
    [self.navigationController pushViewController:changeController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GameHistoryHeaderView* header = [self createHeader];

    [header setInfoForGame: self.game section: section];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.headerHeight) {
        self.headerHeight = [self createHeader].frameHeight;
    }
    return self.headerHeight;
}

-(GameHistoryHeaderView*)createHeader {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([GameHistoryHeaderView class]) owner:nil options:nil];
    GameHistoryHeaderView*  header = (GameHistoryHeaderView *)[nib objectAtIndex:0];
    return header;
}


#pragma mark Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Game Events", @"Game Events");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isCurlAnimation) {
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(popWithCurl)];
        self.navigationItem.leftBarButtonItem = settingsButton;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if ([Game getCurrentGame] !=  nil && [[Game getCurrentGame].gameId isEqualToString: game.gameId]) {
        [super viewWillAppear:animated];
        [self showFirstTimeUsageCallouts];
    } else {  // no longer open on the current game...pop back to previous view
        [self.navigationController popViewControllerAnimated:NO];
    }
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

#pragma mark - Callouts


-(BOOL)showFirstTimeUsageCallouts {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kIsNotFirstGameHistoryViewUsage] && [self.game hasEvents]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstGameHistoryViewUsage];
        [self performSelector:@selector(displayFirstTimeCallouts) withObject:nil afterDelay:.1];
        return YES;
    } else {
        return NO;
    }
    
}

-(void)displayFirstTimeCallouts {
    if ([self.game hasEvents]) {
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGRect firstCellRect = [self.eventTableView rectForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
        CGPoint anchor = CGPointBottom(firstCellRect);
        
        [calloutsView addCallout:@"Tap an event to make changes." anchor: anchor width: 200 degrees: 180 connectorLength: 70 font: [UIFont systemFontOfSize:14]];
        
        self.firstTimeUsageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
        
        // move the callouts off the screen and then animate their return.
        [self.firstTimeUsageCallouts slide: YES animated: NO];
        [self.firstTimeUsageCallouts slide: NO animated: YES];
    }
}


#pragma mark - Miscellaneous

- (void)popWithCurl {
    //Curl up
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
}

@end
