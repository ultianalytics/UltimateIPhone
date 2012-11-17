//
//  SubstitutionViewController.m
//  UltimateIPhone
//
//  Created by james on 11/2/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "SubstitutionViewController.h"
#import "ColorMaster.h"
#import "Player.h"
#import "PlayerSelectionTableViewCell.h"
#import "Constants.h"
#import "UltimateSegmentedControl.h"
#import "DarkButton.h"
#import "Team.h"
#import "UIView+Convenience.h"
#import "UltimateSegmentedControl.h"
#import "PlayerSubstitution.h"
#import "SoundPlayer.h"

@interface SubstitutionViewController ()

@property (strong, nonatomic) IBOutlet UITableView *player1TableView;
@property (strong, nonatomic) IBOutlet UITableView *player2TableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *substitutionReasonSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *playerOutLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerInLabel;
@property (strong, nonatomic) IBOutlet UILabel *errorMessageLabel;

@property (strong, nonatomic) NSArray* playersOnBench;
@property (strong, nonatomic) PlayerSubstitution* originalPlayerSubstitution;

@end

@implementation SubstitutionViewController

#pragma mark Custom accessors

-(void)setPlayersOnField:(NSArray *)playerList {
    _playersOnField = playerList;
    [self initPlayersOnFieldAndBench];
}

-(void)setPlayerSubstitution:(PlayerSubstitution *)playerSubstitution {
    _playerSubstitution = playerSubstitution;
    self.originalPlayerSubstitution = [playerSubstitution copy];
    [self refresh];
}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.player1TableView ? [self.playersOnField count] : [self.playersOnBench count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PlayerSelectionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [self createCell];
    }
    
    if (tableView == self.player1TableView ) {
        cell.player = [self.playersOnField objectAtIndex:[indexPath row]];
        if (self.playerSubstitution) {
            cell.chosen = [cell.player isEqual:self.playerSubstitution.fromPlayer];
        }
    } else if (tableView == self.player2TableView) {
        cell.player = [self.playersOnBench objectAtIndex:[indexPath row]];
        if (self.playerSubstitution) {
            cell.chosen = [cell.player isEqual:self.playerSubstitution.toPlayer];
        }
    }
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.player1TableView) {
       Player* player = [self.playersOnField objectAtIndex:[indexPath row]];
       self.playerSubstitution.fromPlayer = player;
    } else {
       Player* player = [self.playersOnBench objectAtIndex:[indexPath row]];
       self.playerSubstitution.toPlayer = player;
    }
    [self enableSaveButton];
    [self refresh];
}


#pragma mark Event Handling

-(void)doneButtonPressed {
    if (![self willGenderBeUnbalanced]) {
        [self commitChanges];
        if (self.originalPlayerSubstitution) {
            self.completion(self.originalPlayerSubstitution);
        } else {
            self.completion(self.playerSubstitution);        
        }
    }
}

- (IBAction)reasonChanged:(id)sender {

    [self enableSaveButton];
}

#pragma mark Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Substitution";
        _playerSubstitution = [[PlayerSubstitution alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stylize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPlayerOutLabel:nil];
    [self setPlayerInLabel:nil];
    [self setErrorMessageLabel:nil];
    [super viewDidUnload];
}

#pragma mark Misc

-(void)enableSaveButton {
    BOOL enable = NO;
    if (self.originalPlayerSubstitution) {
        enable = 
            ![self.playerSubstitution.fromPlayer isEqual:self.originalPlayerSubstitution.fromPlayer] ||
            ![self.playerSubstitution.toPlayer isEqual:self.originalPlayerSubstitution.toPlayer] ||
            self.playerSubstitution.reason != self.originalPlayerSubstitution.reason;
    } else {
        enable = self.playerSubstitution.fromPlayer != nil && self.playerSubstitution.toPlayer != nil;
    }
    UINavigationItem* currentNavItem = self.navigationController.navigationBar.topItem;
    if (enable) {
        if (!currentNavItem.rightBarButtonItem) {
            [currentNavItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)]animated: YES];
        }
    } else {
        [currentNavItem setRightBarButtonItem:nil];
    }
}

-(void)refresh {
    [self.player1TableView reloadData];
    [self.player2TableView reloadData];
    self.substitutionReasonSegmentedControl.selectedSegmentIndex = self.playerSubstitution.reason == SubstitutionReasonInjury ? 0 : 1;
}

-(void)stylize {
    [ColorMaster styleAsWhiteLabel:self.playerInLabel size:16];
    [ColorMaster styleAsWhiteLabel:self.playerOutLabel size:16];
    self.player1TableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.player2TableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

-(PlayerSelectionTableViewCell*)createCell {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerSelectionTableViewCell class]) owner:nil options:nil];
    PlayerSelectionTableViewCell*  cell = (PlayerSelectionTableViewCell *)[nib objectAtIndex:0];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)initPlayersOnFieldAndBench {
    NSMutableArray* bench = [[NSMutableArray alloc] initWithArray: [Team getCurrentTeam].players];
    [bench removeObjectsInArray:self.playersOnField];
    _playersOnBench = [bench sortedArrayUsingSelector:@selector(compare:)];
    _playersOnField = [self.playersOnField sortedArrayUsingSelector:@selector(compare:)];
}

-(void)commitChanges {
    self.playerSubstitution.reason = self.substitutionReasonSegmentedControl.selectedSegmentIndex == 0 ? SubstitutionReasonInjury : SubstitutionReasonOther;
    if (self.originalPlayerSubstitution) { // update mode
        self.originalPlayerSubstitution.fromPlayer = self.playerSubstitution.fromPlayer;
        self.originalPlayerSubstitution.toPlayer = self.playerSubstitution.toPlayer;
        self.originalPlayerSubstitution.reason = self.playerSubstitution.reason;
    } else {
        self.originalPlayerSubstitution = self.playerSubstitution;
        self.originalPlayerSubstitution.timestamp = [NSDate timeIntervalSinceReferenceDate];
    }
}

#pragma mark Mixed Team Gender checking

-(BOOL)willGenderBeUnbalanced {
    if ([Team getCurrentTeam].isMixed) {
        NSMutableArray* newLine = [NSMutableArray arrayWithArray:self.playersOnField];
        [newLine removeObject:self.playerSubstitution.fromPlayer];
        [newLine addObject:self.playerSubstitution.toPlayer];
        int male = 0;
        int female = 0;
        for (Player* player in newLine) {
            if (player.isMale) {
                male++;
            } else {
                female++;
            }
        }
        if (male > 4 || female > 4) {
            [SoundPlayer playMaxPlayersAlreadyOnField];
            [self showGenderImbalanceIndicator: male > 4];
            return true;
        }
    }
    return false;
}

- (void)showGenderImbalanceIndicator: (BOOL) isMaleImbalance {
    [self.errorMessageLabel setTextColor: [ColorMaster getPlayerImbalanceColor: isMaleImbalance]];
    self.errorMessageLabel.text = isMaleImbalance ? @" too many males" : @" too many females";
    self.errorMessageLabel.alpha = 1;
    self.errorMessageLabel.backgroundColor = [ColorMaster getSegmentControlDarkTintColor];
    [UIView animateWithDuration:1.5 animations:^{self.errorMessageLabel.alpha = 0;}];
}


@end
