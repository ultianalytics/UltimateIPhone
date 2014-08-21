//
//  PlayerDetailsViewController.h
//  Ultimate
//
//  Created by james on 1/21/12.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@class Player;
@class UltimateSegmentedControl;

@interface PlayerDetailsViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    NSArray* cells;
}

@property (nonatomic, strong) Player* player;
@property (strong, nonatomic) void (^playerChangedBlock)(Player* player);
@property (nonatomic) BOOL isModalAddMode;

-(IBAction)addAnotherClicked: (id) sender;
-(IBAction)deleteClicked: (id) sender;
-(void)okClicked;
-(void)cancelClicked;
-(void)returnToTeamView;
-(void)populateViewFromModel;
-(void)populateModelFromView;
-(void)addPlayer;
-(void)updatePlayer;
-(void)deletePlayer;
-(NSString*) getNickNameViewText;
-(NSString*) getNumberViewText;
-(BOOL)verifyPlayer;
-(BOOL)isDuplicatePlayerName: (NSString*) newPlayerName;
-(BOOL)isDuplicatePlayerNumber: (NSString*) newPlayerNumber;

@end
