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
#import "GameDownloadPickerViewController.h"
#import "Team.h"
#import "Game.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "RequestContext.h"

@implementation CloudViewController
@synthesize uploadButton,uploadCell,userCell,websiteCell,adminSiteCell,userLabel,websiteLabel,adminSiteLabel,cloudTableView,signoffButton,downloadTeamCell,downloadGameCell, downloadTeamButton, downloadGameButton;

-(IBAction)downloadTeamButtonClicked: (id) sender {
    [self startTeamsDownload];
}

-(IBAction)downloadGameButtonClicked: (id) sender {
    [self startGamesDownload];
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

-(void)goGamePickerView: (NSArray*) games {
    gameDownloadController = [[GameDownloadPickerViewController alloc] init];
    gameDownloadController.games = games;
    [self.navigationController pushViewController:gameDownloadController animated: YES];
}

-(void)populateViewFromModel {
    NSString* websiteURL = [CloudClient getWebsiteURL: [Team getCurrentTeam]];
    self.websiteLabel.text = websiteURL == nil ?  @"unknown (do upload)" : websiteURL;
    self.websiteCell.accessoryType = websiteURL == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    self.websiteCell.selectionStyle = websiteURL == nil ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleNone;
    NSString* userid = [Preferences getCurrentPreferences].userid;
    self.userLabel.text = userid == nil ? @"unknown (do upload)" : userid;
    [self.uploadButton setTitle:[NSString stringWithFormat:@"Upload %@",[Team getCurrentTeam].name] forState:UIControlStateNormal];
    [self.downloadGameButton setTitle:[NSString stringWithFormat:@"Download a %@ Game",[Team getCurrentTeam].name] forState:UIControlStateNormal];    
    self.signoffButton.hidden = userid == nil;
    [self.cloudTableView reloadData];
}

-(IBAction)uploadButtonClicked: (id) sender {
    [self startUpload];
}

-(void)startUpload {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(uploadToServer) withObject:nil];
}

-(void)uploadToServer {
    NSError* uploadError = nil;
    [CloudClient uploadTeam:[Team getCurrentTeam] withGames:[ Game getAllGameFileNames:[Team getCurrentTeam].teamId] error: &uploadError];
    [self performSelectorOnMainThread:@selector(handleUploadCompletion:) withObject: uploadError ? [NSNumber numberWithInt: uploadError.code] : nil waitUntilDone:NO];
}

-(void)handleUploadCompletion: (NSNumber*) errorCode {
    [self stopBusyDialog];
    if (errorCode && [errorCode intValue] == Unauthorized) {
        __weak CloudViewController* slf = self;
        signonCompletion = ^{[slf uploadToServer];};
        [self goSignonView];
    } else if (errorCode) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: NSLocalizedString(@"Upload FAILED",nil)
                              message: NSLocalizedString(@"We were unable to upload your data to the cloud.  Try again later.",nil)
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
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

-(void)startTeamsDownload {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(downloadTeamsFromServer) withObject:nil];
}

-(void)downloadTeamsFromServer {
    NSError* getError = nil;
    NSArray* teams = [CloudClient getTeams:&getError];
    RequestContext* reqContext = getError ? 
        [[RequestContext alloc] initWithRequestData:nil responseData:nil error: getError.code] :
        [[RequestContext alloc] initWithRequestData:nil responseData:teams];
    [self performSelectorOnMainThread:@selector(handleTeamsDownloadCompletion:) 
                           withObject:reqContext waitUntilDone:YES];
}

-(void)handleTeamsDownloadCompletion: (RequestContext*) requestContext {
    [self stopBusyDialog];
    if ([requestContext hasError]) {
        if ([requestContext getErrorCode] == Unauthorized) {
            __weak CloudViewController* slf = self;
            signonCompletion = ^{[slf downloadTeamsFromServer];};
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
        NSArray* teams = (NSArray*)requestContext.responseData;
        [self goTeamPickerView: teams];
    } 
}

-(void)startGamesDownload {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(downloadGamesFromServer) withObject:nil];
}

-(void)downloadGamesFromServer {
    NSError* getError = nil;
    NSString* cloudId = [Team getCurrentTeam].cloudId;
    NSArray* games = [CloudClient getGameDescriptions:cloudId error:&getError];
    RequestContext* reqContext = getError ? 
    [[RequestContext alloc] initWithRequestData:nil responseData:nil error: getError.code] :
    [[RequestContext alloc] initWithRequestData:nil responseData:games];
    [self performSelectorOnMainThread:@selector(handleGamesDownloadCompletion:) 
                           withObject:reqContext waitUntilDone:YES];
}

-(void)handleGamesDownloadCompletion: (RequestContext*) requestContext {
    [self stopBusyDialog];
    if ([requestContext hasError]) {
        if ([requestContext getErrorCode] == Unauthorized) {
            __weak CloudViewController* slf = self;          
            signonCompletion = ^{[slf downloadGamesFromServer];};
            [self goSignonView];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: NSLocalizedString(@"Download FAILED",nil)
                                  message: NSLocalizedString(@"We were unable to download your games list from the cloud.  Try again later.",nil)
                                  delegate: self
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        }
    } else {
        NSArray* games = (NSArray*)requestContext.responseData;
        [self goGamePickerView: games];
    } 
}

-(void)startGameDownload:(NSString*) gameId {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(downloadGameFromServer:) withObject:gameId];
}

-(void)downloadGameFromServer: (NSString*) gameId {
    NSError* getError = nil;
    [CloudClient downloadGame:gameId forTeam: [Team getCurrentTeam].cloudId error:&getError];
    RequestContext* reqContext = getError ? 
    [[RequestContext alloc] initWithRequestData:gameId responseData:nil error: getError.code] :
    [[RequestContext alloc] initWithRequestData:gameId responseData:nil];
    [self performSelectorOnMainThread:@selector(handleGameDownloadCompletion:) withObject:reqContext waitUntilDone:YES];
}

-(void)handleGameDownloadCompletion: (RequestContext*) requestContext {
    [self stopBusyDialog];
    if ([requestContext hasError]) {
        if ([requestContext getErrorCode] == Unauthorized) {
            NSString* gameId = (NSString*)requestContext.requestData;
            __weak CloudViewController* slf = self;
            signonCompletion = ^{[slf startGameDownload: gameId];};
            [self goSignonView];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: NSLocalizedString(@"Download FAILED",nil)
                                  message: NSLocalizedString(@"We were unable to download your game from the cloud.  Try again later.",nil)
                                  delegate: self
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        }
    } else {
        NSString* gameId = (NSString*)requestContext.requestData;
        if ([Game isCurrentGame:gameId]) {
            [Game setCurrentGame:gameId];
        }
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: NSLocalizedString(@"Download Complete",nil)
                              message: NSLocalizedString(@"The game was successfully downloaded to your iPhone.",nil)
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    }
}

-(void)startTeamDownload: (NSString*) cloudId {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(downloadTeamFromServer:) withObject:cloudId];
}

-(void)downloadTeamFromServer: (NSString*) cloudId {
    NSError* getError = nil;
    NSString* teamId = [CloudClient downloadTeam: cloudId error:&getError];
    RequestContext* reqContext = getError ? 
                   [[RequestContext alloc] initWithRequestData:cloudId responseData:nil error: getError.code] :
                   [[RequestContext alloc] initWithRequestData:cloudId responseData:teamId];
    [self performSelectorOnMainThread:@selector(handleTeamDownloadCompletion:) withObject:reqContext waitUntilDone:YES];
}

-(void)handleTeamDownloadCompletion: (RequestContext*) requestContext {
    [self stopBusyDialog];
    if ([requestContext hasError]) {
        if ([requestContext getErrorCode] == Unauthorized) {
            NSString* cloudId = (NSString*)requestContext.requestData;
            __weak CloudViewController* slf = self;
            signonCompletion = ^{[slf startTeamDownload: cloudId];};
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
        NSString* teamId = (NSString*)requestContext.responseData;
        if (![Team isCurrentTeam:teamId]) {
            [Team setCurrentTeam:teamId];
            [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
        }
        [self populateViewFromModel];
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
    cloudCells = [Team getCurrentTeam].cloudId == nil ? 
    [NSArray arrayWithObjects:uploadCell, downloadTeamCell, userCell, websiteCell, adminSiteCell, nil] :
    [NSArray arrayWithObjects:uploadCell, downloadTeamCell, downloadGameCell, userCell, websiteCell, adminSiteCell, nil];
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
            [self startTeamDownload: teamDownloadController.selectedTeam.cloudId];
        }
        teamDownloadController = nil;
    } else if  (gameDownloadController && gameDownloadController.selectedGame) {
        if (gameDownloadController.selectedGame) {
            [self startGameDownload: gameDownloadController.selectedGame.gameId];
        }
        gameDownloadController = nil;
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
