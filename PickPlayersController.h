//
//  PickPlayersController.h
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerButtonListener.h"
#import "UltimateViewController.h"
@class Game;
@class PlayerButton;
@class Player;

@interface PickPlayersController : UltimateViewController <UITableViewDelegate, UITableViewDataSource, PlayerButtonListener> {
    int numberOfPlayersOnBench;
}

@property (nonatomic, strong) Game* game;
@property (nonatomic, strong) NSMutableArray* benchTableCells;
@property (nonatomic, strong) NSMutableArray* fieldButtons;
@property (nonatomic, strong) NSMutableArray* benchButtons;
@property (nonatomic, strong) NSDictionary* pointsPerPlayer;
@property (nonatomic, strong) NSDictionary* pointFactorPerPlayer;
@property (strong, nonatomic) void (^controllerClosedBlock)();
@property (nonatomic) BOOL flashGoal;

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