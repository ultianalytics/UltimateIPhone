//
//  ViewController.m
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MySampleLeftViewController.h"
#import "MySampleRightViewController.h"


@interface ViewController ()


// for the container view 
@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, strong) UIViewController *leftViewController;

-(void)setupRightViewController;
-(void)setupLeftViewController;

@end

@implementation ViewController 

@synthesize barView,pageView;
@synthesize rightViewController,leftViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

-(void)setupLeftViewController {
  
    /*
        put a master view controller into the bar subview...     
     */
    
    self.leftViewController = [[MySampleLeftViewController alloc] init];
    // adjust the frame to fit in the container view
	self.leftViewController.view.frame = self.barView.bounds;
	// make sure that it resizes on rotation automatically
	self.leftViewController.view.autoresizingMask = self.barView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:self.leftViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[self.barView addSubview:self.leftViewController.view];
	// notify the child that it has been moved in
	[self.leftViewController didMoveToParentViewController:self];
    
}

-(void)setupRightViewController {
    
    /*
     put a new detail view controller into the bar subview...     
     */
    
    self.rightViewController = [[MySampleRightViewController alloc] init];
    // adjust the frame to fit in the container view
	self.rightViewController.view.frame = self.pageView.bounds;
	// make sure that it resizes on rotation automatically
	self.rightViewController.view.autoresizingMask = self.pageView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:self.rightViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[self.pageView addSubview:self.rightViewController.view];
	// notify the child that it has been moved in
	[self.rightViewController didMoveToParentViewController:self];
    
}

#pragma mark
#pragma Lifecycle

- (void) viewWillLayoutSubviews {

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftViewController];
    [self setupRightViewController];

}

- (void)viewDidUnload {
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
