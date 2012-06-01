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
#import "Reachability.h"
#import "SignonCredentials.h"

@interface SignonViewController()

-(void)startSignon;
-(void)startBusyDialog;
-(void)stopBusyDialog;
-(SignonCredentials*)getCredentials;

@end

@implementation SignonViewController
@synthesize delegate,instructionsLabel,useridField,passwordField,useridCell,passwordCell,errorMessage;

-(IBAction) signonButtonClicked: (id) sender {
    errorMessage.text = @"";
    NSString* userid = [self.useridField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([password isEqualToString:@""] || [userid isEqualToString:@""]) {
        errorMessage.text = @"Userid and Password required";
    } else {
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"No Internet Access"
                                  message: @"We are not able to connect to cloud.  Please make sure you have Internet access."
                                  delegate: nil
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        } else {
            [self startSignon];
        }
    }
}

-(void)startSignon {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(signon:) withObject:[self getCredentials]];
}

-(void)signon: (SignonCredentials*) credentials {
    BOOL ok = [CloudClient signOnWithID:credentials.userid password:credentials.password];
    [self performSelectorOnMainThread:@selector(handleSignonCompletion:) withObject: [NSNumber numberWithBool: ok]waitUntilDone:NO];
}

-(void)handleSignonCompletion: (NSNumber*) isOk {
    [self stopBusyDialog];
    BOOL ok = [isOk boolValue];
    if (ok) {
        [self.delegate dismissSignonController:YES];
    } else {
        self.passwordField.text = @"";
        errorMessage.text = @"Signon failed";
    }
}

-(IBAction) cancelButtonClicked: (id) sender {
    [self.delegate dismissSignonController:NO];
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

-(void)startBusyDialog {
    busyView = [[UIAlertView alloc] initWithTitle: @"Talking to cloud..."
                                          message: nil
                                         delegate: self
                                cancelButtonTitle: nil
                                otherButtonTitles: nil];
    // Add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(50,50, 200, 50);
    [busyView addSubview:spinner];
    [spinner startAnimating];
    
    [busyView show];
}

-(void)stopBusyDialog {
    if (busyView) {
        [busyView dismissWithClickedButtonIndex:0 animated:NO];
        [busyView removeFromSuperview];
    }
}

-(SignonCredentials*)getCredentials {
    SignonCredentials *credentials = [[SignonCredentials alloc] init];
    credentials.userid = [self.useridField.text trim];
    credentials.password = [self.passwordField.text trim];
    return credentials;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    self.title = NSLocalizedString(@"Cloud Signon", @"Cloud Signon"); 
    self.instructionsLabel.text = [NSString stringWithFormat:@"Please sign on on to the %@ cloud using your Google Account.", kProductName];
    self.passwordField.secureTextEntry = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    errorMessage.text = @"";
}


- (void)viewDidUnload
{
    [self setInstructionsLabel:nil];
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
