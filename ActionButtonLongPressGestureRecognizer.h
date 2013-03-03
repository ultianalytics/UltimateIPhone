//
//  ActionButtonLongPressGestureRecognizer.h
//  UltimateIPhone
//
//  Created by james on 3/3/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionButtonLongPressGestureRecognizer : UILongPressGestureRecognizer

+ (ActionButtonLongPressGestureRecognizer*)recognizerForButton: (UIButton*) button withTarget:(id)target action:(SEL)action;

@property (weak, nonatomic) UIButton* button;

@end
