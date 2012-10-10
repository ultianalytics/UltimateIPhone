//
//  EventChangeViewController.m
//  UltimateIPhone
//
//  Created by james on 10/10/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "EventChangeViewController.h"
#import "ColorMaster.h"
#import "Event.h"
#import "Player.h"

@interface EventChangeViewController ()

@property (strong, nonatomic) IBOutlet UILabel *pointDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *player1Label;
@property (strong, nonatomic) IBOutlet UILabel *player2Label;
@property (strong, nonatomic) IBOutlet UITableView *player1TableView;
@property (strong, nonatomic) IBOutlet UITableView *actionTableView;
@property (strong, nonatomic) IBOutlet UITableView *player2TableView;

@end

@implementation EventChangeViewController

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* STD_ROW_TYPE = @"stdRowType";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark Event Handling

-(void)doneButtonPressed {
    
}


#pragma mark Miscellaneous

-(void)addDoneButton {
    UINavigationItem* currentNavItem = self.navigationController.navigationBar.topItem;
    currentNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
}

#pragma mark Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Game Event";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addDoneButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPlayer1Label:nil];
    [self setPlayer2Label:nil];
    [self setPlayer1TableView:nil];
    [self setActionTableView:nil];
    [self setPlayer2TableView:nil];
    [self setPointDescriptionLabel:nil];
    [self setPointDescriptionLabel:nil];
    [super viewDidUnload];
}

@end
