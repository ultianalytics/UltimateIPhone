//
//  CloudViewController.m
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//
#import "CloudViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Preferences.h"
#import "ColorMaster.h"
#import "TeamDownloadPickerViewController.h"
#import "GameDownloadPickerViewController.h"
#import "GameUploadPickerViewController.h"
#import "Team.h"
#import "Game.h"
#import "GameDescription.h"
#import "Scrubber.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "AppDelegate.h"
#import "RequestContext.h"
#import "UIView+Toast.h"
#import "UIScrollView+Utilities.h"
#import "UIView+Convenience.h"
#import "CloudClient2.h"
#import "GoogleOAuth2Authenticator.h"


#define kNoInternetMessage @"We were unable to access the internet."
#define kDefaultInvalidAppVersionMessage @"Sorry...a more current version of this app is required in order to talk to the server.\n\nPlease download the latest version."
#define kButtonFont [UIFont boldSystemFontOfSize: 15]

#define kIsNotFirstCloudViewUsage @"IsNotFirstCloudViewUsage"

@interface CloudViewController() 

@property (nonatomic, strong) CalloutsContainerView *usageCallouts;
@property (nonatomic, strong) NSArray *gameIdsToUpload;

@end

@implementation CloudViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - Event handling

-(IBAction)downloadTeamButtonClicked: (id) sender {
    [self downloadTeamDescriptions];
}

-(IBAction)downloadGameButtonClicked: (id) sender {
    [self downloadGameDescriptions];
}

- (IBAction)scrubSwitchChanged:(id)sender {
    [Scrubber currentScrubber].isOn = self.scrubberSwitch.isOn;
}

-(IBAction)uploadButtonClicked: (id) sender {
    if ([[Team getCurrentTeam] isAnonymous]) {
        [self showSetNameFirstUploadAlert];
    } else {
        if ([[Team getCurrentTeam] hasGames]) {
            [self goGameUploadPickerView];
        } else {
            [self showNoGamesToUploadAlert];
        }
    }
}

- (IBAction)autoUploadChanged:(id)sender {
    BOOL shouldAutoUpdate = self.autoUploadSegmentedControl.selectedSegmentIndex == 1;
    if (shouldAutoUpdate) {
        [self verfifySignedOnForAutoUploading];
    } else {
        [Team getCurrentTeam].isAutoUploading = NO;
        [[Team getCurrentTeam] save];
        [self populateViewFromModel];
    }
}

-(IBAction)signoffButtonClicked: (id) sender {
    [CloudClient2 signOff];
    [Team getCurrentTeam].isAutoUploading = NO;
    [[Team getCurrentTeam] save];
    [self populateViewFromModel];
}

#pragma mark - Navigation

-(void)goTeamPickerView: (NSArray*) teams {
    teamDownloadController = [[TeamDownloadPickerViewController alloc] init];
    teamDownloadController.teams = teams;
    [self.navigationController pushViewController:teamDownloadController animated: YES];
}

-(void)goGameDownloadPickerView: (NSArray*) games {
    gameDownloadController = [[GameDownloadPickerViewController alloc] init];
    gameDownloadController.games = games;
    [self.navigationController pushViewController:gameDownloadController animated: YES];
}

-(void)goGameUploadPickerView {
    self.gameIdsToUpload = [NSArray array];
   
    UIStoryboard *gamesStoryboard = [UIStoryboard storyboardWithName:@"GameUploadPickerViewController" bundle:nil];
    GameUploadPickerViewController* gameUploadController  = [gamesStoryboard instantiateInitialViewController];
    gameUploadController.dismissBlock = ^(NSArray* selectedGameIds) {
        [self.navigationController popViewControllerAnimated:YES];
        self.gameIdsToUpload = selectedGameIds;
        [self uploadTeamWithSelectedGames];
    };
    
    [self.navigationController pushViewController:gameUploadController animated: YES];
}

-(void)goGameAutoUploadConfirmed {
    [Team getCurrentTeam].isAutoUploading = YES;
    [[Team getCurrentTeam] save];
    [self populateViewFromModel];
    [self.view makeToast:@"Game data for this team\nwill now be periodically\nuploaded to the website\n as you record actions."
                    duration:5.0
                    position:@"center"
                    title:@"Auto Uploading Started"
                    image:[UIImage imageNamed:@"broadcasting"]];
}

#pragma mark - Upload Team/Games

-(void)uploadTeamWithSelectedGames {
    [self startBusyDialog];
    [CloudClient2 uploadTeam:[Team getCurrentTeam] withGames:self.gameIdsToUpload completion:^(CloudRequestStatus *status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopBusyDialog];
            switch (status.code) {
                case CloudRequestStatusCodeOk: {
                    [self populateViewFromModel];
                    [self showCompleteAlert:NSLocalizedString(@"Upload Complete",nil) message: NSLocalizedString(@"Your data was successfully uploaded to the cloud",nil)];
                    break;
                }
                case CloudRequestStatusCodeUnauthorized: {
                    [[GoogleOAuth2Authenticator sharedAuthenticator] signInUsingNavigationController:self.navigationController completion:^(SignonStatus signonStatus) {
                        switch (signonStatus) {
                            case SignonStatusOk:
                                [self uploadTeamWithSelectedGames];
                                break;
                            case SignonStatusError:
                                [self showCompleteAlert:@"Signon FAILED" message: @"We were unable to signon to Google.  Try again later."];
                                break;
                            default: // cancel
                                break;
                        }
                    }];
                    break;
                }
                default: {
                    [self showErrorAlertForStatus: status isDownload: NO];
                    break;
                }
            }
        });
    }];
}

-(void)showNoGamesToUploadAlert {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"No Games for Team"
                          message: [NSString stringWithFormat: @"The %@ team has zero games.  You must first add a game before uploading", [Team getCurrentTeam].name]
                          delegate: nil
                          cancelButtonTitle: NSLocalizedString(@"OK",nil)
                          otherButtonTitles: nil];
    [alert show];
}

-(void)showSetNameFirstUploadAlert {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"No Team Name"
                          message: @"Please give your team a name before uploading."
                          delegate: nil
                          cancelButtonTitle: NSLocalizedString(@"OK",nil)
                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Download Team descriptions (for picking one to download)

-(void)downloadTeamDescriptions {
    [self startBusyDialog];
    [CloudClient2 downloadTeamsAtCompletion:^(CloudRequestStatus *status, NSArray *teams) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopBusyDialog];
            switch (status.code) {
                case CloudRequestStatusCodeOk: {
                    [self goTeamPickerView: teams];
                    break;
                }
                case CloudRequestStatusCodeUnauthorized: {
                    [[GoogleOAuth2Authenticator sharedAuthenticator] signInUsingNavigationController:self.navigationController completion:^(SignonStatus signonStatus) {
                        switch (signonStatus) {
                            case SignonStatusOk:
                                [self downloadTeamDescriptions];
                                break;
                            case SignonStatusError:
                                [self showCompleteAlert:@"Signon FAILED" message: @"We were unable to signon to Google.  Try again later."];
                                break;
                            default: // cancel
                                break;
                        }
                    }];
                    break;
                }
                default: {
                    [self showErrorAlertForStatus: status isDownload: YES];
                    break;
                }
            }
        });
    }];
}

#pragma mark - Download Games info (for picking one to download)

-(void)downloadGameDescriptions {
    [self startBusyDialog];
    NSString* cloudId = [Team getCurrentTeam].cloudId;
    [CloudClient2 downloadGameDescriptionsForTeam:cloudId atCompletion:^(CloudRequestStatus *status, NSArray *gameDescriptions) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopBusyDialog];
            switch (status.code) {
                case CloudRequestStatusCodeOk: {
                    [self goGameDownloadPickerView: gameDescriptions];
                    break;
                }
                case CloudRequestStatusCodeUnauthorized: {
                    [[GoogleOAuth2Authenticator sharedAuthenticator] signInUsingNavigationController:self.navigationController completion:^(SignonStatus signonStatus) {
                        switch (signonStatus) {
                            case SignonStatusOk:
                                [self downloadGameDescriptions];
                                break;
                            case SignonStatusError:
                                [self showCompleteAlert:@"Signon FAILED" message: @"We were unable to signon to Google.  Try again later."];
                                break;
                            default: // cancel
                                break;
                        }
                    }];
                    break;
                }
                default: {
                    [self showErrorAlertForStatus: status isDownload: YES];
                    break;
                }
            }
        });
    }];
}

#pragma mark - Download Game

-(void)downloadGame: (NSString*) gameId {
    [self startBusyDialog];
    [CloudClient2 downloadGame:gameId forTeam:[Team getCurrentTeam].cloudId atCompletion:^(CloudRequestStatus *status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopBusyDialog];
            switch (status.code) {
                case CloudRequestStatusCodeOk: {
                    if ([Game isCurrentGame:gameId]) {
                        [Game setCurrentGame:gameId];
                    }
                    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
                    [self showCompleteAlert:NSLocalizedString(@"Download Complete",nil) message: [NSString stringWithFormat:@"The game was successfully downloaded to your %@.", IS_IPAD ? @"iPad" : @"iPhone"]];
                    break;
                }
                case CloudRequestStatusCodeUnauthorized: {
                    [[GoogleOAuth2Authenticator sharedAuthenticator] signInUsingNavigationController:self.navigationController completion:^(SignonStatus signonStatus) {
                        switch (signonStatus) {
                            case SignonStatusOk:
                                [self downloadGame:gameId];
                                break;
                            case SignonStatusError:
                                [self showCompleteAlert:@"Signon FAILED" message: @"We were unable to signon to Google.  Try again later."];
                                break;
                            default: // cancel
                                break;
                        }
                    }];
                    break;
                }
                default: {
                    [self showErrorAlertForStatus: status isDownload: YES];
                    break;
                }
            }
        });
    }];
}

#pragma mark - Download Team

-(void)downloadTeam: (NSString*) cloudId {
    [self startBusyDialog];
    [CloudClient2 downloadTeam:cloudId atCompletion:^(CloudRequestStatus *status, NSString *teamId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopBusyDialog];
            switch (status.code) {
                case CloudRequestStatusCodeOk: {
                    [Team setCurrentTeam:nil];
                    [Team setCurrentTeam:teamId];
                    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetTeamTab];
                    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
                    [self populateViewFromModel];
                    [self showCompleteAlert:NSLocalizedString(@"Download Complete",nil) message: [NSString stringWithFormat:@"The team was successfully downloaded to your %@.", IS_IPAD ? @"iPad" : @"iPhone"]];
                    break;
                }
                case CloudRequestStatusCodeUnauthorized: {
                    [[GoogleOAuth2Authenticator sharedAuthenticator] signInUsingNavigationController:self.navigationController completion:^(SignonStatus signonStatus) {
                        switch (signonStatus) {
                            case SignonStatusOk:
                                [self downloadTeam: cloudId];
                                break;
                            case SignonStatusError:
                                [self showCompleteAlert:@"Signon FAILED" message: @"We were unable to signon to Google.  Try again later."];
                                break;
                            default: // cancel
                                break;
                        }
                    }];
                    break;
                }
                default: {
                    [self showErrorAlertForStatus: status isDownload: YES];
                    break;
                }
            }
        });
    }];
}

#pragma mark - Auto Upload Signon Verification (ensure that we are signed on to Google)

-(void)verfifySignedOnForAutoUploading {
    [self startBusyDialog];
    // use the upload team endpoint to verify we have connectivity and signed on (and that the team has been uploaded at least once)
    [CloudClient2 uploadTeam:[Team getCurrentTeam] completion:^(CloudRequestStatus *status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopBusyDialog];
            switch (status.code) {
                case CloudRequestStatusCodeOk: {
                    [self goGameAutoUploadConfirmed];
                    break;
                }
                case CloudRequestStatusCodeUnauthorized: {
                    [[GoogleOAuth2Authenticator sharedAuthenticator] signInUsingNavigationController:self.navigationController completion:^(SignonStatus signonStatus) {
                        switch (signonStatus) {
                            case SignonStatusOk:
                                [self verfifySignedOnForAutoUploading];
                                break;
                            case SignonStatusError:
                                [self showCompleteAlert:@"Signon FAILED" message: @"We were unable to signon to Google.  Try again later."];
                                break;
                            default: // cancel
                                break;
                        }
                    }];
                    break;
                }
                case CloudRequestStatusCodeUnacceptableAppVersion: {
                    [self showCompleteAlert:@"Auto Game Uploading Setup FAILED" message: status.explanation ? status.explanation :kDefaultInvalidAppVersionMessage];
                    break;
                }
                case CloudRequestStatusCodeNotConnectedToInternet: {
                    [self showCompleteAlert:@"Auto Game Uploading Setup FAILED" message: kNoInternetMessage];
                    break;
                }
                default: {
                    NSString* message = @"We were unable to connect to the UltiAnalytics server to setup game auto-uploading.  Try again later.";
                    [self showCompleteAlert:@"Auto Game Uploading Setup FAILED" message: message];
                    break;
                }
            }
        });
    }];
}

#pragma mark - Busy Dialog

-(void)startBusyDialog {
    self.busyView.hidden = NO;
}

-(void)stopBusyDialog {
    self.busyView.hidden = YES;
}

#pragma mark - Miscellaneous

-(void)showErrorAlertForStatus: (CloudRequestStatus*) status isDownload: (BOOL)download {
    NSString* title = download ? @"Download FAILED" : @"Upload FAILED";
    switch (status.code) {
        case CloudRequestStatusCodeUnacceptableAppVersion: {
            [self showCompleteAlert:title message: status.explanation ? status.explanation :kDefaultInvalidAppVersionMessage];
            break;
        }
        case CloudRequestStatusCodeNotConnectedToInternet: {
            [self showCompleteAlert:title message: kNoInternetMessage];
            break;
        }
        default: {
            NSString* message = download ?  @"We were unable to download your data from the server.  Try again later." :  @"We were unable to upload your data to the server.  Try again later.";
            [self showCompleteAlert:title message: message];
            break;
        }
    }
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

-(void)styleView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.cloudTableView adjustInsetForTabBar];
    self.busyDisplay.layer.cornerRadius = 8.0;
}

-(void)populateViewFromModel {
    NSString* websiteURL = [CloudClient2 getWebsiteURL: [Team getCurrentTeam]];
    self.websiteLabel.text = websiteURL == nil ?  @"Unknown...do upload" : websiteURL;
    self.websiteCell.accessoryType = websiteURL == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    self.websiteCell.selectionStyle = websiteURL == nil ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleNone;
    NSString* userid = [Preferences getCurrentPreferences].userid;
    NSString* adminURL = [NSString stringWithFormat:@"%@/team/admin", [CloudClient2 getBaseWebUrl]];
    self.adminSiteLabel.text = adminURL;
    self.userUnknownLabel.hidden = userid != nil;
    self.userLabel.hidden = userid == nil;
    self.userLabel.text = userid;
    [self.uploadButton setTitle:[NSString stringWithFormat:@" Upload %@ Games ",[Team getCurrentTeam].name] forState:UIControlStateNormal];
    [self.downloadGameButton setTitle:[NSString stringWithFormat:@" Download a %@ Game ",[Team getCurrentTeam].name] forState:UIControlStateNormal];    
    self.signoffButton.hidden = userid == nil;
    [self.cloudTableView reloadData];
    [self.scrubberSwitch setOn:[Scrubber currentScrubber].isOn];
    self.autoUploadSegmentedControl.selectedSegmentIndex = [Team getCurrentTeam].isAutoUploading ? 1 : 0;
#ifdef DEBUG
    self.scrubberView.hidden = NO;
#endif
    
}

#pragma mark - Table handling

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    cloudCells = @[self.userCell, self.autoUploadCell, self.websiteCell, self.adminSiteCell, self.privacyPolicyCell];
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
        if (cell == self.websiteCell) {
            NSString* websiteURL = [CloudClient2 getWebsiteURL: [Team getCurrentTeam]];
            if (websiteURL != nil) {
                NSURL *url = [NSURL URLWithString:websiteURL];
                [[UIApplication sharedApplication] openURL:url];
            }
        } else if (cell == self.adminSiteCell) {
            NSString* adminUrl = self.adminSiteLabel.text;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adminUrl]];
        } else if (cell == self.privacyPolicyCell) {
            NSString* privacyPolicyUrl = [NSString stringWithFormat: @"%@/privacy.html", [CloudClient2 getBaseWebUrl]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:privacyPolicyUrl]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSingleSectionGroupedTableSectionHeaderHeight;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cloudTableView.tableHeaderView = self.headerView;
    [self styleView];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(populateViewFromModel)
                                                 name: @"UIApplicationWillEnterForegroundNotification"
                                               object: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"Website", @"Website");
    [self populateViewFromModel];
    if  (teamDownloadController && teamDownloadController.selectedTeam) {
        if (teamDownloadController.selectedTeam) {
            [self downloadTeam: teamDownloadController.selectedTeam.cloudId];
        }
        teamDownloadController = nil;
    } else if  (gameDownloadController && gameDownloadController.selectedGame) {
        if (gameDownloadController.selectedGame) {
            [self downloadGame: gameDownloadController.selectedGame.gameId];
        }
        gameDownloadController = nil;
    } 
}

-(void)viewDidAppear:(BOOL)animated {
    [self showNewLogonUsageCallouts];
}

- (void)viewDidUnload
{
    [self setUserUnknownLabel:nil];
    [self setScrubberView:nil];
    [self setScrubberSwitch:nil];
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

#pragma mark - Help Callouts


-(BOOL)showNewLogonUsageCallouts {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsNotFirstCloudViewUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsNotFirstCloudViewUsage];
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        [calloutsView addCallout:@"If you would like to keep your team statistics private, you can set a password on your team website and only share it with your teammates.\n\nTo set the password, go to Admin website after you upload your team for the first time." anchor: CGPointTop(self.view.bounds) width: 250 degrees: 180 connectorLength: 110 font:[UIFont systemFontOfSize:14]];
        
        self.usageCallouts = calloutsView;
        [self.view addSubview:calloutsView];
        return YES;
    } else {
        return NO;
    }
}

@end
