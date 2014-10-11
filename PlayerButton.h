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
    BOOL isOnField;
}

@property (nonatomic, weak) id<PlayerButtonListener> clickListener;
@property (nonatomic, strong) Player* player;

-(void)setPlayer: (Player*) player;
-(void)setPlayer: (Player*) player points: (float) points pointFactor: (float) pointFactor;
-(void)setOnField: (BOOL) shouldBeOnField;
-(NSString*)getPlayerName;

@end


