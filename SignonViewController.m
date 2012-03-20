//
//  SignonViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignonViewController.h"
#import "ColorMaster.h"
#import "CloudClient.h"

NSArray* cells;


@implementation SignonViewController
@synthesize useridField,passwordField,useridCell,passwordCell,isSignedOn,errorMessage;

-(IBAction) signonButtonClicked: (id) sender {
    errorMessage.text = @"";
    NSString* userid = [self.useridField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([password isEqualToString:@""] || [userid isEqualToString:@""]) {
        errorMessage.text = @"Userid and Password required";
    } else {
        BOOL ok = [CloudClient signOnWithID:userid password:password];
        if (ok) {
            self.isSignedOn = YES;
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            self.passwordField.text = @"";
            errorMessage.text = @"Signon failed";
        }
    }
}

-(IBAction) cancelButtonClicked: (id) sender {
    self.isSignedOn = NO; 
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    cells = [NSArray arrayWithObjects:useridCell, passwordCell, nil];
    return [cells count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [cells objectAtIndex:[indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         self.title = NSLocalizedString(@"Cloud Signon", @"Cloud Signon");
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    self.passwordField.secureTextEntry = YES;
    errorMessage.text = @"";
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
