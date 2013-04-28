//
//  GameStartTimeViewController.m
//  UltimateIPhone
//
//  Created by james on 4/28/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "GameStartTimeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DarkButton.h"
#import "ColorMaster.h"

@interface GameStartTimeViewController()

@property (strong, nonatomic) IBOutlet UILabel *viewTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation GameStartTimeViewController

-(void)viewDidLoad {
    self.datePicker.date = self.date ? self.date : [NSDate date];
    [ColorMaster styleAsWhiteLabel:self.viewTitleLabel size:22];
}

- (IBAction)saveButtonTapped:(id)sender {
    if (self.completion) {
        self.completion(self);
    }
}

- (IBAction)cancelButtonTapped:(id)sender {
    if (self.completion) {
        self.date = nil;
        self.completion(self);
    }
}

- (IBAction)datePickerValueChanged:(id)sender {
    self.date = self.datePicker.date;
}



- (void)viewDidUnload {
    [self setViewTitleLabel:nil];
    [super viewDidUnload];
}
@end
