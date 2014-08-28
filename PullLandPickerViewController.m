//
//  PullLandPickerViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/28/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "PullLandPickerViewController.h"

@interface PullLandPickerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@end

@implementation PullLandPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)inBoundsButtonTapped:(id)sender {
    [self notifyListener:Pull];
}

- (IBAction)outOfBoundsButtonTapped:(id)sender {
    [self notifyListener:PullOb];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self notifyListener:None];
}

-(void)notifyListener: (Action)action {
    if (self.doneRequestedBlock) {
        self.doneRequestedBlock(action);
    }
}


@end
