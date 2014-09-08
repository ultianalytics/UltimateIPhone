//
//  GameFieldEventPointView.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/23/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface GameFieldEventPointView : UIView

@property (nonatomic, strong) Event* event;
@property (nonatomic) BOOL isOurEvent;
@property (nonatomic) BOOL isEmphasizedEvent;
@property (nonatomic) BOOL isDiscHidden;
@property (nonatomic) CGFloat discDiameter;
@property (nonatomic) UIColor* discColor;
@property (strong, nonatomic) void (^tappedBlock)(CGPoint tapPoint, GameFieldEventPointView* pointView);

- (void)flashOutOfBoundsMessage;
- (BOOL)isBelowMidField;
- (BOOL)isRightOfMidField;

@end
