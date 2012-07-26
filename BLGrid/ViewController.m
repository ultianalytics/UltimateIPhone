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
#import "MySampleToolbarViewController.h"


@interface ViewController ()


// for the container view 
@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *toolbarViewController;

-(void)setupRightViewController;
-(void)setupLeftViewController;

@end

@implementation ViewController 

@synthesize leftView,rightView,toolbarView;
@synthesize rightViewController,leftViewController,toolbarViewController;


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
        put the left view controller into the left subview...     
     */
    
    self.leftViewController = [[MySampleLeftViewController alloc] init];
    // adjust the frame to fit in the container view
	self.leftViewController.view.frame = self.leftView.bounds;
	// make sure that it resizes on rotation automatically
	self.leftViewController.view.autoresizingMask = self.leftView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:self.leftViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[self.leftView addSubview:self.leftViewController.view];
	// notify the child that it has been moved in
	[self.leftViewController didMoveToParentViewController:self];
    
}

-(void)setupRightViewController {
    
    /*
        put the right view controller into the right subview...     
     */
    
    self.rightViewController = [[MySampleRightViewController alloc] init];
    // adjust the frame to fit in the container view
	self.rightViewController.view.frame = self.rightView.bounds;
	// make sure that it resizes on rotation automatically
	self.rightViewController.view.autoresizingMask = self.rightView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:self.rightViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[self.rightView addSubview:self.rightViewController.view];
	// notify the child that it has been moved in
	[self.rightViewController didMoveToParentViewController:self];
    
}

-(void)setupToolbarViewController {
    
    /*
        put the toolbar view controller into the toolbar subview...     
     */
    
    self.toolbarViewController = [[MySampleToolbarViewController alloc] init];
    // adjust the frame to fit in the container view
	self.toolbarViewController.view.frame = self.toolbarView.bounds;
	// make sure that it resizes on rotation automatically
	self.toolbarViewController.view.autoresizingMask = self.rightView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:self.toolbarViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's view that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[self.toolbarView addSubview:self.toolbarViewController.view];
	// notify the child that it has been moved in
	[self.toolbarViewController didMoveToParentViewController:self];
    
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
    [self setupToolbarViewController];
}

- (void)viewDidUnload {
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
