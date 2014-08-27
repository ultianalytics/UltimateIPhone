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
@class GameHistoryController;

@interface GameViewController : UltimateViewController <ActionListener, UIAlertViewDelegate> {
    BOOL isOffense;
}


// SUBCLASS Support
@property (nonatomic, strong, readonly) UIView* actionSubView;
@property (nonatomic, strong, readonly) UIView *topOrLeftView;
@property (nonatomic, strong, readonly) UIView *bottomOrRightView;
@property (nonatomic, strong, readonly) UIView* hideReceiverView;
@property (nonatomic, strong, readonly) GameHistoryController* eventsViewController;
@property (nonatomic, strong, readonly) NSMutableArray* playerViews;


@end
