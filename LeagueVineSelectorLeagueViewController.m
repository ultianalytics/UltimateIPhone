//
//  LeagueVineSelectorLeagueViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineSelectorLeagueViewController.h"
#import "ColorMaster.h"
#import "LeaguevineLeague.h"
#import "LeaguevineClient.h"

@interface LeagueVineSelectorLeagueViewController ()

@end

@implementation LeagueVineSelectorLeagueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Leaguevine League";
    }
    return self;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    LeaguevineLeague* league = [self.filteredItems objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
        
    cell.textLabel.text = league.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LeaguevineItem* item = [self.filteredItems objectAtIndex:indexPath.row];
    [self itemSelected: item];
}

#pragma mark Client interaction

-(void)refresh {
    [self startBusyDialog];
    [self.leaguevineClient retrieveLeagues:^(LeaguevineInvokeStatus status, id result) {

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
    }];
}


@end
