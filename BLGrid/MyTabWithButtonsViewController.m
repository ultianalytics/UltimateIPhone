//
//  MyTabWithButtonsViewController.m
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyTabWithButtonsViewController.h"

@interface MyTabWithButtonsViewController ()

@end

@implementation MyTabWithButtonsViewController
@synthesize delegate, previousButton, nextButton;


#pragma mark
#pragma Lifecycle


-(IBAction)previousButtonSelected:(id)sender {
    [delegate previousButtonSelected];
}

-(IBAction)nextButtonSelected:(id)sender {
    [delegate nextButtonSelected];    
}

#pragma mark
#pragma Inits

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark
#pragma Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidAppear:(BOOL)animated
{
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
