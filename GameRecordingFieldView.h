//
//  GameRecordingFieldView.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventPosition.h"
#import "GameFieldView.h"

@class Event;

@interface GameRecordingFieldView : GameFieldView

// view configuration
@property (nonatomic, strong) UIColor* fieldBorderColor;
@property (nonatomic) float endzonePercent; // portion of the total field occupied by a single endzone
@property (nonatomic) BOOL inverted;
@property (nonatomic, strong) NSAttributedString* message;

@property (strong, nonatomic) BOOL (^positionTappedBlock)(EventPosition* position, CGPoint gameFieldPoint, BOOL isOutOfBounds);
@property (nonatomic, strong, readonly) EventPosition* potentialEventPosition;

-(void)handleTap:(CGPoint) tapPoint isOB: (BOOL) isOutOfBounds;
-(void)updateForCurrentEvents;
-(BOOL)isPointInGoalEndzone: (CGPoint)eventPoint;
-(void)showDragCallout;

@end
