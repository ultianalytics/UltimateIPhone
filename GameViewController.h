//
//  SecondViewController.h
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionListener.h"
#import "UltimateViewController.h"

@class EventView;
@class PlayerView;
@class Game;

@interface GameViewController : UltimateViewController <ActionListener, UIAlertViewDelegate> {
    BOOL isOffense;
}

@end
