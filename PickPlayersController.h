//
//  PickPlayersController.h
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerButtonListener.h"
#import "Player.h"
#import "PlayerButton.h"


@interface PickPlayersController : UIViewController <UITableViewDelegate, UITableViewDataSource, PlayerButtonListener> {
    int numberOfPlayersOnBench;
}

@property (nonatomic, strong) IBOutlet UITableView* benchTableView;
@property (nonatomic, strong) NSMutableArray* benchTableCells;
@property (nonatomic, strong) IBOutlet UIView* fieldView;
@property (nonatomic, strong) IBOutlet UIButton* lastLineButton;
@property (nonatomic, strong) IBOutlet UILabel* errorMessageLabel;
@property (nonatomic, strong) NSMutableArray* fieldButtons;
@property (nonatomic, strong) NSMutableArray* benchButtons;
@property (nonatomic, strong) NSDictionary* pointsPerPlayer;
@property (nonatomic, strong) NSDictionary* pointFactorPerPlayer;

- (NSMutableArray*) initializePlayersViewCount: (int)numberOfButtons players: (NSArray*) players isField: (BOOL)isField;
- (void) clearFieldView;
- (IBAction)lastLineClicked:(id)button;
- (IBAction)clearClicked:(id)button;
- (void) intializeForLineType;
- (void) benchPlayerClicked:(id)playerButton;
- (void) fieldPlayerClicked:(id)playerButton;
- (void) updateBenchView;
- (PlayerButton*) findBenchButton: (Player*) player;
- (void) loadPlayerButtons;
- (void) loadPlayerStats;
- (BOOL) shouldDisplayOline;
- (void) setPlayer: (Player*) player inButton: (PlayerButton*) button;
- (NSArray*) getCurrentTeamPlayers;
- (void) updateGameCurrentLineFromView;
- (BOOL) willGenderBeUnbalanced: (Player*) newPlayer;
- (void) showGenderImbalanceIndicator: (BOOL) isMaleImbalance;


- (void) dumpBenchView; // debug help
@end