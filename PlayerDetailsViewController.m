//
//  PlayerDetailsViewController.m
//  Ultimate
//
//  Created by james on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerDetailsViewController.h"
#import "Team.h"
#import "SoundPlayer.h"
#import "ColorMaster.h"
#import "Player.h"
#import "UltimateSegmentedControl.h"
#import "AppDelegate.h"

@implementation PlayerDetailsViewController
@synthesize player,nickNameField,numberField,positionControl,sexControl,saveAndAddButton,deleteButton,tableView,nameTableCell,numberTableCell,positionTableCell,genderTableCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Player", @"Player");
    }
    return self;
}

-(void)populateViewFromModel {
    if (player) {
        self.nickNameField.text = self.player.name;
        self.numberField.text = self.player.number;
        [self.positionControl setSelection: self.player.position == Any ? @"Any" : self.player.position == Handler ? @"Handler" : @"Cutter" ];
        [self.sexControl setSelection: self.player.isMale ? @"Male" : @"Female"];        
    } else {
        self.nickNameField.text = nil;
        self.numberField.text = nil;
        [self.positionControl setSelection: @"Cutter"];
        [self.sexControl setSelection: @"Male"];
    }
}

-(void)populateModelFromView {
    self.player.name = [self getNickNameViewText];
    self.player.number = [self getNumberViewText];
    NSString* selectedPosition = [self.positionControl getSelection];
    self.player.position = [selectedPosition isEqualToString:@"Any"] ? Any : [selectedPosition isEqualToString:@"Handler"] ? Handler : Cutter;
    self.player.isMale = [[self.sexControl getSelection] isEqualToString:@"Male"] ? YES : NO;
}

-(IBAction)addAnotherClicked: (id) sender{
    if ([self verifyPlayer]) {
        [self addPlayer];
        self.player = nil;
        [self populateViewFromModel];
    }
}
-(IBAction)deleteClicked: (id) sender {
    [self deletePlayer];
    [self returnToTeamView];
}
-(void)okClicked {
    if ([self verifyPlayer]) {
        if (player) {
            [self updatePlayer];
        } else {
            [self addPlayer];
        }
        [self returnToTeamView];
    } 
}
-(void)cancelClicked {
    [self returnToTeamView];
}
-(void)returnToTeamView {
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)verifyPlayer {
    NSString* newPlayerName = [self getNickNameViewText];
    NSString* newPlayerNumber = [self getNumberViewText];
    if ([newPlayerName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Invalid Player Name" 
                              message:@"A name is required for each player"
                              delegate:self 
                              cancelButtonTitle:@"Try Again" 
                              otherButtonTitles:nil]; 
        [alert show];
        return NO;
    } else if ([self isDuplicatePlayerName:newPlayerName]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Duplicate Player Name" 
                              message:@"Each player must have a unique name"
                              delegate:self 
                              cancelButtonTitle:@"Try Again" 
                              otherButtonTitles:nil]; 
        [alert show];
        return NO;  
    } else if ([self isDuplicatePlayerNumber:newPlayerNumber]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Duplicate Player Number" 
                              message:@"Each player must have a unique number if assigned"
                              delegate:self 
                              cancelButtonTitle:@"Try Again" 
                              otherButtonTitles:nil]; 
        [alert show];
        return NO;        
    } else {
        return YES;
    } 
}

-(BOOL) isDuplicatePlayerName: (NSString*) newPlayerName {
    if (self.player && [self.player.name caseInsensitiveCompare:newPlayerName] == NSOrderedSame) {
        return NO;
    }
    return [[[Team getCurrentTeam] getAllPlayers] containsObject:[[Player alloc] initName:newPlayerName]];
}

-(BOOL) isDuplicatePlayerNumber: (NSString*) newPlayerNumber {
    if (newPlayerNumber == nil || [[newPlayerNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString: @""]) {
        return NO;
    }
    else if (self.player && [self.player.number caseInsensitiveCompare:newPlayerNumber] == NSOrderedSame) {
        return NO;
    } else {
        for (Player* otherPlayer in [[Team getCurrentTeam] getAllPlayers]) {
            if ([otherPlayer.number isEqualToString: newPlayerNumber]) {
                return YES;
            }
        }
        return NO;
    }
}

-(NSString*) getNickNameViewText {
     return self.nickNameField.text == nil ? @"" : [self.nickNameField.text trim];
}

-(NSString*) getNumberViewText {
    return self.numberField.text == nil ? @"" : [self.numberField.text trim];
}

-(void)addPlayer {
    self.player = [[Player alloc] init];
    [self populateModelFromView];
    [[Team getCurrentTeam] addPlayer:player];
    [self saveTeam];
}

-(void)updatePlayer {
    [self populateModelFromView];
    [self saveTeam];
}

-(void)deletePlayer {
    [[Team getCurrentTeam] removePlayer:player];
    [self saveTeam];
}

-(void)saveTeam {
    [[Team getCurrentTeam] save];
    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.separatorColor = [ColorMaster getTableListSeparatorColor];
    
    self.nickNameField.delegate = self;
    self.numberField.delegate = self;
    
    UIBarButtonItem *cancelNavBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelNavBarItem;
    
    UIBarButtonItem *saveNavBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStyleBordered target:self action:@selector(okClicked)];
    self.navigationItem.rightBarButtonItem = saveNavBarItem;    
    
    self.saveAndAddButton.hidden = player != nil;
    self.deleteButton.hidden = player == nil;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateViewFromModel];
}

- (void)viewDidUnload
{
    [self setFooterView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark = Table Source/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    cells = [NSArray arrayWithObjects:nameTableCell, numberTableCell, positionTableCell, genderTableCell, nil];
    return [cells count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [cells objectAtIndex:[indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kFormCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSingleSectionGroupedTableSectionHeaderHeight;
}

#pragma mark  Text Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == nickNameField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        BOOL isTooLong = (newLength > kMaxNicknameLength);
        if (isTooLong) {
            [SoundPlayer playKeyIgnored];
        }
        return !isTooLong;
    } else {
        return true;
    }
}

@end
