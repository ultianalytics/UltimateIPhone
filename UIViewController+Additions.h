//
//  UIViewController+Additions.h
//  UltimateIPhone
//
//  Created by james on 3/3/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Additions)

-(void)addChildViewController: (UIViewController *)childViewController inSubView: (UIView *)subView;
// given a UIKeyboardWillShowNotification answer the orgin of the keyboard in the coordinates of the receiver's view
- (CGFloat)calcKeyboardOrigin:(NSNotification *)uiKeyboardWillShowNotification;

@end
