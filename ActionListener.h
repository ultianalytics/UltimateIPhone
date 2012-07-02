//
//  ActionListener.h
//  Ultimate
//
//  Created by james on 1/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
@class Player;
@class PlayerView;
@protocol ActionListener <NSObject>

- (void) action: (Action) action targetPlayer: (Player*) player fromView: (PlayerView*) view;
- (void) passerSelected: (Player*) player view: (PlayerView*) view; 

@end
