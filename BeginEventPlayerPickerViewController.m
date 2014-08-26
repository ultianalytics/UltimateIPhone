//
//  BeginEventPlayerPickerViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/26/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "BeginEventPlayerPickerViewController.h"

@interface BeginEventPlayerPickerViewController ()

@property (nonatomic, weak) IBOutlet UIButton* player1Button;
@property (nonatomic, weak) IBOutlet UIButton* player2Button;
@property (nonatomic, weak) IBOutlet UIButton* player3Button;
@property (nonatomic, weak) IBOutlet UIButton* player4Button;
@property (nonatomic, weak) IBOutlet UIButton* player5Button;
@property (nonatomic, weak) IBOutlet UIButton* player6Button;
@property (nonatomic, weak) IBOutlet UIButton* player7Button;
@property (nonatomic, weak) IBOutlet UIButton* playerUnknownButton;

@property (weak, nonatomic) IBOutlet UILabel* instructionsLabel;

@end

@implementation BeginEventPlayerPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.line = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refresh];
}

-(void)refresh {
    [self populateView];
}

- (IBAction)playerButtonTapped:(id)sender {
    int playerButtonNumber = ((UIButton*)sender).tag;
    if (self.doneRequestedBlock) {
        Player* player = playerButtonNumber == 8 ? [Player getAnonymous] : self.line[playerButtonNumber - 1];
        self.doneRequestedBlock(player);
    }
}

- (IBAction)cancelButtonTapped:(id)sender {
    if (self.doneRequestedBlock) {
        self.doneRequestedBlock(nil);
    }
}

-(void)populateView {
    self.instructionsLabel.text = self.instructions;
    for (int i = 0; i < 7; i++) {
        UIButton* playerButton = (UIButton*)[self.view viewWithTag:i + 1];
        if ([self.line count] > i) {
            Player* player = self.line[i];
            [playerButton setTitle:player.name forState:UIControlStateNormal];
            playerButton.hidden = NO;
        } else {
            playerButton.hidden = YES;
        }
    }
}

@end
