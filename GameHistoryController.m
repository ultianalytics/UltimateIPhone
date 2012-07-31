//
//  GameHistoryController.m
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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

@implementation GameHistoryController
@synthesize game,isCurlAnimation;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.game getNumberOfPoints];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.game getPointAtMostRecentIndex:section] getNumberOfEvents];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.game getPointNameAtMostRecentIndex:section];
}

- (void)popWithCurl {
        //Curl up
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO]; 
        [self.navigationController popViewControllerAnimated:NO];
        [UIView commitAnimations];
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
        cell.textLabel.backgroundColor = color;
        cell.contentView.backgroundColor = color;
    }
    cell.imageView.image = [ImageMaster getImageForEvent: event];
    cell.textLabel.text = [event getDescription];
    return cell;
}

//- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [self.game getPointNamesInMostRecentOrder];
//}

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

#pragma mark - View lifecycle

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

@end
