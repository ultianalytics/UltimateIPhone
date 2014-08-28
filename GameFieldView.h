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

// view configuration
@property (nonatomic, strong) UIColor* fieldBorderColor;
@property (nonatomic) float endzonePercent; // portion of the total field occupied by a single endzone
@property (nonatomic) BOOL inverted;
@property (nonatomic, strong) NSString* message;

@property (strong, nonatomic) BOOL (^positionTappedBlock)(EventPosition* position, CGPoint gameFieldPoint);
@property (nonatomic, strong, readonly) EventPosition* potentialEventPosition;

-(void)handleTap:(CGPoint) tapPoint;
-(void)updateForCurrentEvents;

@end
