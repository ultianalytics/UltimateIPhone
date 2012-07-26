//
//  ViewController.m
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MyPageViewController.h"
#import "MyTabWithButtonsViewController.h"


@interface ViewController ()


// for the container view 
@property (nonatomic, strong) MyPageViewController *pageViewController;
@property (nonatomic, strong) MyTabWithButtonsViewController *barViewController;

-(void)setupPageSubView;
-(void)setupTabSubView;

@end

@implementation ViewController 

@synthesize barView,pageView;
@synthesize pageViewController,barViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

//
//-(void)previousButtonSelected {
//    [self switchSelectedPage:NO];
//}
//
//-(void)nextButtonSelected {
//    [self switchSelectedPage:YES];    
//}
//
//-(void)switchSelectedPage: (BOOL)isForward {
//    int i = [self.pageViewControllers indexOfObject:_selectedPageViewController];
//    isForward ? i++ : i--;
//    if (i >= 0 && i < [self.pageViewControllers count]) {
//        [self setPageViewSelected:[self.pageViewControllers objectAtIndex:i] isAdvancing:isForward];
//    }
//}

-(void)setupTabSubView {
  
    /*
        put a master view controller into the bar subview...     
     */
    
    self.barViewController = [[MyTabWithButtonsViewController alloc] init];
    // adjust the frame to fit in the container view
	self.barViewController.view.frame = self.barView.bounds;
	// make sure that it resizes on rotation automatically
	self.barViewController.view.autoresizingMask = self.barView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:self.barViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[self.barView addSubview:self.barViewController.view];
	// notify the child that it has been moved in
	[self.barViewController didMoveToParentViewController:self];
    
}

-(void)setupPageSubView {
    
    /*
     put a new detail view controller into the bar subview...     
     */
    
    self.pageViewController = [[MyPageViewController alloc] init];
    // adjust the frame to fit in the container view
	self.pageViewController.view.frame = self.pageView.bounds;
	// make sure that it resizes on rotation automatically
	self.pageViewController.view.autoresizingMask = self.pageView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:self.pageViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[self.pageView addSubview:self.pageViewController.view];
	// notify the child that it has been moved in
	[self.pageViewController didMoveToParentViewController:self];
    
}

//-(void)setupPageSubViewX {
//   
//    /*
//     create the array of page view controllers that we will swipe between
//     */
//    self.pageViewControllers = [NSMutableArray array];
//    for (int i=0; i<5; i++) {
//        MyPageViewController *page = [[MyPageViewController alloc] init];
//        [self.pageViewControllers addObject:page];
//    }
//    [self setPageViewSelected: [self.pageViewControllers objectAtIndex:0] isAdvancing:NO];
//}

//-(void)setPageViewSelected: (MyPageViewController*) toPageViewController isAdvancing: (BOOL) isAdvancing {
//	if (toPageViewController.parentViewController == self) {
//		// nothing to do (already the selected page view controller)
//		return;
//	}
//    
//    // adjust the frame to fit in the container view
//	toPageViewController.view.frame = self.pageView.bounds;
//	// make sure that it resizes on rotation automatically
//	toPageViewController.view.autoresizingMask = self.pageView.autoresizingMask;
//    
//    MyPageViewController* fromPageViewController = _selectedPageViewController;
//    
//    if (fromPageViewController) {
//        // notify old controller that it is being pulled out
//        [fromPageViewController willMoveToParentViewController:nil];
//        // add the new ViewController as a child to this view controller
//        [self addChildViewController:toPageViewController];
//        // transition
//        [self transitionFromViewController:fromPageViewController toViewController:toPageViewController duration:1.0 
//                                   options: isAdvancing ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown
//                                animations:^{
//                                }
//                                completion:^(BOOL finished) {
//                                    [toPageViewController didMoveToParentViewController:self];
//                                    [fromPageViewController removeFromParentViewController];
//                                }];
//    } else {
//        // Step 1: add the ViewController as a child to this view controller
//        [self addChildViewController:toPageViewController];
//        // Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
//        // (calls willMoveToParentViewController for us BTW)
//        [self.pageView addSubview:toPageViewController.view];
//        // notify it that move is done
//        [toPageViewController didMoveToParentViewController:self];
//    }
//    _selectedPageViewController = toPageViewController; 
//}

#pragma mark
#pragma Lifecycle

- (void) viewWillLayoutSubviews {

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTabSubView];
    [self setupPageSubView];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
