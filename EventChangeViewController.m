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
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "Player.h"

@interface EventChangeViewController ()

@property (strong, nonatomic) IBOutlet UILabel *pointDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *player1Label;
@property (strong, nonatomic) IBOutlet UILabel *player2Label;
@property (strong, nonatomic) IBOutlet UITableView *player1TableView;
@property (strong, nonatomic) IBOutlet UITableView *actionTableView;
@property (strong, nonatomic) IBOutlet UITableView *player2TableView;

@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) OffenseEvent* offenseEvent;
@property (strong, nonatomic) DefenseEvent* defenseEvent;

@end

@implementation EventChangeViewController
@dynamic offenseEvent;
@dynamic defenseEvent;

#pragma mark Custom accessors

-(void)setPlayersInPoint:(NSArray *)playerList {
    _playersInPoint = playerList;
    self.players = [NSMutableArray arrayWithArray:self.playersInPoint];
    [self.players addObject:[Player getAnonymous]];
}

-(OffenseEvent*)offenseEvent {
    return (OffenseEvent*)self.event;
}

-(DefenseEvent*)defenseEvent {
    return (DefenseEvent*)self.event;
}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.player1TableView || tableView == self.player2TableView  ? [self.players count] : [[self eligibleActions] count];
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
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
    
    if (tableView == self.player1TableView || tableView == self.player2TableView) {
        cell.textLabel.text = [[self.players objectAtIndex:[indexPath row]] name];
        NSString* selectedPlayerForThisTable;
        NSString* selectedPlayerForOtherTable;
        if (tableView == self.player1TableView) {
            selectedPlayerForThisTable = [self.event isOffense] ? self.offenseEvent.passer.name : self.defenseEvent.defender.name;
            selectedPlayerForOtherTable = [self.event isOffense] ? self.offenseEvent.receiver.name : nil;
        } else {
            selectedPlayerForThisTable = [self.event isOffense] ? self.offenseEvent.receiver.name : nil;
            selectedPlayerForOtherTable = [self.event isOffense] ? self.offenseEvent.passer.name : self.defenseEvent.defender.name;
        }
        BOOL isSelected = [selectedPlayerForThisTable isEqualToString:cell.textLabel.text];
        cell.highlighted = isSelected;
        BOOL isEligible = [selectedPlayerForOtherTable isEqualToString:cell.textLabel.text];
//        cell.textLabel.textColor = isEligible ? [UIColor blackColor] : [UIColor grayColor];
        cell.textLabel.enabled = isEligible;

    } else {
        NSString* eligibleAction = [[self eligibleActions] objectAtIndex:[indexPath row]];
        cell.textLabel.text = eligibleAction;
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

-(void)refresh {
    [self.player1TableView reloadData];
    [self.player2TableView reloadData];
}

-(void)stylize {
    [ColorMaster styleAsWhiteLabel:self.pointDescriptionLabel size:16];
    [ColorMaster styleAsWhiteLabel:self.player1Label size:16];
    [ColorMaster styleAsWhiteLabel:self.player2Label size:16];
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
    [self stylize];
    [self addDoneButton];
    self.pointDescriptionLabel.text = self.pointDescription;
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

#pragma mark Misc

-(NSArray*)eligibleActions {
    return @[@"Catch"];
}

@end
