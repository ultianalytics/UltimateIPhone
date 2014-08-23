//
//  GameFieldView.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventPosition.h"
@class Event;

@interface GameFieldView : UIView

@property (nonatomic, strong) UIColor* fieldBorderColor;
@property (nonatomic) float endzonePercent; // portion of the total field occupied by a single endzone
@property (nonatomic, strong) Event* lastSavedEvent;
@property (nonatomic, strong) Event* previousSavedEvent;
@property (nonatomic) BOOL inverted;

- (void)handleTap:(CGPoint) tapPoint;

@end
