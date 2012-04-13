//
//  CloudViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "CloudViewController.h"
#import "Preferences.h"
#import "ColorMaster.h"
#import "CloudClient.h"
#import "SignonViewController.h"
#import "TeamDownloadPickerViewController.h"
#import "Team.h"
#import "Game.h"
#import "Constants.h"

@implementation CloudViewController
@synthesize syncButton,uploadCell,userCell,websiteCell,adminSiteCell,userLabel,websiteLabel,adminSiteLabel,cloudTableView,signoffButton,downloadCell,downloadButton;

NSArray* cloudCells;
SignonViewController* signonController;
TeamDownloadPickerViewController* teamDownloadController;
UIAlertView* busyView;
void (^signonCompletion)();

-(IBAction)downloadButtonClicked: (id) sender {
    [self downloadTeams];
}

-(void)goSignonView{
    signonController = [[SignonViewController alloc] init];
    [self.navigationController pushViewController:signonController animated: YES];
}

-(void)goTeamPickerView: (NSArray*) teams {
    teamDownloadController = [[TeamDownloadPickerViewController alloc] init];
    teamDownloadController.teams = teams;
    [self.navigationController pushViewController:teamDownloadController animated: YES];
}

-(void)populateViewFromModel {
    NSString* websiteURL = [CloudClient getWebsiteURL: [Team getCurrentTeam]];
    self.websiteLabel.text = websiteURL == nil ?  @"unknown (do upload)" : websiteURL;
    self.websiteCell.accessoryType = websiteURL == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    self.websiteCell.selectionStyle = websiteURL == nil ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleNone;
    NSString* userid = [Preferences getCurrentPreferences].userid;
    self.userLabel.text = userid == nil ? @"unknown (do upload)" : userid;
    [self.syncButton setTitle:[NSString stringWithFormat:@"Upload %@",[Team getCurrentTeam].name] forState:UIControlStateNormal];
    self.signoffButton.hidden = userid == nil;
}

-(IBAction)syncButtonClicked: (id) sender {
    [self upload];
}

-(void)upload {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(doUpload) withObject:nil];
}

-(void)doUpload {
    NSError* uploadError = nil;
    [CloudClient uploadTeam:[Team getCurrentTeam] withGames:[ Game getAllGameFileNames:[Team getCurrentTeam].teamId] error: &uploadError];
    [self stopBusyDialog];
    if (uploadError) {
        if (uploadError.code == Unauthorized) {
            signonCompletion = ^{[self doUpload];};
            [self goSignonView];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: NSLocalizedString(@"Upload FAILED",nil)
                                  message: NSLocalizedString(@"We were unable to upload your data to the cloud.  Try again later.",nil)
                                  delegate: self
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        }
    } else {
        [self populateViewFromModel];
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: NSLocalizedString(@"Upload Complete",nil)
                              message: NSLocalizedString(@"Your data was successfully uploaded to the cloud",nil)
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    }
}

-(void)downloadTeams {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(doTeamsRetrieve) withObject:nil];
}

-(void)doTeamsRetrieve {
    NSError* getError = nil;
    NSArray* teams = [CloudClient getTeams:&getError];
    [self stopBusyDialog];
    if (getError) {
        if (getError.code == Unauthorized) {
            signonCompletion = ^{[self doTeamsRetrieve];};
            [self goSignonView];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: NSLocalizedString(@"Download FAILED",nil)
                                  message: NSLocalizedString(@"We were unable to download your team list from the cloud.  Try again later.",nil)
                                  delegate: self
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        }
    } else {
        [self goTeamPickerView: teams];
    }
}

-(void)downloadTeam: (NSString*) cloudId {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(doDownloadTeam:) withObject:cloudId];
}

-(void)doDownloadTeam: (NSString*) cloudId {
    NSError* getError = nil;
    [CloudClient downloadTeam: cloudId error:&getError];
    [self stopBusyDialog];
    if (getError) {
        if (getError.code == Unauthorized) {
            signonCompletion = ^{[self doDownloadTeam: cloudId];};
            [self goSignonView];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: NSLocalizedString(@"Download FAILED",nil)
                                  message: NSLocalizedString(@"We were unable to download your team from the cloud.  Try again later.",nil)
                                  delegate: self
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: NSLocalizedString(@"Download Complete",nil)
                              message: NSLocalizedString(@"The team was successfully downloaded to your iPhone.",nil)
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    }
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

-(IBAction)signoffButtonClicked: (id) sender {
    [CloudClient signOff];
    [self populateViewFromModel];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    cloudCells = [NSArray arrayWithObjects:uploadCell, downloadCell, userCell, websiteCell, adminSiteCell, nil];
    return [cloudCells count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [cloudCells objectAtIndex:[indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath { 
    if (tableView == self.cloudTableView) {
        UITableViewCell* cell = [cloudCells objectAtIndex:[indexPath row]];
        if (cell == websiteCell) {
            NSString* websiteURL = [CloudClient getWebsiteURL: [Team getCurrentTeam]];
            if (websiteURL != nil) {
                NSURL *url = [NSURL URLWithString:websiteURL];
                [[UIApplication sharedApplication] openURL:url];
            }
        } else if (cell == adminSiteCell) {
            NSString* adminUrl = adminSiteLabel.text;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adminUrl]];
        } 
    }
} 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Cloud", @"Cloud");
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
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(populateViewFromModel)
                                                 name: @"UIApplicationWillEnterForegroundNotification"
                                               object: nil];
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateViewFromModel];
    if (signonController) {
        if (signonController.isSignedOn) {
            signonCompletion();
        }
        signonController = nil;
    } else if  (teamDownloadController && teamDownloadController.selectedTeam) {
        if (teamDownloadController.selectedTeam) {
            [self downloadTeam: teamDownloadController.selectedTeam.cloudId];
        }
        teamDownloadController = nil;
    } 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
