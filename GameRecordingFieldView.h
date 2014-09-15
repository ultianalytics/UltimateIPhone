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

@property (strong, nonatomic) BOOL (^positionTappedBlock)(EventPosition* position, CGPoint gameFieldPoint, BOOL isOutOfBounds);
@property (nonatomic, strong, readonly) EventPosition* potentialEventPosition;

-(void)handleTap:(CGPoint) tapPoint isOB: (BOOL) isOutOfBounds;
-(void)updateForCurrentEvents;
-(BOOL)isPointInGoalEndzone: (CGPoint)eventPoint;
-(void)showDragCallout;

@end
