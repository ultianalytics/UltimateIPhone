//
//  GameUploadPickerViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 7/20/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameUploadPickerViewController.h"
#import "GameDescription.h"

@interface GameUploadPickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) NSArray* gameDescriptions;
@property (strong, nonatomic) NSMutableSet* selectedGameIds;

@end

@implementation GameUploadPickerViewController


#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initGamesList];
        [self initSelectedGamesSet];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Game Upload";
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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:STD_ROW_TYPE];
    }
    
    cell.textLabel.text = [NSString stringWithFormat: @"vs. %@", game.opponent];
    cell.detailTextLabel.text = game.tournamentName == nil? game.formattedStartDate : [NSString stringWithFormat:@"%@, %@", game.formattedStartDate, game.tournamentName];
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
    [self updateCellImage:[self.tableView cellForRowAtIndexPath:indexPath] forGame:game];
}


#pragma mark - Misc

-(void)initGamesList {
    self.gameDescriptions = [Game retrieveGameDescriptionsForCurrentTeam];
}

-(void)initSelectedGamesSet {
    self.selectedGameIds = [NSMutableSet set];
    // TODO...add games that have not been uploaded since last save
}

-(void)updateCellImage: (UITableViewCell*) cell forGame:  (GameDescription*) game {
    BOOL isSelectedGame = [self.selectedGameIds containsObject:game.gameId];
    cell.imageView.image = isSelectedGame ? [UIImage imageNamed:@"checkbox-checked"] : [UIImage imageNamed:@"checkbox-unchecked"];
    self.uploadButton.enabled = [self.selectedGameIds count] > 0;
    
}

@end
