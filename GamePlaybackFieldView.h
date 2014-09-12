//
//  GamePlaybackFieldView.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/12/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldView.h"

@interface GamePlaybackFieldView : GameFieldView

-(void)displayNewEvent: (Event*) event complete: (void (^)()) completionBlock;
-(void)displayEvent: (Event*) event;
-(void)resetField;

@end
