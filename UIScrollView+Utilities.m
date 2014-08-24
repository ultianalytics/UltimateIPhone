//
//  UIScrollView+Utilities.m
//  UltimateIPhone
//
//  Created by james on 4/12/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "UIScrollView+Utilities.h"

@implementation UIScrollView (Utilities)


-(void)adjustInsetForTabBar {
    // adjust the bottom inset to handle being under the tab bar
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top,self.contentInset.left, IS_IPAD ? 56.f : 49.f,self.contentInset.right);
}



@end
