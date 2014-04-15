//
//  TweetViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/28/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "TweetViewController.h"
#import "ColorMaster.h"
#import "SoundPlayer.h"
#import "Tweeter.h"
#import "TweetQueue.h"
#import "TwitterAccountPickViewController.h"
#import "TwitterController.h"
#import "Reachability.h"
#import "Tweet.h"

@interface TweetViewController()

-(void)checkAccountAvailable;
-(void)cancelSend;
-(void)sendTweet;
-(void)populateViewFromModel;
-(void)updateCharCount: (int) count;

@end

@implementation TweetViewController
@synthesize tableView,tweetTextCell,tweetAccountCell,accountNameLabel,tweetTextView,charCountLabel,initialText;

-(void)populateViewFromModel {
    NSString* currentAccount = [[Tweeter getCurrent] getTwitterAccountName];
    self.accountNameLabel.text = currentAccount == nil ? kNoAccountText : currentAccount;
}

+(void)alertNoAccount: (id<UIAlertViewDelegate>) delegate {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: NSLocalizedString(@"No Twitter Accounts",nil)
                          message: NSLocalizedString(@"You have not created any Twitter account yet in your iPhone settings (or you are not granting access to this app).   Go to iPhone settings.",nil)
                          delegate: delegate
                          cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
                          otherButtonTitles: nil];
    [alert show];
}

-(void)checkAccountAvailable {
    if ([self.accountNameLabel.text isEqualToString: kNoAccountText]) {
        [TweetViewController alertNoAccount: self];
    } 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell =  [indexPath section] == 0 ? tweetTextCell : tweetAccountCell;
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [indexPath section] == 0 ? 140 : 38;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath { 
    if ([indexPath section] == 1) {
        TwitterAccountPickViewController* pickController = [[TwitterAccountPickViewController alloc] init];
        [self.navigationController pushViewController:pickController animated: YES];
    }
} 

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [tweetTextView.text length] + [text length] - range.length;
    BOOL isTooLong = (newLength > 140);
    if (isTooLong) {
        [SoundPlayer playKeyIgnored];
    } else {
        [self updateCharCount: (int)newLength];
    }
    return !isTooLong;
}

- (void)updateCharCount: (int) count {
    charCountLabel.text = [NSString stringWithFormat:@"%d", 140 - count];
}

-(void)cancelSend {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendTweet {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [TwitterController showNoConnectivityAlert];
    } else {
        [[Tweeter getCurrent] tweet:[[Tweet alloc] initMessage: tweetTextView.text type: kAdHocType]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Tweet", @"Tweet");
        self.tweetTextView.text = @"";
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
    tableView.sectionHeaderHeight = 3.0;
    tableView.sectionFooterHeight = 1.0;
    
    UIBarButtonItem *playersNavBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelSend)];
    self.navigationItem.leftBarButtonItem = playersNavBarItem;
    
    UIBarButtonItem *historyNavBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Send" style: UIBarButtonItemStyleBordered target:self action:@selector(sendTweet)];
    self.navigationItem.rightBarButtonItem = historyNavBarItem;  
    self.navigationItem.rightBarButtonItem.tag = 44;
    historyNavBarItem.tag = 55;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tweetTextView.text = initialText ? initialText : @"";
    [self updateCharCount: (int)[self.tweetTextView.text length]];
    [self populateViewFromModel];
    [self.tweetTextView becomeFirstResponder]; // makes the text view "in focus" and shows the keyboard
}

- (void)viewDidAppear:(BOOL)animated
{
    [self checkAccountAvailable];
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
