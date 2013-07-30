//
//  ActionDetailsViewController.m
//  UltimateIPhone
//
//  Created by james on 3/3/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "ActionDetailsViewController.h"
#import "EventSelectTableViewCell.h"
#import "Event.h"
#import "ColorMaster.h"

@interface ActionDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *choicesView;
@property (strong, nonatomic) IBOutlet UITableView *choicesTable;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) NSArray *candidateEvents;
@property (strong, nonatomic) Event *chosenEvent;

@end

@implementation ActionDetailsViewController
@dynamic description;

#pragma mark Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _candidateEvents = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    [self stylize];
    [self refresh];
}

- (void)viewDidUnload {
    [self setDescriptionLabel:nil];
    [self setChoicesTable:nil];
    [self setSaveButton:nil];
    [self setCancelButton:nil];
    [self setChoicesView:nil];
    [super viewDidUnload];
}

-(void)stylize {
    [ColorMaster styleAsWhiteLabel:self.descriptionLabel size:18];
    self.choicesTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.candidateEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event* event = [self.candidateEvents objectAtIndex:indexPath.row];
    
    EventSelectTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [self createCell];
    }
    
    cell.event = event;
    cell.chosen = self.chosenEvent == event;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Event* event = [self.candidateEvents objectAtIndex:indexPath.row];
    
    self.chosenEvent = event;
    
    [self refresh];

}

-(EventSelectTableViewCell*)createCell {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([EventSelectTableViewCell class]) owner:nil options:nil];
    EventSelectTableViewCell*  cell = (EventSelectTableViewCell *)[nib objectAtIndex:0];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)refresh {
    [self.choicesTable reloadData];
    [self sizeTable];
}

-(void)sizeTable {
    CGFloat heightNeededToViewAllChoices = [self.candidateEvents count] * self.choicesTable.rowHeight;
    if (heightNeededToViewAllChoices > self.choicesView.bounds.size.height) {
        self.choicesTable.frame = self.choicesView.bounds;
        self.choicesTable.scrollEnabled = YES;
    } else {
        CGRect f = self.choicesView.bounds;
        f.size.height = self.choicesTable.rowHeight * [self.candidateEvents count];
        self.choicesTable.frame = f;
        self.choicesTable.scrollEnabled = NO;
    }
    self.choicesTable.separatorStyle = [self.candidateEvents count] > 1 ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
}
    
#pragma mark Event handlers 
    
- (IBAction)savePressed:(id)sender {
    if (self.saveBlock) {
        self.saveBlock(self.chosenEvent);
    }
}
    
- (IBAction)cancelPressed:(id)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
}

#pragma mark Custom accessors

-(void)setCandidateEvents:(NSArray *)candidateEvents initialChosen: (Event*) initialEvent {
    self.candidateEvents = candidateEvents;
    self.chosenEvent = initialEvent;
    [self refresh];
}

-(void)setDescription:(NSString *)description {
    self.descriptionLabel.text = description;
}


@end
