//
//  PickPlayerForEventViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/28/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "PickPlayerForEventViewController.h"
#import "Player.h"

@interface PickPlayerForEventViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel* instructionsLabel;
@property (weak, nonatomic) IBOutlet UITableView* playersTableView;
@property (weak, nonatomic) IBOutlet UIButton* cancelButton;

@end

@implementation PickPlayerForEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.line = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.instructionsLabel.text = self.instructions;
}

- (IBAction)cancelButtonTapped:(id)sender {
    if (self.doneRequestedBlock) {
        self.doneRequestedBlock(nil);
    }
}

-(void)refresh {
    self.instructionsLabel.text = self.instructions;
    [self.playersTableView reloadData];
}

#pragma mark - Table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.line count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCell"];
    
    NSString* playerName;
    if (row < [self.line count]) {
        playerName = ((Player*)self.line[row]).name;
    } else {
        playerName = @"UNKNOWN";
    }
    
    cell.textLabel.text = playerName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    Player* player;
    if (row < [self.line count]) {
        player = self.line[row];
    } else {
        player = [Player getAnonymous];
    }
    
    if (self.doneRequestedBlock) {
        self.doneRequestedBlock(player);
    }

}



@end
