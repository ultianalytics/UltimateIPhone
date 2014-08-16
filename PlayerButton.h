//
//  PlayerButton.h
//  Ultimate
//
//  Created by james on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IBView.h"
#import "PlayerButtonListener.h"
@class PlayerButtonActual;
@class Player;

@interface PlayerButton : UIView {
    Player* __strong _player;
    BOOL isOnField;
    id<PlayerButtonListener> __strong listener; 
}

@property (nonatomic, strong) IBOutlet UIButton* button;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* positionLabel;
@property (nonatomic, strong) IBOutlet UILabel* pointsLabel;
@property (nonatomic, strong) IBOutlet UIImageView* genderImage;

-(void)setClickListener: (id<PlayerButtonListener>) listener;
-(void)setPlayer: (Player*) player;
-(void)setPlayer: (Player*) player points: (float) points pointFactor: (float) pointFactor;
-(Player*)getPlayer;
-(void)setOnField: (BOOL) shouldBeOnField;
-(NSString*)getPlayerName;

@end


