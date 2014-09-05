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
#import "GameHistoryTableViewCell.h"
#import "UIView+Convenience.h"
#import "UIScrollView+Utilities.h"

#define kIsNotFirstGameHistoryViewUsage @"IsNotFirstGameHistoryViewUsage"

@interface GameHistoryController() <GameHistoryTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (strong, nonatomic) IBOutlet UILabel *noEventsLabel;
@property (nonatomic) CGFloat headerHeight;

@property (nonatomic, strong) CalloutsContainerView *firstTimeUsageCallouts;

@end

@implementation GameHistoryController
@synthesize game,isCurlAnimation;


#pragma mark Table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self getNumberOfGamePoints];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int number = [[self getGamePointAtMostRecentIndex:(int)section] getNumberOfEvents];
    if ((section == 0) && [self.game.positionalBeginEvent isPickupDisc]) {
        number++;
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Event* event = [self getEventForIndex:indexPath];
    
    GameHistoryTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"EventCell"];
    cell.backgroundColor = [event isOffense] ? [ColorMaster getOffenseEventColor] : [ColorMaster getDefenseEventColor];
    cell.imageView.image = [ImageMaster getImageForEvent: event];
    cell.descriptionLabel.text = [event getDescription];
    cell.undoButton.visible = indexPath.section == 0 && indexPath.row == 0 && self.embeddedMode;
    if (cell.undoButton.visible) {
        cell.delegate = self;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UPoint* point = [self getGamePointAtMostRecentIndex:indexPath.section];
    Event* event = [self getEventForIndex:indexPath];
    
    EventChangeViewController* changeController = [[EventChangeViewController alloc] init];
    changeController.event = event;
    changeController.pointDescription = [self.game getPointNameAtMostRecentIndex:(int)[indexPath section]];
    changeController.playersInPoint = point.line ? point.line : [self.game currentLineSorted];
    NSIndexPath* topVisibleRow = [self.eventTableView indexPathForCell:[self.eventTableView.visibleCells objectAtIndex:0]];
    changeController.completion = ^{
        [self.game saveWithUpload];
        [self.eventTableView reloadData];
        [self.eventTableView scrollToRowAtIndexPath:topVisibleRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    };
    
    if (self.embeddedMode) {
        changeController.modalMode = YES;
        UINavigationController* navChangeController = [[UINavigationController alloc] initWithRootViewController:changeController];
        navChangeController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navChangeController animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:changeController animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GameHistoryHeaderView* header = [self createHeader];
    
    UPoint* point = [self getGamePointAtMostRecentIndex:(int)section];

    NSString* pointName = @"";
    BOOL isOline = false;
    if ([self.game.positionalBeginEvent isPullBegin]) {
        if (section == 0) {
            pointName = @"Current";
            isOline = [self.game.positionalBeginEvent isOffense];
        } else {
            pointName = [game getPointNameAtMostRecentIndex:section - 1];
            isOline = [game isPointOline: point];
        }
    } else {
        pointName = [game getPointNameAtMostRecentIndex:(int)section];
        isOline = [game isPointOline: point];
    }

    [header setInfoForGame:self.game point:point withName:pointName isOline:isOline];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isCurlAnimation) {
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(popWithCurl)];
        self.navigationItem.leftBarButtonItem = settingsButton;
    }
    self.noEventsLabel.hidden = [self hasEvents];
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

#pragma mark - Point/Event Lookups

-(UPoint*)getGamePointAtMostRecentIndex: (int) index {
    // if there is a beginPull then we have a "pseudo" point to hold it
    if ([self.game.positionalBeginEvent isPullBegin]) {
        if (index == 0) {
            UPoint* fakePoint = [[UPoint alloc] init];
            [fakePoint addEvent:self.game.positionalBeginEvent];
            fakePoint.line = [self.game currentLineSorted];
            return fakePoint;
        } else {
            return [self.game getPointAtMostRecentIndex:index - 1];
        }
    } else {
        return [self.game getPointAtMostRecentIndex:index];
    }
}

-(int)getNumberOfGamePoints {
    int numberOfPoints = [self.game getNumberOfPoints];
    // if there is a beginPull then we have a "pseudo" point to hold it
    if ([self.game.positionalBeginEvent isPullBegin]) {
        numberOfPoints++;
    }
    return numberOfPoints;
}

-(Event*)getEventForIndex: (NSIndexPath *)indexPath {
    UPoint* point = [self getGamePointAtMostRecentIndex:indexPath.section];
    if ((indexPath.section == 0) && self.game.positionalBeginEvent) {
        // first row is the begin (pickup or pull start) event...others are normal events
        if (indexPath.row == 0) {
            return self.game.positionalBeginEvent;
        } else {
            return [point getEventAtMostRecentIndex:indexPath.row - 1];
        }
    } else {
        return [point getEventAtMostRecentIndex:indexPath.row];
    }
}

-(BOOL)hasEvents {
    return[[Game getCurrentGame] hasEvents] || [Game getCurrentGame].positionalBeginEvent;
}

#pragma mark - Cell delegate

-(void)undoButtonTapped {
    if (self.embeddedUndoTappedBlock) {
        self.embeddedUndoTappedBlock();
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

-(void)refresh {
    BOOL hasEvents = [self hasEvents];
    if (hasEvents) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:self.eventTableView duration:0.1f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
                [self.eventTableView reloadData];
            } completion:nil];
        });
    }
    self.noEventsLabel.hidden = hasEvents;
}

-(void)adjustInsetForTabBar {
    [self.eventTableView adjustInsetForTabBar];
}


@end
