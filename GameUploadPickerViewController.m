//
//  GameUploadPickerViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 7/20/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameUploadPickerViewController.h"
#import "GameDescription.h"
#import "UploadDownloadTracker.h"
#import "Team.h"
#import "GameUploadPickerTableViewCell.h"

@interface GameUploadPickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) NSArray* gameDescriptions;
@property (strong, nonatomic) NSMutableSet* selectedGameIds;

@end

@implementation GameUploadPickerViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initGamesList];
    [self initSelectedGamesSet];
    self.title = @"Games Upload";
    [self.tableView reloadData];
}

#pragma mark - Event Handling

- (IBAction)uploadButtonTapped:(id)sender {
    if (self.dismissBlock) {
        self.dismissBlock([self.selectedGameIds allObjects]);
    }
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gameDescriptions count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameDescription* game = [self.gameDescriptions objectAtIndex:[indexPath row]];
    
    GameUploadPickerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"GameCell"];
    cell.opponentLabel.text = [NSString stringWithFormat: @"vs. %@", game.opponent];
    cell.otherInfoLabel.text = game.tournamentName == nil? game.formattedStartDate : [NSString stringWithFormat:@"%@, %@", game.formattedStartDate, game.tournamentName];
    [self updateCellImage:cell forGame:game];
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    GameDescription* game = [self.gameDescriptions objectAtIndex:[indexPath row]];
    if ([self.selectedGameIds containsObject:game.gameId]) {
        [self.selectedGameIds removeObject:game.gameId];
    } else {
        [self.selectedGameIds addObject:game.gameId];
    }
    [self updateCellImage:(GameUploadPickerTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath] forGame:game];
}


#pragma mark - Misc

-(void)initGamesList {
    self.gameDescriptions = [Game retrieveGameDescriptionsForCurrentTeam];
}

-(void)initSelectedGamesSet {
    self.selectedGameIds = [NSMutableSet set];
    NSString* teamId = [Team getCurrentTeam].teamId;
    for (GameDescription* gameDescription in self.gameDescriptions) {
        NSTimeInterval lastUploadOrDownloadTime = [UploadDownloadTracker lastUploadOrDownloadForGameId:gameDescription.gameId inTeamId:teamId];
        if (gameDescription.lastSaveGMT == -1 || (gameDescription.lastSaveGMT != lastUploadOrDownloadTime)) {
            [self.selectedGameIds addObject:gameDescription.gameId];
        };
    }
}

-(void)updateCellImage: (GameUploadPickerTableViewCell*) cell forGame:  (GameDescription*) game {
    BOOL isSelectedGame = [self.selectedGameIds containsObject:game.gameId];
    cell.checkedImageView.image = isSelectedGame ? [UIImage imageNamed:@"checkbox-checked"] : [UIImage imageNamed:@"checkbox-unchecked"];
    [self updateUploadButton];
}

-(void)updateUploadButton {
    BOOL hasSelections = [self.selectedGameIds count] > 0;
    self.uploadButton.enabled = hasSelections;
    NSString* buttonText = hasSelections ? [NSString stringWithFormat:@"Upload %lu Game%@", (unsigned long)[self.selectedGameIds count], [self.selectedGameIds count] == 1 ? @"" : @"s"]: @"No Games Selected";
    [self.uploadButton setTitle:buttonText forState:UIControlStateNormal];
}

@end
