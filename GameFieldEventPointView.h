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
@property (nonatomic, strong) UIColor* pointColor;
@property (strong, nonatomic) void (^tappedBlock)(CGPoint tapPoint, GameFieldEventPointView* pointView);


@end
