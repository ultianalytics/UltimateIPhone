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
#import "LeaguevineEventQueue.h"
#import "Game.h"

#define kTypeHeightExpansion 46.0f

@interface EventChangeViewController ()

@property (strong, nonatomic) IBOutlet UIView *eventTypeView;
@property (strong, nonatomic) IBOutlet UIView *eventPlayersView;
@property (strong, nonatomic) IBOutlet UILabel *pointDescriptionLabel;
@property (strong, nonatomic) IBOutlet UITableView *player1TableView;
@property (strong, nonatomic) IBOutlet UITableView *player2TableView;
@property (strong, nonatomic) IBOutlet UILabel *eventTypeDescriptionLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *eventActionSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *passedToLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *textFieldLabel;
@property (strong, nonatomic) IBOutlet UIView *deleteButtonView;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) UIAlertView *hangtimeAlertView;

@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) OffenseEvent* offenseEvent;
@property (strong, nonatomic) DefenseEvent* defenseEvent;
@property (strong, nonatomic) OffenseEvent* originalOffenseEvent;
@property (strong, nonatomic) DefenseEvent* originalDefenseEvent;
@property (strong, nonatomic) Event *originalEvent;

@property (nonatomic) BOOL showingFullTeam;
@property (nonatomic) BOOL deleteRequested;

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
    if ([event isPlayEvent]) {
        [self initSortedPlayersIncludingTeam: NO];
    }
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
    return [self.event isPlayEvent] ? [self.players count] : 0;
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
    if (tableView == self.player1TableView) {
        if ([self.event isOffense])  {
            self.offenseEvent.passer = player;
            if ([self.offenseEvent.receiver.name isEqualToString:player.name]) {
                self.offenseEvent.receiver = [Player getAnonymous];
            }
        } else {
            [self.defenseEvent.defender.name isEqualToString:player.name];
            self.defenseEvent.defender = player;
        }
    } else if (tableView == self.player2TableView) {
        self.offenseEvent.receiver = player;
        if ([self.offenseEvent.passer.name isEqualToString:player.name]) {
            self.offenseEvent.passer = [Player getAnonymous];
        }
    }
    [self addSaveButton];
    [self refresh];
}

- (void)addTableFooterView: (UITableView*)tableView {
    CGFloat topMargin = 10;
    CGFloat buttonHeight = 34;
    CGFloat tabBarHeight = 50;
    CGFloat footerHeight = tabBarHeight;
    if (!self.showingFullTeam) {
        footerHeight += topMargin + buttonHeight;
    }
    CGFloat tableWidth = tableView.bounds.size.width;
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, footerHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    if (!self.showingFullTeam) {
        UIButton* footerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        footerButton.frame = CGRectMake(0, topMargin, tableWidth, buttonHeight);
        footerButton.titleLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:12];
        footerButton.titleLabel.tintColor = [UIColor blackColor];
        [footerButton setTitle: @"Show Full Team" forState:UIControlStateNormal];
        [footerButton addTarget:self action:@selector(showFullTapped) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:footerButton];
    }
    tableView.tableFooterView = footerView;
}

#pragma mark Event Handling

-(void)doneButtonPressed {
    if ([self.event isPullIb] && [self textFieldMs] > 60000) {
        [self alertUnreasonbleHangtime];
        return;
    }
    [self commitChanges];
    [self close];
}

-(void)cancelPressed {
    [self close];
}

-(IBAction)deleteTapped:(id)sender {
    self.deleteRequested = YES;
    [self close];
}

- (IBAction)eventActionChanged:(id)sender {
    self.eventTypeDescriptionLabel.text = @"Foo";
    if ([self.event isOpponentPull]) {
        self.event.action = self.eventActionSegmentedControl.selectedSegmentIndex == 1 ? OpponentPullOb : OpponentPull;
    } else if ([self.event isOffense]) {
        // offense turnover
        switch (self.eventActionSegmentedControl.selectedSegmentIndex)
        {
            case 0:
                self.event.action = Drop;
                break;
            case 1:
                self.event.action = Throwaway;
                break;
            case 2:
                self.event.action = Stall;
                break;
            case 3:
                self.event.action = MiscPenalty;
                break;
            default:
                break;
        }
        if (self.event.action == Drop) {
            self.offenseEvent.receiver = self.originalOffenseEvent.receiver ? self.originalOffenseEvent.receiver : [Player getAnonymous];
        }
    } else {
        // defense d or throwaway
        if (self.event.action == De || self.event.action == Throwaway) {
            self.event.action = self.eventActionSegmentedControl.selectedSegmentIndex == 0 ? De : Throwaway;
            if (self.event.action == De) {
                self.defenseEvent.defender = self.originalDefenseEvent.defender ? self.originalDefenseEvent.defender : [Player getAnonymous];
            }
        // pull (in-bounds or OB)
        } else if (self.event.action == Pull || self.event.action == PullOb) {
            self.event.action = self.eventActionSegmentedControl.selectedSegmentIndex == 0 ? Pull : PullOb;
            [self showTextField: self.event.action == Pull animate:YES];
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
    if (self.modalMode) {
        UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelPressed)];
        self.navigationItem.leftBarButtonItem = cancelBarItem;
    }
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    [self stylize];
    self.pointDescriptionLabel.text = [NSString stringWithFormat: @"Point: %@",[self.pointDescription lowercaseString]];
    [self configureForEventType: YES];
    [self addTableFooterView: self.player1TableView];
    [self addTableFooterView: self.player2TableView];
    [self addDeleteButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Misc

-(void)addSaveButton {
    UINavigationItem* currentNavItem = self.navigationController.navigationBar.topItem;
    if (!currentNavItem.rightBarButtonItem) {
        [currentNavItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Save Change" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)]animated: YES];
    }
}

-(void)addDeleteButton {
    if (self.deleteAllowed) {
        self.deleteButtonView.hidden = NO;
        self.player1TableView.frameHeight = self.player1TableView.frameHeight - self.deleteButtonView.frameHeight;
        self.player2TableView.frameHeight = self.player2TableView.frameHeight - self.deleteButtonView.frameHeight;
    }
}

-(void)refresh {
    [self.player1TableView reloadData];
    [self.player2TableView reloadData];
    [self addTableFooterView:self.player1TableView];
    [self addTableFooterView:self.player2TableView];
}

-(void)stylize {

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
    [self showTextField:NO animate:NO];
    self.textFieldLabel.hidden = YES;
    self.textField.hidden = YES;

    if ([self.event isOffense]) {
        switch (self.event.action) {
            case PickupDisc: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Pickup Disc";
                break;
            }
            case PullBegin: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Opponent Pull Begin";
                self.player1TableView.hidden = YES;
                break;
            }
            case OpponentPull: {
                self.eventTypeDescriptionLabel.text = @"Opponent Pull";
                self.player1TableView.hidden = YES;
                [self configureActionControlFor:@[@"In Bounds", @"OB"] initial: initial ? @"In Bounds" : nil];
                break;
            }
            case OpponentPullOb: {
                self.eventTypeDescriptionLabel.text = @"Opponent Pull";
                self.player1TableView.hidden = YES;
                [self configureActionControlFor:@[@"In Bounds", @"OB"] initial: initial ? @"OB" : nil];
                break;
            }
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
                self.eventTypeDescriptionLabel.text = @"Our Turnover";
                [self show: self.player2TableView shouldShow: YES animate: animate];
                [self show: self.passedToLabel shouldShow: YES animate: animate];
                [self configureActionControlFor:@[@"Drop", @"Throwaway", @"Stall", @"Misc. Penalty"] initial: initial ? @"Drop" : nil];
                [self movePlayer1TableToCenter:NO animate:animate];
                break;                
            }
            case Throwaway: {
                self.eventTypeDescriptionLabel.text = @"Our Turnover";
                [self show: self.player2TableView shouldShow: NO animate: animate];
                [self show: self.passedToLabel shouldShow: NO animate: animate];
                [self configureActionControlFor:@[@"Drop", @"Throwaway", @"Stall", @"Misc. Penalty"] initial: initial ? @"Throwaway" : nil];
                [self movePlayer1TableToCenter:YES animate:animate];
                break;                
            }
            case Stall: {
                self.eventTypeDescriptionLabel.text = @"Our Turnover";
                [self show: self.player2TableView shouldShow: NO animate: animate];
                [self show: self.passedToLabel shouldShow: NO animate: animate];
                [self configureActionControlFor:@[@"Drop", @"Throwaway", @"Stall", @"Misc. Penalty"] initial: initial ? @"Stall" : nil];
                [self movePlayer1TableToCenter:YES animate:animate];
                break;
            }
            case MiscPenalty: {
                self.eventTypeDescriptionLabel.text = @"Our Turnover";
                [self show: self.player2TableView shouldShow: NO animate: animate];
                [self show: self.passedToLabel shouldShow: NO animate: animate];
                [self configureActionControlFor:@[@"Drop", @"Throwaway", @"Stall", @"Misc. Penalty"] initial: initial ? @"Misc. Penalty" : nil];
                [self movePlayer1TableToCenter:YES animate:animate];
                break;
            }
            case Callahan: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Callahan'd";
                self.passedToLabel.hidden = YES;
                self.player2TableView.hidden = YES;
                break;
            }
            default: {
            }
        }
    } else if ([self.event isDefense]) {
        [self movePlayer1TableToCenter:YES animate:NO];
        switch (self.event.action) {
            case OpponentCatch: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Opponent Catch";
                self.player1TableView.hidden = YES;
                break;
            }
            case PickupDisc: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Opponent Pickup Disc";
                self.player1TableView.hidden = YES;
                break;
            }
            case PullBegin: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Pull Begin";
                break;
            }
            case Pull: {
                self.eventTypeDescriptionLabel.text = @"Pull";
                self.textFieldLabel.text = @"Hang Time:";
                self.textField.placeholder = @"sec.";
                [self showTextField: YES animate:NO];
                if (self.defenseEvent.pullHangtimeMilliseconds) {
                    self.textField.text = [DefenseEvent formatHangtime:self.defenseEvent.pullHangtimeMilliseconds];
                }
                [self configureActionControlFor:@[@"In Bounds", @"OB"] initial: initial ? @"In Bounds" : nil];
                break;                
            }
            case PullOb: {
                self.eventTypeDescriptionLabel.text = @"Pull";
                self.textFieldLabel.text = @"Hang Time:";
                self.textField.placeholder = @"sec.";
                [self showTextField: NO animate:NO];
                self.eventActionSegmentedControl.hidden = NO;
                [self configureActionControlFor:@[@"In Bounds", @"OB"] initial: initial ? @"OB" : nil];
                break;
            }
            case Goal: {
                self.eventActionSegmentedControl.hidden = YES;
                self.eventTypeDescriptionLabel.text = @"Their Goal";
                self.player1TableView.hidden = YES;
                break;                
            }
            case De: {
                self.eventTypeDescriptionLabel.text = @"Their Turnover";
                [self configureActionControlFor:@[@"D", @"Throwaway"] initial: initial ? @"D" : nil];
                [self show: self.player1TableView shouldShow: YES animate: animate];
                break;                
            }
            case Throwaway:{
                self.eventTypeDescriptionLabel.text = @"Their Turnover";
                [self configureActionControlFor:@[@"D", @"Throwaway"] initial: initial ? @"Throwaway" : nil];
                [self show: self.player1TableView shouldShow: NO animate: animate];
                break;
            }
            case Callahan: {
                self.eventTypeDescriptionLabel.text = @"Callahan";
                self.eventActionSegmentedControl.hidden = YES;
                [self show: self.player1TableView shouldShow: YES animate: animate];
                break;
            }
            default: {
            }
        }
    } else if ([self.event isCessationEvent]) {
        self.player1TableView.hidden = YES;
        self.player2TableView.hidden = YES;
        self.eventActionSegmentedControl.hidden = YES;
        
        switch (self.event.action) {
            case EndOfFirstQuarter: {
                self.eventTypeDescriptionLabel.text = @"End Of 1st Quarter";
                break;
            }
            case Halftime: {
                self.eventTypeDescriptionLabel.text = @"Halftime";
                break;
            }
            case EndOfThirdQuarter: {
                self.eventTypeDescriptionLabel.text = @"End Of 3rd Quarter";
                break;
            }
            case GameOver: {
                self.eventTypeDescriptionLabel.text = @"Game Over";
                break;
            }
            case EndOfFourthQuarter: {
                self.eventTypeDescriptionLabel.text = @"End Of 4th Quarter";
                break;
            }
            case EndOfOvertime: {
                self.eventTypeDescriptionLabel.text = @"End Of An Overtime";
                break;
            }
            case Timeout: {
                self.eventTypeDescriptionLabel.text = @"Timeout";
                break;
            }
            default: {
            }
        }
    }
    self.eventPlayersView.hidden = self.player1TableView.hidden && self.player2TableView.hidden;
    
    // resize the type view if don't need extra space
    if (self.eventActionSegmentedControl.hidden && self.textFieldLabel.hidden && self.textField.hidden) {
        self.eventTypeView.frameHeight = self.eventTypeView.frameHeight - kTypeHeightExpansion;
        self.eventPlayersView.frameY = self.eventPlayersView.frameY - kTypeHeightExpansion;
        self.eventPlayersView.frameHeight = self.eventPlayersView.frameHeight + kTypeHeightExpansion;
    }
}

-(void)configureActionControlFor: (NSArray*)actionTitles initial: (NSString*)initialTitle {
    self.eventActionSegmentedControl.apportionsSegmentWidthsByContent = YES;
    NSUInteger index = 0;
    for (NSString* segmentTitle in actionTitles) {
        if (index < [self.eventActionSegmentedControl numberOfSegments]) {
            [self.eventActionSegmentedControl setTitle:segmentTitle forSegmentAtIndex:index];
        } else {
            [self.eventActionSegmentedControl insertSegmentWithTitle:segmentTitle atIndex:index animated:NO];
        }
        index++;
    }
    if (initialTitle && [actionTitles indexOfObject:initialTitle] != NSNotFound) {
        self.eventActionSegmentedControl.selectedSegmentIndex = [actionTitles indexOfObject:initialTitle];
    }
    [self.eventActionSegmentedControl sizeToFit];
}

-(void)show: (UIView*) view shouldShow: (BOOL)show animate: (BOOL) animate {
    if (!show && view.hidden) {
        return;
    }
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
        }];
        self.player1TableView.frameX = moveToCenter ? xOriginWhenAtCenter : xOriginWhenLeft;
    } else {
        self.player1TableView.frameX = moveToCenter ? xOriginWhenAtCenter : xOriginWhenLeft;
    }
}

-(void)showTextField: (BOOL)show animate: (BOOL)animate{
    if (animate) {
        if (show) {
            self.textFieldLabel.alpha = 0;
            self.textField.alpha = 0;
            self.textFieldLabel.hidden = NO;
            self.textField.hidden = NO;
            [UIView animateWithDuration:.5 animations:^{
                self.textFieldLabel.alpha = 1;
                self.textField.alpha = 1;
            }];
        } else {
            [UIView animateWithDuration:.5 animations:^{
                self.textFieldLabel.alpha = 0;
                self.textField.alpha = 0;
            } completion:^(BOOL finished) {
                self.textFieldLabel.hidden = YES;
                self.textField.hidden = YES;
            }];
        }
        
    } else {
        self.textFieldLabel.hidden = !show;
        self.textField.hidden = !show;
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
    } else if ([self.event isDefense]) {
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

-(void)commitChanges {
    self.originalEvent.action = self.event.action;
    if ([self.event isOffense]) {
        self.originalOffenseEvent.passer = self.offenseEvent.passer;
        self.originalOffenseEvent.receiver = self.offenseEvent.receiver;
    } else {
        self.originalDefenseEvent.defender = self.defenseEvent.defender;
        if ([self.defenseEvent isPullIb]) {
            self.originalDefenseEvent.pullHangtimeMilliseconds = [self textFieldMs];
        }
    }
    if ([Game getCurrentGame].publishStatsToLeaguevine) {
        [[LeaguevineEventQueue sharedQueue] submitChangedEvent:self.originalDefenseEvent forGame:[Game getCurrentGame]];
    }
}

-(int)textFieldMs {
    float hangtime = [self.textField.text floatValue];
    int hangtimeMs = hangtime * 1000;
    if (hangtimeMs < 0) {
        hangtimeMs = 0;
    }
    return hangtimeMs;
}

-(void)close {
    if (self.eventMaintenanceCompletion) {
        self.eventMaintenanceCompletion(self.deleteRequested);
    }
    if (self.modalMode) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.textField) {
        [self addSaveButton];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.textField) {
        [self addSaveButton];
    }
    return YES;
}

#pragma mark Alert

-(void) alertUnreasonbleHangtime {
    // Show the confirmation.
    self.hangtimeAlertView = [[UIAlertView alloc]
                          initWithTitle: @"Long Hang Time!"
                          message: @"This hang time seems too high.  Are you sure?"
                          delegate: self
                          cancelButtonTitle: @"No"
                          otherButtonTitles: @"Yes", nil];
    [self.hangtimeAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.hangtimeAlertView) {
        if (buttonIndex == 1) {
            [self commitChanges];
            [self close];
        }
    }

}


@end
