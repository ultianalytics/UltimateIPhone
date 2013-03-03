//
//  ActionButtonLongPressGestureRecognizer.m
//  UltimateIPhone
//
//  Created by james on 3/3/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "ActionButtonLongPressGestureRecognizer.h"

@implementation ActionButtonLongPressGestureRecognizer

+ (ActionButtonLongPressGestureRecognizer*)recognizerForButton: (UIButton*) button withTarget:(id)target action:(SEL)action {
    ActionButtonLongPressGestureRecognizer* recognizer = [[ActionButtonLongPressGestureRecognizer alloc] initWithTarget:target action:action];
    recognizer.button = button;
    return recognizer;
}
                                                          
@end
