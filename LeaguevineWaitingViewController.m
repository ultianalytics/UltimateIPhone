//
//  LeaguevineWaitingViewController.m
//  UltimateIPhone
//
//  Created by james on 4/5/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevineWaitingViewController.h"

@interface LeaguevineWaitingViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation LeaguevineWaitingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Cancel";
}

- (void)viewDidUnload {
    [self setCancelButton:nil];
    [super viewDidUnload];
}

- (IBAction)cancelTapped:(id)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
}

@end
