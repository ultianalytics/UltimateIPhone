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

-(void)setupPageSubView;
-(void)setupTabSubView;
-(void)setPageViewSelected: (MyPageViewController*) toPageViewController isAdvancing: (BOOL) isAdvancing;
-(void)switchSelectedPage: (BOOL)isForward;

@end

@implementation ViewController 

@synthesize barView,pageView;

-(void)previousButtonSelected {
    [self switchSelectedPage:NO];
}

-(void)nextButtonSelected {
    [self switchSelectedPage:YES];    
}

-(void)switchSelectedPage: (BOOL)isForward {
    int i = [_pageViewControllers indexOfObject:_selectedPageViewController];
    isForward ? i++ : i--;
    if (i >= 0 && i < [_pageViewControllers count]) {
        [self setPageViewSelected:[_pageViewControllers objectAtIndex:i] isAdvancing:isForward];
    }
}

-(void)setupTabSubView {
  
    /*
        put a new tab bar view controller into the bar subview...     
     */
    
    _barViewController = [[MyTabWithButtonsViewController alloc] init];
    _barViewController.delegate = self;
    // adjust the frame to fit in the container view
	_barViewController.view.frame = self.barView.bounds;
	// make sure that it resizes on rotation automatically
	_barViewController.view.autoresizingMask = self.barView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:_barViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[self.barView addSubview:_barViewController.view];
	// notify the child that it has been moved in
	[_barViewController didMoveToParentViewController:self];
    
}

-(void)setupPageSubView {
   
    /*
     create the array of page view controllers that we will swipe between
     */
    _pageViewControllers = [NSMutableArray array];
    for (int i=0; i<5; i++) {
        MyPageViewController *page = [[MyPageViewController alloc] init];
        page.name = [NSString stringWithFormat:@"Page %d", i + 1];
        [_pageViewControllers addObject:page];
    }
    [self setPageViewSelected: [_pageViewControllers objectAtIndex:0] isAdvancing:NO];
}

-(void)setPageViewSelected: (MyPageViewController*) toPageViewController isAdvancing: (BOOL) isAdvancing {
	if (toPageViewController.parentViewController == self) {
		// nothing to do (already the selected page view controller)
		return;
	}
    
    // adjust the frame to fit in the container view
	toPageViewController.view.frame = self.pageView.bounds;
	// make sure that it resizes on rotation automatically
	toPageViewController.view.autoresizingMask = self.pageView.autoresizingMask;
    
    MyPageViewController* fromPageViewController = _selectedPageViewController;
    
    if (fromPageViewController) {
        // notify old controller that it is being pulled out
        [fromPageViewController willMoveToParentViewController:nil];
        // add the new ViewController as a child to this view controller
        [self addChildViewController:toPageViewController];
        // transition
        [self transitionFromViewController:fromPageViewController toViewController:toPageViewController duration:1.0 
                                   options: isAdvancing ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown
                                animations:^{
                                }
                                completion:^(BOOL finished) {
                                    [toPageViewController didMoveToParentViewController:self];
                                    [fromPageViewController removeFromParentViewController];
                                }];
    } else {
        // Step 1: add the ViewController as a child to this view controller
        [self addChildViewController:toPageViewController];
        // Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
        // (calls willMoveToParentViewController for us BTW)
        [self.pageView addSubview:toPageViewController.view];
        // notify it that move is done
        [toPageViewController didMoveToParentViewController:self];
    }
    _selectedPageViewController = toPageViewController; 
}

#pragma mark
#pragma Lifecycle

- (void) viewWillLayoutSubviews {
    //LOG_RECT(@"topview frame", self.view.frame);
    //LOG_RECT(@"pageView bound", self.pageView.bounds);
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
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
