//
//  ViewController.m
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 7/26/12.
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

@end

@implementation ViewController 

@synthesize leftView,rightView,toolbarView;
@synthesize rightViewController,leftViewController,toolbarViewController;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // tab bar stuff...
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

#pragma mark - Lifecycle

- (void) viewWillLayoutSubviews {

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupChildViewController:[[MySampleLeftViewController alloc] init] inSubView:self.leftView];
    [self setupChildViewController:[[MySampleRightViewController alloc] init] inSubView:self.rightView];
    [self setupChildViewController:[[MySampleToolbarViewController alloc] init] inSubView:self.toolbarView];
}

- (void)viewDidUnload {
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark - Child View setup

-(void)setupChildViewController: (UIViewController *)childViewController inSubView: (UIView *)subView {
    /*
     put the child view controller into the subview of this view controller...     
     */
    
    // adjust the frame to fit in the container view
	childViewController.view.frame = subView.bounds;
	// make sure that it resizes on rotation automatically
	childViewController.view.autoresizingMask = subView.autoresizingMask;
	// Step 1: add the ViewController as a child to this view controller
	[self addChildViewController:childViewController];
  	// Step 2: add the child view controller's view as a child to this view controller's subview that contains that controller 
    // (calls willMoveToParentViewController for us BTW)
	[subView addSubview:childViewController.view];
	// notify the child that it has been moved in
	[childViewController didMoveToParentViewController:self];
    
}

@end
