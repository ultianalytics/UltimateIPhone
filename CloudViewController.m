//
//  CloudViewController.m
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//
#import "CloudViewController.h"
#import "Preferences.h"
#import "ColorMaster.h"
#import "CloudClient.h"
#import "SignonViewController.h"
#import "WebViewSignonController.h"
#import "TeamDownloadPickerViewController.h"
#import "GameDownloadPickerViewController.h"
#import "Team.h"
#import "Game.h"

#import "AppDelegate.h"
#import "RequestContext.h"

#define kNoInternetMessage @"We were unable to access the internet."
#define kButtonFont [UIFont boldSystemFontOfSize: 15]

@interface CloudViewController() 

-(void)populateViewFromModel;

-(void)goSignonView;
-(void)goTeamPickerView: (NSArray*) teams;
-(void)goGamePickerView: (NSArray*) games;

-(void)startUpload;
-(void)startTeamsDownload;
-(void)startTeamDownload:(NSString*) cloudId;
-(void)startGamesDownload;
-(void)startGameDownload:(NSString*) gameId;

-(void)startBusyDialog;
-(void)stopBusyDialog;

-(void)showCompleteAlert: (NSString*) title message: (NSString*) message;

-(void)styleButtons;

@end

@implementation CloudViewController
@synthesize userUnknownLabel;
@synthesize uploadButton,uploadCell,userCell,websiteCell,adminSiteCell,userLabel,websiteLabel,adminSiteLabel,cloudTableView,signoffButton,downloadTeamCell,downloadGameCell, downloadTeamButton, downloadGameButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - Event handling

-(IBAction)downloadTeamButtonClicked: (id) sender {
    [self startTeamsDownload];
}

-(IBAction)downloadGameButtonClicked: (id) sender {
    [self startGamesDownload];
}

-(IBAction)uploadButtonClicked: (id) sender {
    [self startUpload];
}

#pragma mark - Navigation

-(void)goSignonView{
    WebViewSignonController *signonController = [[WebViewSignonController alloc] init];
    signonController.delegate = self;
    [self presentViewController:signonController animated:YES completion:nil];
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

#pragma mark - Upload Team/Games

-(void)startUpload {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(uploadToServer) withObject:nil];
}

-(void)uploadToServer {
    NSError* uploadError = nil;
    [CloudClient uploadTeam:[Team getCurrentTeam] withGames:[ Game getAllGameFileNames:[Team getCurrentTeam].teamId] error: &uploadError];
    [self performSelectorOnMainThread:@selector(handleUploadCompletion:) withObject: uploadError waitUntilDone:NO];
}

-(void)handleUploadCompletion: (NSError*) error {
    [self stopBusyDialog];
    if (error && error.code == Unauthorized) {
        __weak CloudViewController* slf = self;
        signonCompletion = ^{[slf startUpload];};
        [self goSignonView];
    } else if (error && error.code == UnacceptableAppVersion) {
        [self showCompleteAlert:NSLocalizedString(@"Upload FAILED",nil) message: [error.userInfo objectForKey:kCloudErrorExplanationKey]]; 
    } else if (error) {
        [self showCompleteAlert:NSLocalizedString(@"Upload FAILED",nil) message: NSLocalizedString(error.code == NotConnectedToInternet ? kNoInternetMessage : @"We were unable to upload your data to the cloud.  Try again later.", nil)];
    } else {
        [self populateViewFromModel];
        [self showCompleteAlert:NSLocalizedString(@"Upload Complete",nil) message: NSLocalizedString(@"Your data was successfully uploaded to the cloud",nil)];
    }
}

#pragma mark - Download Team descriptions (for picking one to download)

-(void)startTeamsDownload {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(downloadTeamsFromServer) withObject:nil];
}

-(void)downloadTeamsFromServer {
    NSError* requestError = nil;
    NSArray* teams = [CloudClient getTeams:&requestError];
    RequestContext* reqContext = requestError ? 
        [[RequestContext alloc] initWithReqData:nil responseData:nil error: requestError] :
        [[RequestContext alloc] initWithReqData:nil responseData:teams];
    [self performSelectorOnMainThread:@selector(handleTeamsDownloadCompletion:) 
                           withObject:reqContext waitUntilDone:YES];
}

-(void)handleTeamsDownloadCompletion: (RequestContext*) requestContext {
    [self stopBusyDialog];
    if ([requestContext hasError]) {
        if ([requestContext getErrorCode] == Unauthorized) {
            __weak CloudViewController* slf = self;
            signonCompletion = ^{[slf startTeamsDownload];};
            [self goSignonView];
        } else if ([requestContext getErrorCode] == UnacceptableAppVersion) {
            [self showCompleteAlert:NSLocalizedString(@"Download FAILED",nil) message: requestContext.errorExplanation];               
        } else {
            [self showCompleteAlert:NSLocalizedString(@"Download FAILED",nil) message: NSLocalizedString([requestContext getErrorCode] == NotConnectedToInternet ? kNoInternetMessage : @"We were unable to download your team list from the cloud.  Try again later.", nil)];            
        }
    } else {
        NSArray* teams = (NSArray*)requestContext.responseData;
        [self goTeamPickerView: teams];
    } 
}

#pragma mark - Download Games info (for picking one to download)

-(void)startGamesDownload {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(downloadGamesFromServer) withObject:nil];
}

-(void)downloadGamesFromServer {
    NSError* requestError = nil;
    NSString* cloudId = [Team getCurrentTeam].cloudId;
    NSArray* games = [CloudClient getGameDescriptions:cloudId error:&requestError];
    RequestContext* reqContext = requestError ? 
    [[RequestContext alloc] initWithReqData:nil responseData:nil error: requestError] :
    [[RequestContext alloc] initWithReqData:nil responseData:games];
    [self performSelectorOnMainThread:@selector(handleGamesDownloadCompletion:) 
                           withObject:reqContext waitUntilDone:YES];
}

-(void)handleGamesDownloadCompletion: (RequestContext*) requestContext {
    [self stopBusyDialog];
    if ([requestContext hasError]) {
        if ([requestContext getErrorCode] == Unauthorized) {
            __weak CloudViewController* slf = self;          
            signonCompletion = ^{[slf startGamesDownload];};
            [self goSignonView];
        } else if ([requestContext getErrorCode] == UnacceptableAppVersion) {
            [self showCompleteAlert:NSLocalizedString(@"Download FAILED",nil) message: requestContext.errorExplanation];               
        } else {
            [self showCompleteAlert:NSLocalizedString(@"Download FAILED",nil) message: NSLocalizedString([requestContext getErrorCode] == NotConnectedToInternet ? kNoInternetMessage : @"We were unable to download your games list from the cloud.  Try again later.", nil)];                
        }
    } else {
        NSArray* games = (NSArray*)requestContext.responseData;
        [self goGamePickerView: games];
    } 
}

#pragma mark - Download Game

-(void)startGameDownload:(NSString*) gameId {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(downloadGameFromServer:) withObject:gameId];
}

-(void)downloadGameFromServer: (NSString*) gameId {
    NSError* requestError = nil;
    [CloudClient downloadGame:gameId forTeam: [Team getCurrentTeam].cloudId error:&requestError];
    RequestContext* reqContext = requestError ? 
    [[RequestContext alloc] initWithReqData:gameId responseData:nil error: requestError] :
    [[RequestContext alloc] initWithReqData:gameId responseData:nil];
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
        } else if ([requestContext getErrorCode] == UnacceptableAppVersion) {
            [self showCompleteAlert:NSLocalizedString(@"Download FAILED",nil) message: requestContext.errorExplanation];               
        } else {
            [self showCompleteAlert:NSLocalizedString(@"Download FAILED",nil) message: NSLocalizedString([requestContext getErrorCode] == NotConnectedToInternet ? kNoInternetMessage : @"We were unable to download your game from the cloud.  Try again later.", nil)];               
        }
    } else {
        NSString* gameId = (NSString*)requestContext.requestData;
        if ([Game isCurrentGame:gameId]) {
            [Game setCurrentGame:gameId];
        }
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
        [self showCompleteAlert:NSLocalizedString(@"Download Complete",nil) message: NSLocalizedString(@"The game was successfully downloaded to your iPhone.",nil)];         
    }
}

#pragma mark - Download Team

-(void)startTeamDownload: (NSString*) cloudId {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(downloadTeamFromServer:) withObject:cloudId];
}

-(void)downloadTeamFromServer: (NSString*) cloudId {
    NSError* requestError = nil;
    NSString* teamId = [CloudClient downloadTeam: cloudId error:&requestError];
    RequestContext* reqContext = requestError ? 
                   [[RequestContext alloc] initWithReqData:cloudId responseData:nil error: requestError] :
                   [[RequestContext alloc] initWithReqData:cloudId responseData:teamId];
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
        } else if ([requestContext getErrorCode] == UnacceptableAppVersion) {
            [self showCompleteAlert:NSLocalizedString(@"Download FAILED",nil) message: requestContext.errorExplanation];               
        } else {
            [self showCompleteAlert:NSLocalizedString(@"Download FAILED",nil) message: NSLocalizedString([requestContext getErrorCode] == NotConnectedToInternet ? kNoInternetMessage : @"We were unable to download your team from the cloud.  Try again later.", nil)];                   
        }
    } else {
        NSString* teamId = (NSString*)requestContext.responseData;
        if (![Team isCurrentTeam:teamId]) {
            [Team setCurrentTeam:teamId];
            [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
        }
        [self populateViewFromModel];
        [self showCompleteAlert:NSLocalizedString(@"Download Complete",nil) message: NSLocalizedString(@"The team was successfully downloaded to your iPhone.",nil)];            
    }
}

#pragma mark - Busy Dialog

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

#pragma mark - Miscellaneous

-(void)dismissSignonController:(BOOL) isSignedOn email: (NSString*) userEmail {
    [Preferences getCurrentPreferences].userid = userEmail;
    [[Preferences getCurrentPreferences] save];
    void (^completionBlock)() = isSignedOn ? signonCompletion : nil;
    [self.presentedViewController dismissViewControllerAnimated:NO completion:completionBlock];
}

-(IBAction)signoffButtonClicked: (id) sender {
    [CloudClient signOff];
    [self populateViewFromModel];
}

-(void)showCompleteAlert: (NSString*) title message: (NSString*) message {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: title
                          message: message
                          delegate: nil
                          cancelButtonTitle: NSLocalizedString(@"OK",nil)
                          otherButtonTitles: nil];
    [alert show];
}

-(void)styleButtons {
    self.uploadButton.titleLabel.font = kButtonFont;  
    self.downloadGameButton.titleLabel.font = kButtonFont;    
    self.downloadTeamButton.titleLabel.font = kButtonFont;    
    self.signoffButton.titleLabel.font = kButtonFont;    
}

-(void)populateViewFromModel {
    NSString* websiteURL = [CloudClient getWebsiteURL: [Team getCurrentTeam]];
    self.websiteLabel.text = websiteURL == nil ?  @"Unknown...do upload" : websiteURL;
    self.websiteCell.accessoryType = websiteURL == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    self.websiteCell.selectionStyle = websiteURL == nil ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleNone;
    NSString* userid = [Preferences getCurrentPreferences].userid;
    self.userUnknownLabel.hidden = userid != nil;
    self.userLabel.hidden = userid == nil;
    self.userLabel.text = userid;
    [self.uploadButton setTitle:[NSString stringWithFormat:@" Upload %@ Games ",[Team getCurrentTeam].name] forState:UIControlStateNormal];
    [self.downloadGameButton setTitle:[NSString stringWithFormat:@" Download a %@ Game ",[Team getCurrentTeam].name] forState:UIControlStateNormal];    
    self.signoffButton.hidden = userid == nil;
    [self.cloudTableView reloadData];
}

#pragma mark - Table handling

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

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleButtons];
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(populateViewFromModel)
                                                 name: @"UIApplicationWillEnterForegroundNotification"
                                               object: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"Cloud", @"Cloud");
    [self populateViewFromModel];
    if  (teamDownloadController && teamDownloadController.selectedTeam) {
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
    [self setUserUnknownLabel:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
