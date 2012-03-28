//
//  SecondViewController.h
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"
#import "EventView.h"
#import "ActionListener.h"

@interface GameViewController : UIViewController <ActionListener> {
    BOOL isOffense;
}

@property (nonatomic, strong) IBOutlet UILabel* playerLabel;
@property (nonatomic, strong) IBOutlet UILabel* receiverLabel;
@property (nonatomic, strong) IBOutlet UIButton* throwAwayButton;
@property (nonatomic, strong) IBOutlet UIButton* gameOverButton;
@property (nonatomic, strong) IBOutlet UIButton* otherTeamScoreButton;
@property (nonatomic, strong) IBOutlet UIButton* removeEventButton;

@property (nonatomic, strong) NSMutableArray* playerViews;
@property (nonatomic, strong) IBOutlet PlayerView* playerView1;
@property (nonatomic, strong) IBOutlet PlayerView* playerView2;
@property (nonatomic, strong) IBOutlet PlayerView* playerView3;
@property (nonatomic, strong) IBOutlet PlayerView* playerView4;
@property (nonatomic, strong) IBOutlet PlayerView* playerView5;
@property (nonatomic, strong) IBOutlet PlayerView* playerView6;
@property (nonatomic, strong) IBOutlet PlayerView* playerView7;
@property (nonatomic, strong) IBOutlet PlayerView* playerViewTeam;

@property (nonatomic, strong) IBOutlet EventView* eventView1;
@property (nonatomic, strong) IBOutlet EventView* eventView2;
@property (nonatomic, strong) IBOutlet EventView* eventView3;

@property (nonatomic, strong) IBOutlet UIView* swipeEventsView;
@property (nonatomic, strong) IBOutlet UIView* hideReceiverView;

@property (nonatomic, strong) IBOutlet UILabel* tweetingLabel;


-(void) goToPlayersOnFieldView;
-(void) goToHistoryView: (BOOL) curl;
-(void) goToHistoryViewRight;
-(void) setOffense: (BOOL) isOffense;
-(IBAction) throwAwayButtonClicked: (id) sender;
-(IBAction) otherTeamScoreClicked: (id) sender;
-(IBAction) switchSidesClicked: (id) sender;
-(IBAction) removeEventClicked: (id) sender;
-(IBAction) gameOverButtonClicked: (id) sender;
-(PlayerView*) findPlayerView: (Player*) player;
-(PlayerView*) findSelectedPlayerView;
-(void) populatePlayers;
-(void) addEvent: (Event*) event;
-(void) updateEventViews;
-(void) initializeSelected;
-(void) refreshTitle: (Event*) event;
-(void) updateNavBarTitle;
-(void) updateViewFromGame: (Game*) game;
-(void)halftimeWarning;


@end
