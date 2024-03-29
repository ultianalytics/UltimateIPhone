//
//  GameFieldView.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventPosition.h"
@class Event, GameFieldEventPointView, FieldDimensions;

#define kPointViewWidth 30.0f
#define kDiscDiameter 16.0f

@interface GameFieldView : UIView

// view configuration
@property (nonatomic, strong) UIColor* fieldBorderColor;
@property (nonatomic, strong) UIColor* endzone0BorderColor;
@property (nonatomic, strong) UIColor* endzone100BorderColor;
@property (nonatomic) float endzonePercent; // portion of the total field occupied by a single endzone
@property (nonatomic) BOOL inverted;
@property (nonatomic, strong) UIColor* discColor;
@property (nonatomic, strong) NSAttributedString* message;
@property (nonatomic, strong) FieldDimensions* fieldDimensions;

// subclass support

-(void)commonInit;
-(void)initFieldDefaults;

-(void)calculateFieldRectangles;
-(EventPosition*)calculatePosition: (CGPoint)point;
-(EventPosition*)calculatePosition: (CGPoint)point inRect: (CGRect)rect area: (EventPositionArea)area;
-(CGPoint)calculatePoint: (EventPosition*)position;
-(void)updatePointViewLocation: (GameFieldEventPointView*)pointView toPosition: (EventPosition*)eventPosition;

-(BOOL)isOurEvent:(Event*) event;


@end
