//
//  UIViewController+Additions.m
//  UltimateIPhone
//
//  Created by james on 3/3/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

/*
 Add the view controller as a child view controller of the receiver.  The child VC's view will be
 put into (fill) the VC's subView param.  This approach allows for the VC to create "widget" subviews that are
 populated by other VCs.
 
 NOTE:  Don't forget to set the subview's autoresizingMask (springs and struts) via XIB or programmtically
 because the child VC view adopts it.
 */
-(void)addChildViewController: (UIViewController *)childViewController inSubView: (UIView *)subView {
    NSAssert(childViewController!=nil,@"Attempt to add nil child view controller");
    NSAssert(subView!=nil,@"Attempt to add child view controller into nil subview");
	
    // adjust the child view's frame to fit in the container subview
	childViewController.view.frame = subView.bounds;
	
	// make sure that it resizes on rotation automatically
    // NOTE: this uses the parent's subview to set springs & struts such that the child view will fill it completely.
	// If you want to control the layout of the child controller you should do it by adjusting the layout of the receiver's subview
	childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:childViewController];
	
  	// Step 2: add the child view controller's view as a child to this view controller's subview that contains that controller
    // (calls willMoveToParentViewController for us BTW)
	[subView addSubview:childViewController.view];
	
	// notify the child that it has been moved in
	[childViewController didMoveToParentViewController:self];
    
}

@end