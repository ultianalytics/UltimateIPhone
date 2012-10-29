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
#import "DarkButton.h"
#import "Team.h"
#import "UIView+Convenience.h"

@interface EventChangeViewController ()

@property (strong, nonatomic) IBOutlet UILabel *pointDescriptionLabel;
@property (strong, nonatomic) IBOutlet UITableView *player1TableView;
@property (strong, nonatomic) IBOutlet UITableView *player2TableView;
@property (strong, nonatomic) IBOutlet UILabel *eventTypeDescriptionLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *eventActionSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *passedToLabel;
@property (strong, nonatomic) IBOutlet UITextField *hangtimeTextField;
@property (strong, nonatomic) IBOutlet UILabel *textFieldLabel;

@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) OffenseEvent* offenseEvent;
@property (strong, nonatomic) DefenseEvent* defenseEvent;
@property (strong, nonatomic) OffenseEvent* originalOffenseEvent;
@property (strong, nonatomic) DefenseEvent* originalDefenseEvent;
@property (strong, nonatomic) Event *originalEvent;

@property (nonatomic) BOOL showingFullTeam;

@end

@implementation EventChangeViewController
@dynamic offenseEvent;
@dynamic defenseEvent;
@dynamic originalOffenseEvent;
@dynamic originalDefenseEvent;

#pragma mark Custom accessors

-(void)setPlayersInPoint:(NSArray *)playerList {
    _playersInPoint = playerList;
    [self initSortedPlayersIncludingTeam: NO];
}

-(void)setEvent:(Event *)event {
    _event = [event copy];
    self.originalEvent = event;
    [self initSortedPlayersIncludingTeam: NO];
}

-(OffenseEvent*)offenseEvent {
    return (OffenseEvent*)self.event;
}

-(DefenseEvent*)defenseEvent {
    return (DefenseEvent*)self.event;
}

-(OffenseEvent*)originalOffenseEvent {
    return (OffenseEvent*)self.originalEvent;
}

-(DefenseEvent*)originalDefenseEvent {
    return (DefenseEvent*)self.originalEvent;
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

- (void)addTableFooterView: (UITableView*)tableView {
    if (self.showingFullTeam) {
        tableView.tableFooterView = nil;
    } else {
        CGFloat tableWidth = tableView.bounds.size.width;
        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 50)];
        footerView.backgroundColor = [UIColor clearColor];
        DarkButton* footerButton = [[DarkButton alloc] initWithFrame:CGRectMake(0, 10, tableWidth, 34)];
        [footerButton setTitle: @"Show Full Team" forState:UIControlStateNormal];
        [footerButton addTarget:self action:@selector(showFullTapped) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:footerButton];
        tableView.tableFooterView = footerView;
    }
}

#pragma mark Event Handling

-(void)doneButtonPressed {
    self.originalEvent.action = self.event.action;
    if ([self.event isOffense]) {
        self.originalOffenseEvent.passer = self.offenseEvent.passer;
        self.originalOffenseEvent.receiver = self.offenseEvent.receiver;
    } else {
        self.originalDefenseEvent.defender = self.defenseEvent.defender;
        if ([self.defenseEvent isPull]) {
            float hangtime = [self.hangtimeTextField.text floatValue];
            self.originalDefenseEvent.pullHangtimeMilliseconds = hangtime * 1000;
        }
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
        if (self.event.action == Drop) {
            self.offenseEvent.receiver = self.originalOffenseEvent.receiver ? self.originalOffenseEvent.receiver : [Player getAnonymous];
        }
    } else {
        // d/throway
        if (self.event.action == De || self.event.action == Throwaway) {
            self.event.action = self.eventActionSegmentedControl.selectedSegmentIndex == 0 ? De : Throwaway;
            if (self.event.action == De) {
                self.defenseEvent.defender = self.originalDefenseEvent.defender ? self.originalDefenseEvent.defender : [Player getAnonymous];
            }
        }
    }
    [self configureForEventType: NO];
    [self addSaveButton];
}

-(void)showFullTapped {
    [self initSortedPlayersIncludingTeam: YES];
    self.showingFullTeam = YES;
    [self refresh];
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
    self.pointDescriptionLabel.text = [NSString stringWithFormat: @"Point: %@",[self.pointDescription lowercaseString]];
    [self configureForEventType: YES];
    [self addTableFooterView: self.player1TableView];
    [self addTableFooterView: self.player2TableView];
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
    [self setButtonTest:nil];
    [self setHangtimeTextField:nil];
    [self setTextFieldLabel:nil];
    [super viewDidUnload];
}

#pragma mark Misc

-(void)addSaveButton {
    UINavigationItem* currentNavItem = self.navigationController.navigationBar.topItem;
    if (!currentNavItem.rightBarButtonItem) {
        [currentNavItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Save Change" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)]animated: YES];
    }
}

-(void)refresh {
    [self.player1TableView reloadData];
    [self.player2TableView reloadData];
    [self addTableFooterView:self.player1TableView];
    [self addTableFooterView:self.player2TableView];
}

-(void)stylize {
    [ColorMaster styleAsWhiteLabel:self.pointDescriptionLabel size:14];
    [ColorMaster styleAsWhiteLabel:self.eventTypeDescriptionLabel size:18];
    [ColorMaster styleAsWhiteLabel:self.passedToLabel size:18];
    [ColorMaster styleAsWhiteLabel:self.textFieldLabel size:14];
    self.player1TableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.player2TableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

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

-(void)configureForEventType: (BOOL)initial {
    BOOL animate = !initial;
    self.passedToLabel.hidden = YES;
    self.player1TableView.hidden = NO;
    self.player2TableView.hidden = YES;
    self.eventActionSegmentedControl.hidden = NO;
    self.textFieldLabel.hidden = YES;
    self.hangtimeTextField.hidden = YES;

    if ([self.event isOffense]) {
        switch (self.event.action) {
            case Catch: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Catch";
                self.passedToLabel.hidden = NO;
                self.player2TableView.hidden = NO;
                break;
            }
            case Goal: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Our Goal";
                self.passedToLabel.hidden = NO;
                self.player2TableView.hidden = NO;
                break;
            }
            case Drop: {
                self.eventTypeDescriptionLabel.text = @"Our Turnover:";
                [self show: self.player2TableView shouldShow: YES animate: animate];
                [self show: self.passedToLabel shouldShow: YES animate: animate];
                [self configureActionControlFor:@"Drop" and:@"Throwaway" initial:initial ? @"Drop" : nil];
                [self movePlayer1TableToCenter:NO animate:animate];
                break;                
            }
            case Throwaway: {
                self.eventTypeDescriptionLabel.text = @"Our Turnover:";
                [self show: self.player2TableView shouldShow: NO animate: animate];
                [self show: self.passedToLabel shouldShow: NO animate: animate];
                [self configureActionControlFor:@"Drop" and:@"Throwaway" initial:initial ? @"Throwaway" :nil];
                [self movePlayer1TableToCenter:YES animate:animate];
                break;                
            }
            default: {
            }
        }
    } else {
        [self movePlayer1TableToCenter:YES animate:NO];
        switch (self.event.action) {
            case Pull: {
                self.textFieldLabel.hidden = NO;
                self.textFieldLabel.text = @"Hang Time:";
                self.hangtimeTextField.hidden = NO;
                if (self.defenseEvent.pullHangtimeMilliseconds) {
                    self.hangtimeTextField.text = [DefenseEvent formatHangtime:self.defenseEvent.pullHangtimeMilliseconds];
                }
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Pull";
                break;                
            }
            case PullOb: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Pull OB";
                break;
            }
            case Goal: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Their Goal";
                self.player1TableView.hidden = YES;
                break;                
            }
            case De: {
                self.eventTypeDescriptionLabel.text = @"Their Turnover:";
                [self configureActionControlFor:@"D" and:@"Throwaway" initial:initial ? @"D" :nil];
                [self show: self.player1TableView shouldShow: YES animate: animate];
                break;                
            }
            case Throwaway:{
                self.eventTypeDescriptionLabel.text = @"Their Turnover:";
                [self configureActionControlFor:@"D" and:@"Throwaway" initial:initial ? @"Throwaway" :nil];
                [self show: self.player1TableView shouldShow: NO animate: animate];
                break;
            }
            default: {
            }
        }
    }
}

-(void)configureActionControlFor: (NSString*)action1 and: (NSString*)action2 initial: (NSString*)initial {
    [self.eventActionSegmentedControl setTitle:action1 forSegmentAtIndex:0];
    [self.eventActionSegmentedControl setTitle:action2 forSegmentAtIndex:1];
    if (initial) {
        self.eventActionSegmentedControl.selectedSegmentIndex = [action1 isEqualToString:initial ] ? 0 : 1;
    }
}

-(void)show: (UIView*) view shouldShow: (BOOL)show animate: (BOOL) animate {
    if (animate) {
        view.alpha = show ? 0.0 : 1.0;
        view.hidden = NO;
        [UIView animateWithDuration:.5 animations:^{
            view.alpha = show ? 1.0 : 0.0;
        } completion:^(BOOL finished) {
            view.hidden = !show;
        }];
    } else {
        view.hidden = !show;
    }
}

-(void)movePlayer1TableToCenter: (BOOL)moveToCenter animate: (BOOL) animate {
    CGFloat xOriginWhenAtCenter = (self.view.bounds.size.width - self.player1TableView.bounds.size.width) / 2;
    CGFloat xOriginWhenLeft = 10.f;
    if (animate) {

        [UIView animateWithDuration:.5 animations:^{
            self.player1TableView.frameX = moveToCenter ? xOriginWhenAtCenter : xOriginWhenLeft;
        } completion:^(BOOL finished) {
            
        }];
        self.player1TableView.frameX = moveToCenter ? xOriginWhenAtCenter : xOriginWhenLeft;
    } else {
        self.player1TableView.frameX = moveToCenter ? xOriginWhenAtCenter : xOriginWhenLeft;
    }
}

-(void)initSortedPlayersIncludingTeam: (BOOL) includeTeam {
    NSMutableSet* playerSet = [NSMutableSet setWithArray: self.playersInPoint ? self.playersInPoint : @[]];
    if (includeTeam) {
        [playerSet addObjectsFromArray:[Team getCurrentTeam].players];
    }
    [self ensureEventPlayersInPlayersList: playerSet];
    self.players = [[[playerSet allObjects] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    [self.players addObject:[Player getAnonymous]];
}

-(void)ensureEventPlayersInPlayersList: (NSMutableSet*)playersSet {
    if ([self.event isOffense]) {
        [self ensureEventPlayer:self.offenseEvent.passer inPlayersList:playersSet];
        [self ensureEventPlayer:self.offenseEvent.receiver inPlayersList:playersSet];
    } else {
        [self ensureEventPlayer:self.defenseEvent.defender inPlayersList:playersSet];
    }
}

-(void)ensureEventPlayer: (Player*) eventPlayer inPlayersList: (NSMutableSet*) playerSet {
    if (eventPlayer == nil || [eventPlayer isAnonymous] ) {
        return;
    }
    if (self.event && playerSet) {
        NSSet* playersCopy = [playerSet copy];
        for (Player* listPlayer in playersCopy) {
            if ([eventPlayer.name isEqualToString:listPlayer.name]) {
                return;
            }
        }
        [playerSet addObject:eventPlayer];
    }
}

#pragma mark TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.hangtimeTextField) {
        [self addSaveButton];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.hangtimeTextField) {
        [self addSaveButton];
    }
    return YES;
}

@end
