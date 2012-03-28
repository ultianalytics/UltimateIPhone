//
//  TweetViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TweetViewController.h"
#import "ColorMaster.h"
#import "SoundPlayer.h"
#import "Tweeter.h"

#define kNoAccountText @"NO TWITTER ACCOUNT DEFINED"

@implementation TweetViewController
@synthesize tableView,tweetTextCell,tweetAccountCell,accountNameLabel,tweetTextView,charCountLabel,initialText;

-(void)populateViewFromModel {
    NSString* currentAccount = [Tweeter getTwitterAccountName];
    if (currentAccount == nil) {
        self.accountNameLabel.text = kNoAccountText;
    } else {
        self.accountNameLabel.text = currentAccount;
    }
}

-(void)checkAccountAvailable {
    if (self.accountNameLabel.text == kNoAccountText) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: NSLocalizedString(@"No Twitter Accounts",nil)
                              message: NSLocalizedString(@"You have not created any Twitter account yet in your iPhone settings.",nil)
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
                              otherButtonTitles: NSLocalizedString(@"Open Settings",nil), nil];
        [alert show];
    } 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    return [indexPath section] == 0 ? 140 : 37;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath { 
    if ([indexPath section] == 1) {
        // open view to pick account
    }
} 

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [tweetTextView.text length] + [text length] - range.length;
    BOOL isTooLong = (newLength > 140);
    if (isTooLong) {
        [SoundPlayer playKeyIgnored];
    } else {
        charCountLabel.text = [NSString stringWithFormat:@"%d", newLength];
    }
    return !isTooLong;
}

-(void)cancelSend {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendTweet {
    [self.navigationController popViewControllerAnimated:YES];
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tweetTextView.text = initialText ? initialText : @"";
    self.charCountLabel.text = [NSString stringWithFormat:@"%d", [self.tweetTextView.text length]];
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
