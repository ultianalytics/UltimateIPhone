//
//  ViewController.h
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTabWithButtonsViewController.h"
@class MyPageViewController;
@class MyTabWithButtonsViewController;

@interface ViewController : UIViewController {

    // for the container view 
    NSMutableArray *_pageViewControllers;
    MyPageViewController *_selectedPageViewController;
    MyTabWithButtonsViewController *_barViewController;
}

// 2 view panes on window
@property (nonatomic, strong) IBOutlet UIView *pageView;
@property (nonatomic, strong) IBOutlet UIView *barView;

@end
