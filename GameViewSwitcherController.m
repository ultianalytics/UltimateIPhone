//
//  GameViewSwitcherController.m
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameViewSwitcherController.h"
#import "GameViewController.h"

@implementation GameViewSwitcherController
@synthesize currentViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)switchActiveContoller: (Class) controllerClass {
    [self.currentViewController.view removeFromSuperview];
    self.currentViewController = [[controllerClass alloc] initWithNibName:[controllerClass description] bundle:nil];
    [self.view insertSubview:self.currentViewController.view atIndex:0];
}

-(void)switchActiveControllerAnimated: (Class) controllerClass transition: (UIViewAnimationTransition) transition {
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
    UIViewController* controllerLeaving = self.currentViewController;
    self.currentViewController = [[controllerClass alloc] initWithNibName:[controllerClass description] bundle:nil];
    [UIView setAnimationTransition: transition forView:self.view cache:YES];
		
    [self.currentViewController viewWillAppear:YES];
    [controllerLeaving viewWillDisappear:YES];
    
    [controllerLeaving.view removeFromSuperview];
    [self.view insertSubview:self.currentViewController.view atIndex:0];
    
    [controllerLeaving viewDidDisappear:YES];
    [self.currentViewController viewDidAppear:YES];
    
    [UIView commitAnimations];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self switchActiveContoller:[GameViewController class]];
    [super viewDidLoad];
}


- (void)viewDidUnload
{

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
