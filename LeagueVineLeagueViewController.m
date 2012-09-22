//
//  LeagueVineLeagueViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineLeagueViewController.h"
#import "ColorMaster.h"
#import "LeaguevineLeague.h"
#import "LeaguevineClient.h"

@interface LeagueVineLeagueViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LeagueVineLeagueViewController

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
    [self setTableView:nil];

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
    return [self.leagues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* STD_ROW_TYPE = @"stdRowType";
    
    LeaguevineLeague* league = [self.leagues objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
        //cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
        
    cell.textLabel.text = league.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

#pragma mark Client interaction

-(void)refresh {
    [self startBusyDialog];
    [self.leaguevineClient retrieveLeagues:^(LeaguevineInvokeStatus status, id result) {

        if (status == LeaguevineInvokeOK) {
            self.leagues = result;
            [self.tableView reloadData];
        NSLog(@"reloading table");
            [self stopBusyDialog];
            // TODO position to current league selection
        } else {
            self.leagues = [NSArray array];
            [self stopBusyDialog];
            [self alertFailure:status];
            // pop back to previous controller or all the way back?
        }
    }];
}


@end
