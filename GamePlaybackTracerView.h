//
//  GamePlaybackTracerView.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/13/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GamePlaybackTracerView : UIView

@property (nonatomic) CGPoint sourcePoint;
@property (nonatomic) CGPoint destinationPoint;
@property (nonatomic) CGFloat endInset;  // how far from arrow end/begin to the center of the source/destination point
@property (nonatomic) BOOL isOurEvent;

@end
