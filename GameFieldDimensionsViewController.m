//
//  GameFieldDimensionsViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/14/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldDimensionsViewController.h"
#import "FieldDimensionsView.h"
#import "FieldDimensions.h"
#import "GameFieldDimensionViewController.h"

@interface GameFieldDimensionsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *fieldTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet FieldDimensionsView *fieldDimensionsView;

@property (strong, nonatomic) FieldDimensions* fieldDimensions;
@property (strong, nonatomic) UIPopoverController* popover;

@end

@implementation GameFieldDimensionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fieldDimensions = self.game.fieldDimensions;
    [self populateView];
}

-(void)populateView {
    int typeIndex;
    switch (self.fieldDimensions.type) {
        case FieldDimensionTypeUPA:
            typeIndex = 0;
            break;
        case FieldDimensionTypeWFDF:
            typeIndex = 1;
            break;
        case FieldDimensionTypeAUDL:
            typeIndex = 2;
            break;
        case FieldDimensionTypeMLU:
            typeIndex = 3;
            break;
        case FieldDimensionTypeOther:
            typeIndex = 4;
            break;
        default:
            break;
    }
    self.fieldTypeSegmentedControl.selectedSegmentIndex = typeIndex;
    self.fieldDimensionsView.fieldDimensions = self.fieldDimensions;
}

- (IBAction)fieldTypeChanged:(id)sender {
    FieldDimensionType fdType;
    switch (self.fieldTypeSegmentedControl.selectedSegmentIndex) {
        case 0:
            fdType = FieldDimensionTypeUPA;
            break;
        case 1:
            fdType = FieldDimensionTypeWFDF;
            break;
        case 2:
            fdType = FieldDimensionTypeAUDL;
            break;
        case 3:
            fdType = FieldDimensionTypeMLU;
            break;
        case 4:
            fdType = FieldDimensionTypeOther;
            break;
        default:
            fdType = FieldDimensionTypeUPA;
            break;
    }
    if (self.fieldDimensions.type != fdType) {
        self.fieldDimensions = [FieldDimensions fieldWithType:fdType];
        [self populateView];
        [self saveChanges];
    }
}

-(void)saveChanges {
    self.game.fieldDimensions = self.fieldDimensions;
    
}

-(void)showDimensionChangePopover: (UIView*) anchorView {
    GameFieldDimensionViewController *changeVC = [[GameFieldDimensionViewController alloc] init];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:changeVC];
    
//    CGRect anchorViewRect = [self.view convertRect:anchorView.frame fromView:anchorView];
    [self.popover presentPopoverFromRect:anchorView.frame inView:anchorView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

@end
