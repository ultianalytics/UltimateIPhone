//
//  PickPlayersController.h
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerButtonListener.h"
@class Game;
@class PlayerButton;
@class Player;

@interface PickPlayersController : UIViewController <UITableViewDelegate, UITableViewDataSource, PlayerButtonListener> {
    int numberOfPlayersOnBench;
}

@property (nonatomic, strong) Game* game;

@property (nonatomic, strong) IBOutlet UITableView* benchTableView;
@property (strong, nonatomic) IBOutlet UIView *substitutionsView;
@property (strong, nonatomic) IBOutlet UIButton *undoSubstitutionButton;
@property (strong, nonatomic) IBOutlet UITableView *substitutionTableView;
@property (nonatomic, strong) NSMutableArray* benchTableCells;
@property (nonatomic, strong) IBOutlet UIView* fieldView;
@property (nonatomic, strong) IBOutlet UIButton* lastLineButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *substitutionButton;
@property (nonatomic, strong) IBOutlet UILabel* errorMessageLabel;
@property (nonatomic, strong) NSMutableArray* fieldButtons;
@property (nonatomic, strong) NSMutableArray* benchButtons;
@property (nonatomic, strong) NSDictionary* pointsPerPlayer;
@property (nonatomic, strong) NSDictionary* pointFactorPerPlayer;

+(void)halftimeWarning;

- (NSMutableArray*) initializePlayersViewCount: (int)numberOfButtons players: (NSArray*) players isField: (BOOL)isField;
- (void) clearFieldView;
- (IBAction) lastLineClicked:(id)button;
- (IBAction) clearClicked:(id)button;
- (void) populateLineType;
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
- (IBAction) halftimeButtonClicked:(id)sender;
- (void) populateUI;


- (void) dumpBenchView; // debug help
@end