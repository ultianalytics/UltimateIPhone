//
//  PlayerDetailsViewController.m
//  Ultimate
//
//  Created by james on 1/21/12.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "PlayerDetailsViewController.h"
#import "Team.h"
#import "SoundPlayer.h"
#import "ColorMaster.h"
#import "Player.h"
#import "UltimateSegmentedControl.h"
#import "AppDelegate.h"
#import "UIViewController+Additions.h"

@interface PlayerDetailsViewController ()

@property (nonatomic, strong) IBOutlet UITextField* nickNameField;
@property (nonatomic, strong) IBOutlet UITextField* numberField;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* positionControl;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* sexControl;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* statusControl;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *buttonsView;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
@property (nonatomic, strong) IBOutlet UILabel* savedMessageLabel;

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell* nameTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* numberTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* positionTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* genderTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* absentTableCell;

@end

@implementation PlayerDetailsViewController
@synthesize nickNameField,numberField,positionControl,sexControl,deleteButton,tableView,nameTableCell,numberTableCell,positionTableCell,genderTableCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(void)populateViewFromModel {
    if (self.player) {
        self.nickNameField.text = self.player.name;
        self.numberField.text = self.player.number;
        [self.positionControl setSelection: self.player.position == Any ? @"Any" : self.player.position == Handler ? @"Handler" : @"Cutter" ];
        [self.sexControl setSelection: self.player.isMale ? @"Male" : @"Female"];
        [self.statusControl setSelection: self.player.isAbsent ? @"Absent" : @"Playing"];
    } else {
        self.nickNameField.text = nil;
        self.numberField.text = nil;
        [self.positionControl setSelection: @"Cutter"];
        [self.sexControl setSelection: @"Male"];
        [self.statusControl setSelection: @"Playing"];
    }
    self.buttonsView.hidden = self.player == nil;
}

-(void)populateModelFromView {
    self.player.name = [self getNickNameViewText];
    self.player.number = [self getNumberViewText];
    NSString* selectedPosition = [self.positionControl getSelection];
    self.player.position = [selectedPosition isEqualToString:@"Any"] ? Any : [selectedPosition isEqualToString:@"Handler"] ? Handler : Cutter;
    self.player.isMale = [[self.sexControl getSelection] isEqualToString:@"Male"] ? YES : NO;
    self.player.isAbsent = [[self.statusControl getSelection] isEqualToString:@"Absent"] ? YES : NO;
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
    _player = [[Player alloc] init];
    [self populateModelFromView];
    [[Team getCurrentTeam] addPlayer:self.player];
    [self saveTeam];
}

-(void)updatePlayer {
    [self populateModelFromView];
    [self saveTeam];
}

-(void)deletePlayer {
    [[Team getCurrentTeam] removePlayer:self.player];
    [self saveTeam];
}

-(void)saveTeam {
    [[Team getCurrentTeam] save];
    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
}

-(void)setPlayer:(Player *)player {
    _player = player;
    [self populateViewFromModel];
}

#pragma mark - Event Handlers

-(IBAction)deleteClicked: (id) sender {
    [self deletePlayer];
    if (IS_IPAD) {
        [self notifyChangeListener];
    } else {
        [self returnToTeamView];
    }
}

-(void)okClicked {
    if ([self verifyPlayer]) {
        if (self.player) {
            [self updatePlayer];
            if (IS_IPAD) {
                // "flash" the view so that the user can see something happened
                [UIView transitionWithView:self.view duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
                    self.view.alpha = 0;
                } completion:^(BOOL finished) {
                    self.view.alpha = 1;
                }];
                [self notifyChangeListener];
            } else {
                [self returnToTeamView];
            }
        } else {
            [self addPlayer];
            [self.view endEditing:YES];
            self.player = nil;
            [self flashAddAnotherMessage];
            if (IS_IPAD) {
                [self notifyChangeListener];
            }
        }
        
    }
}


-(void)cancelClicked {
    if (IS_IPAD) {
        [self cancelModalDialog];
    } else {
        [self returnToTeamView];
    }
}

#pragma mark - Add Another Message

- (void)flashAddAnotherMessage {
    [self showSavedAddAnotherMessage];
}

- (void)showSavedAddAnotherMessage {
    self.savedMessageLabel.alpha = 0;
    self.savedMessageLabel.hidden = NO;
    [UIView animateWithDuration:.5 animations:^{
        self.savedMessageLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(animateHideSavedMessageLabel) withObject:self afterDelay:2];
    }];
}

- (void)animateHideSavedMessageLabel {
    [UIView animateWithDuration:.5 animations:^{
        self.savedMessageLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.savedMessageLabel.hidden = YES;
        self.savedMessageLabel.alpha = 1;
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = self.footerView;
    
    self.nickNameField.delegate = self;
    self.numberField.delegate = self;
    
    if (IS_IPHONE || self.isModalAddMode) {
        UIBarButtonItem *cancelNavBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStylePlain target:self action:@selector(cancelClicked)];
        self.navigationItem.leftBarButtonItem = cancelNavBarItem;
    }
    
    UIBarButtonItem *saveNavBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStylePlain target:self action:@selector(okClicked)];
    self.navigationItem.rightBarButtonItem = saveNavBarItem;    
    
    self.title = self.isModalAddMode ? @"New Player" : @"Player";

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populateViewFromModel];
    [self registerForKeyboardNotifications];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Keyboard Up/Down Handling

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    // make the view port smaller so the user can scroll up to see all of the view
    CGFloat keyboardY = [self calcKeyboardOrigin:aNotification];
    CGFloat tableBottom = CGRectGetMaxY(self.tableView.frame);
    CGFloat newBottomInset = MAX(tableBottom - keyboardY, 0);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, newBottomInset, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    // undo the view port
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Table Source/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    cells = [NSArray arrayWithObjects:self.nameTableCell, self.numberTableCell, self.positionTableCell, self.genderTableCell, self.absentTableCell, nil];
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

#pragma mark - Text Delegate

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


#pragma mark - iPad only (Master/Detail UX)

-(void)notifyChangeListener {
    if (self.playerChangedBlock) {
        self.playerChangedBlock(self.player);
    }
}

-(void)cancelModalDialog {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
