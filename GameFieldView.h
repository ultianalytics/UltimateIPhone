//
//  GameFieldView.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameFieldView : UIView

@property (nonatomic, strong) UIColor* fieldBorderColor;
@property (nonatomic) float endzonePercent; // portion of the total field occupied by a single endzone

@end
