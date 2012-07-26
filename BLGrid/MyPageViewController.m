//
//  MyPageViewController.m
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyPageViewController.h"

@interface MyPageViewController ()

@end

@implementation MyPageViewController
@synthesize nameLabel;
@synthesize doitButton;
@synthesize name;
@synthesize popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nameLabel.text = name;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setDoitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)popupPressed:(id)sender {
    UIViewController *popupContentViewController =  [[UIViewController alloc] initWithNibName:@"PopupMessage" bundle:[NSBundle mainBundle]]; 
    popupContentViewController.contentSizeForViewInPopover = popupContentViewController.view.frame.size;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popupContentViewController]; 
    CGRect popoverRect = [self.doitButton frame];
    
    [self.popover presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}
@end
