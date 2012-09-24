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

@property (nonatomic, strong) UIAlertView* busyView;


@end

@implementation LeaguevineSelectorAbstractViewController

#pragma mark - Custom accessors

-(void)setItems:(NSArray *)items {
    _items = items;
    self.filteredItems = items;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.tintColor = [ColorMaster getSearchBarTintColor];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [self refresh];
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
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    cell.textLabel.text = item.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LeaguevineItem* item = [self.filteredItems objectAtIndex:indexPath.row];
    [self itemSelected: item];
}

#pragma mark - Busy Dialog

-(void)startBusyDialog {
    self.busyView = [[UIAlertView alloc] initWithTitle: @"Talking to Leaguevine..."
                                          message: nil
                                         delegate: self
                                cancelButtonTitle: nil
                                otherButtonTitles: nil];
    // Add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(50,50, 200, 50);
    [self.busyView addSubview:spinner];
    [spinner startAnimating];
    
    [self.busyView show];
}

-(void)stopBusyDialog {
    if (self.busyView) {
        [self.busyView dismissWithClickedButtonIndex:0 animated:NO];
        [self.busyView removeFromSuperview];
    }
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
            NSString* itemString = [item name];
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
    [self startBusyDialog];
    [self refreshItems];
}

-(void)refreshItems {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
}

- (void)refreshItems:(LeaguevineInvokeStatus)status result:(id)result {
    if (status == LeaguevineInvokeOK) {
        self.items = result;
        [self.mainTableView reloadData];
        [self stopBusyDialog];
        // TODO position to current league selection
    } else {
        self.items = [NSArray array];
        [self stopBusyDialog];
        [self alertFailure:status];
        // pop back to previous controller or all the way back?
    }
}



@end
