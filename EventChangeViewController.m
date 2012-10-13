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
#import "UltimateSegmentedControl.h"

@interface EventChangeViewController ()

@property (strong, nonatomic) IBOutlet UILabel *pointDescriptionLabel;
@property (strong, nonatomic) IBOutlet UITableView *player1TableView;
@property (strong, nonatomic) IBOutlet UITableView *player2TableView;
@property (strong, nonatomic) IBOutlet UILabel *eventTypeDescriptionLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *eventActionSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *passedToLabel;

@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) OffenseEvent* offenseEvent;
@property (strong, nonatomic) DefenseEvent* defenseEvent;
@property (strong, nonatomic) Event *originalEvent;

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

-(void)setEvent:(Event *)event {
    _event = event;
    self.originalEvent = [event copy];
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
            if ([self.offenseEvent.receiver.name isEqualToString:player.name]) {
                self.offenseEvent.receiver = [Player getAnonymous];
            }
        } else {
            [self.defenseEvent.defender.name isEqualToString:player.name];
            self.defenseEvent.defender = player;
        }
    } else if (tableView == self.player2TableView) {
        isChange = [self.offenseEvent.receiver.name isEqualToString:player.name];
        self.offenseEvent.receiver = player;
        if ([self.offenseEvent.passer.name isEqualToString:player.name]) {
            self.offenseEvent.passer = [Player getAnonymous];
        }
    }
    [self addSaveButton];
    [self refresh];
}

#pragma mark Event Handling

-(void)doneButtonPressed {
    self.originalEvent.action = self.event.action;
    if ([self.event isOffense]) {
        ((OffenseEvent*)self.originalEvent).passer = self.offenseEvent.passer;
        ((OffenseEvent*)self.originalEvent).receiver = self.offenseEvent.receiver;
    } else {
        ((DefenseEvent*)self.originalEvent).defender = self.defenseEvent.defender;
    }
    if (self.completion) {
        self.completion();
    }
}

- (IBAction)eventActionChanged:(id)sender {
    self.eventTypeDescriptionLabel.text = @"Foo";
    
    if ([self.event isOffense]) {
        // drop/throway
        self.event.action = self.eventActionSegmentedControl.selectedSegmentIndex == 0 ? Drop : Throwaway;
    } else {
        // d/throway
        if (self.event.action == De || self.event.action == Throwaway) {
            self.event.action = self.eventActionSegmentedControl.selectedSegmentIndex == 0 ? De : Throwaway;
        }
    }
    [self configureForEventType];
}

#pragma mark Miscellaneous

-(void)addSaveButton {
    UINavigationItem* currentNavItem = self.navigationController.navigationBar.topItem;
    if (!currentNavItem.rightBarButtonItem) {
        currentNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save Change" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
    }
}

-(void)refresh {
    [self.player1TableView reloadData];
    [self.player2TableView reloadData];
}

-(void)stylize {
    [ColorMaster styleAsWhiteLabel:self.pointDescriptionLabel size:16];
    [ColorMaster styleAsWhiteLabel:self.eventTypeDescriptionLabel size:25];
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
    [self configureForEventType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPlayer1TableView:nil];
    [self setPlayer2TableView:nil];
    [self setPointDescriptionLabel:nil];
    [self setPointDescriptionLabel:nil];
    [self setEventTypeDescriptionLabel:nil];
    [self setPassedToLabel:nil];
    [self setEventActionSegmentedControl:nil];
    [self setPassedToLabel:nil];
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

-(void)configureForEventType {
    self.passedToLabel.hidden = YES;
    self.player1TableView.hidden = NO;
    self.player2TableView.hidden = YES;
    self.eventActionSegmentedControl.hidden = NO;

    if ([self.event isOffense]) {
        switch (self.event.action) {
            case Catch: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Catch";
                self.passedToLabel.hidden = NO;
                self.player2TableView.hidden = NO;
            }
            case Goal: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Our Goal";
                self.passedToLabel.hidden = NO;
                self.player2TableView.hidden = NO;                
            }
            case Drop: {
                self.eventTypeDescriptionLabel.text = @"Our Turnover";
                self.player2TableView.hidden = NO;
                [self.eventActionSegmentedControl setTitle:@"Drop" forSegmentAtIndex:0];
                [self.eventActionSegmentedControl setTitle:@"Throwaway" forSegmentAtIndex:1];
                self.eventActionSegmentedControl.selectedSegmentIndex = 0;
            }
            case Throwaway: {
                self.eventTypeDescriptionLabel.text = @"Our Turnover";
                [self.eventActionSegmentedControl setTitle:@"Drop" forSegmentAtIndex:0];
                [self.eventActionSegmentedControl setTitle:@"Throwaway" forSegmentAtIndex:1];
                self.eventActionSegmentedControl.selectedSegmentIndex = 1;
            }
            default: {
            }
        }
    } else {
        switch (self.event.action) {
            case Pull: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Pull";
            }
            case Goal: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Their Goal";
                self.player1TableView.hidden = YES;
            }
            case De: {
                self.eventTypeDescriptionLabel.text = @"Their Turnover";
                [self.eventActionSegmentedControl setTitle:@"D" forSegmentAtIndex:0];
                [self.eventActionSegmentedControl setTitle:@"Throwaway" forSegmentAtIndex:1];
                self.eventActionSegmentedControl.selectedSegmentIndex = 0;
            }
            case Throwaway:{
                self.player1TableView.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Their Turnover";
                [self.eventActionSegmentedControl setTitle:@"D" forSegmentAtIndex:0];
                [self.eventActionSegmentedControl setTitle:@"Throwaway" forSegmentAtIndex:1];
                self.eventActionSegmentedControl.selectedSegmentIndex = 1;
            }
            default: {
            }
        }
    }
    [self.view setNeedsDisplay];
}


@end
