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
#import "PlayerSelectionTableViewCell.h"
#import "Constants.h"

@interface EventChangeViewController ()

@property (strong, nonatomic) IBOutlet UILabel *pointDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *player1Label;
@property (strong, nonatomic) IBOutlet UILabel *player2Label;
@property (strong, nonatomic) IBOutlet UITableView *player1TableView;
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
    return [self.players count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PlayerSelectionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [self createCell];
    }
    
    if (tableView == self.player1TableView || tableView == self.player2TableView) {
        cell.player = [self.players objectAtIndex:[indexPath row]];
        
        NSString* selectedPlayerForThisTable;
        if (tableView == self.player1TableView) {
            selectedPlayerForThisTable = [self.event isOffense] ? self.offenseEvent.passer.name : self.defenseEvent.defender.name;
        } else {
            selectedPlayerForThisTable = [self.event isOffense] ? self.offenseEvent.receiver.name : nil;
        }
        BOOL isChoice = [selectedPlayerForThisTable isEqualToString:cell.player.name];
        cell.chosen = isChoice;
    } 
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Player* player = [self.players objectAtIndex:[indexPath row]];
    BOOL isChange = NO;
    if (tableView == self.player1TableView) {
        if ([self.event isOffense])  {
            isChange = [self.offenseEvent.passer.name isEqualToString:player.name];
            self.offenseEvent.passer = player;
        } else {
            [self.defenseEvent.defender.name isEqualToString:player.name];
            self.defenseEvent.defender = player;
        }
    } else if (tableView == self.player2TableView) {
        isChange = [self.offenseEvent.receiver.name isEqualToString:player.name];
        self.offenseEvent.receiver = player;
    }
    [self addSaveButton];
    [self refresh];
}

#pragma mark Event Handling

-(void)doneButtonPressed {
    
}


#pragma mark Miscellaneous

-(void)addSaveButton {
    UINavigationItem* currentNavItem = self.navigationController.navigationBar.topItem;
    if (!currentNavItem.rightBarButtonItem) {
        currentNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
    }
}

-(void)refresh {
    [self.player1TableView reloadData];
    [self.player2TableView reloadData];
}

-(void)stylize {
    [ColorMaster styleAsWhiteLabel:self.pointDescriptionLabel size:16];
    [ColorMaster styleAsWhiteLabel:self.player1Label size:16];
    [ColorMaster styleAsWhiteLabel:self.player2Label size:16];
    self.player1TableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.player2TableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    [self setPlayer2TableView:nil];
    [self setPointDescriptionLabel:nil];
    [self setPointDescriptionLabel:nil];
    [super viewDidUnload];
}

#pragma mark Misc

-(NSArray*)eligibleActions {
    return @[@"Catch"];
}

-(PlayerSelectionTableViewCell*)createCell {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerSelectionTableViewCell class]) owner:nil options:nil];
    PlayerSelectionTableViewCell*  cell = (PlayerSelectionTableViewCell *)[nib objectAtIndex:0];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    return cell;
}


@end
