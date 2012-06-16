//
//  LeaguevineSelectorAbstractViewController.m
//  UltimateIPhone
//
//  Created by james on 9/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineSelectorAbstractViewController.h"
#import "LeaguevineClient.h"
#import "ColorMaster.h"
#import "NSArray+Utilities.h"
#import "NSString+manipulations.h"
#import "LeaguevineItem.h"

@interface LeaguevineSelectorAbstractViewController()

@property (strong, nonatomic) IBOutlet UIView *waitingView;
@property (strong, nonatomic) IBOutlet UIView *itemListView;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation LeaguevineSelectorAbstractViewController


- (id)init {
    return [self initWithNibName:@"LeaguevineSelectorAbstractViewController" bundle:nil];
}

#pragma mark - Custom accessors

-(void)setItems:(NSArray *)items {
    _items = items;
    self.filteredItems = items;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.tintColor = [ColorMaster getSearchBarTintColor];
    [self showWaitingView];
    [self refresh];
}

- (void)viewDidUnload {
    [self setWaitingView:nil];
    [self setItemListView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {

}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* STD_ROW_TYPE = @"stdRowType";
    
    LeaguevineItem* item = [self.filteredItems objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [self createCell:STD_ROW_TYPE];
    }
    
    [self populateCell:cell withItem:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LeaguevineItem* item = [self.filteredItems objectAtIndex:indexPath.row];
    [self itemSelected: item];
}

-(UITableViewCell*)createCell: (NSString*) rowType {
    UITableViewCell* cell = [[UITableViewCell alloc]
            initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:rowType];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

-(void)populateCell: (UITableViewCell*) cell withItem: (LeaguevineItem*) item {
    cell.textLabel.text = [self getItemDescription: item];
}

#pragma mark - Waiting View

-(void)showWaitingView {
    self.waitingView.hidden = NO;
}

-(void)hideWaitingView {
    [UIView  transitionFromView:self.waitingView toView:self.itemListView duration:0.4 options: UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

#pragma mark - Error alerting

-(void)alertError:(NSString*) title message: (NSString*) message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: title
                                                        message: message
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

-(void)alertFailure: (LeaguevineInvokeStatus) type {
    [self alertError:@"Error talking to Leaguevine" message:[self errorDescription:type]];
}

-(NSString*)errorDescription: (LeaguevineInvokeStatus) type {
    switch(type) {
        case LeaguevineInvokeNetworkError:
            return @"Network error detected...are you connected to the internet?";
        case LeaguevineInvokeInvalidResponse:
            return @"Leaguevine is having problems. Try later";
        default:
            return @"Unkown error. Try later";
    }
}

-(void)errorAlertDismissed {
    // subclasses can implement
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self errorAlertDismissed];
}

#pragma mark - Search delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self applySearchFilter];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Search filtering

-(void)applySearchFilter {
    NSString* searchString = [self getSearchString];
    if ([searchString isNotEmpty]) {
        self.filteredItems = [self.items filter:^(id item) {
            NSString* itemString = [item listDescription];
            BOOL matchesFilter = [itemString rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound;
            return matchesFilter;
        }];
    } else {
        self.filteredItems = self.items;
    }
    [self.mainTableView reloadData];
}

-(NSString*)getSearchString {
    return self.searchBar.text;
}

#pragma mark - Selection 

-(void)itemSelected: (LeaguevineItem*) item {
    if (self.selectedBlock) {
        self.selectedBlock(item);
    }
}

#pragma mark - Refresh

-(void)refresh {
    [self refreshItems];
}

-(void)refreshItems {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
}

- (void)refreshItems:(LeaguevineInvokeStatus)status result:(id)result {
    if (status == LeaguevineInvokeOK) {
        self.items = result;
        [self.mainTableView reloadData];
        [self hideWaitingView];
        if ([self.items count] < 1) {
            [self showNoResults];
        } else {
            int bestRow = [self getBestRowPositionAfterRefresh];
            if (bestRow != 0) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow: bestRow inSection: 0];
                [self.mainTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }
    } else {
        self.items = [NSArray array];
        [self.activityIndicator stopAnimating];
        [self alertFailure:status];
    }
}

-(void)showNoResults {
    self.searchBar.hidden = YES;
    self.noResultsLabel.hidden = NO;
    self.noResultsLabel.text = [self getNoResultsText];
}

-(NSString*)getNoResultsText {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return nil;
}

-(NSString*)getItemDescription: (LeaguevineItem*) item {
    return [item listDescription];
}

-(int)getBestRowPositionAfterRefresh {
    return 0;
}

@end
