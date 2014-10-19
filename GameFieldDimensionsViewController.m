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
#import "UIView+Toast.h"

@interface GameFieldDimensionsViewController () <GameFieldDimensionViewControllerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fieldTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitOfMeasureSegmentedControl;
@property (weak, nonatomic) IBOutlet FieldDimensionsView *fieldDimensionsView;

@property (strong, nonatomic) FieldDimensions* fieldDimensions;
@property (strong, nonatomic) UIPopoverController* popover;

@end

@implementation GameFieldDimensionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.fieldDimensions = self.game.fieldDimensions;
    self.fieldDimensionsView.lineColor = [UIColor darkGrayColor];
    self.fieldDimensionsView.changeRequested = ^(DimensionType dimensionType, UIView* anchorView) {
        [self showDimensionChangePopover:anchorView forDimension:dimensionType];
    };
    [self populateViewAnimated: NO];
}

-(void)populateViewAnimated: (BOOL)animate {
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
    self.unitOfMeasureSegmentedControl.selectedSegmentIndex = self.fieldDimensions.unitOfMeasure == FieldUnitOfMeasureYards ? 0 : 1;
    self.unitOfMeasureSegmentedControl.hidden = self.fieldDimensions.type == FieldDimensionTypeOther ? NO : YES;
    if (animate) {
        [UIView transitionWithView:self.fieldDimensionsView duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.fieldDimensionsView.fieldDimensions = self.fieldDimensions;
        } completion:^(BOOL finished) {
            self.fieldDimensionsView.changedEnabled = self.fieldDimensions.type == FieldDimensionTypeOther;
        }];
    } else {
        self.fieldDimensionsView.fieldDimensions = self.fieldDimensions;
        self.fieldDimensionsView.changedEnabled = self.fieldDimensions.type == FieldDimensionTypeOther;
    }
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
            [self.containerView makeToast:@"Tap the numbers on\nthe field to change any\ndimension."
                        duration:3.0
                        position:@"center"
                           title:@"Custom Field Dimensions"];
            break;
        default:
            fdType = FieldDimensionTypeUPA;
            break;
    }
    if (self.fieldDimensions.type != fdType) {
        self.fieldDimensions = [FieldDimensions fieldWithType:fdType];
        [self populateViewAnimated: YES];
        [self saveChanges];
    }
}

- (IBAction)unitOfMeasureChanged:(id)sender {
    self.fieldDimensions.unitOfMeasure = self.unitOfMeasureSegmentedControl.selectedSegmentIndex == 0 ? FieldUnitOfMeasureYards : FieldUnitOfMeasureMeters;
    [self populateViewAnimated: YES];
    [self saveChanges];
}

-(void)saveChanges {
    self.game.fieldDimensions = self.fieldDimensions;
    
}

-(void)showDimensionChangePopover: (UIView*) anchorView forDimension: (DimensionType) dimensionType{
    GameFieldDimensionViewController *changeVC = [[GameFieldDimensionViewController alloc] init];
    changeVC.fieldDimensions = self.fieldDimensions;
    changeVC.delegate = self;
    changeVC.dimensionType = dimensionType;
    self.popover = [[UIPopoverController alloc] initWithContentViewController:changeVC];
    self.popover.delegate = self;
    
    CGRect anchorViewRect = [self.view convertRect:anchorView.frame fromView:self.fieldDimensionsView];
    [self.popover presentPopoverFromRect:anchorViewRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

#pragma mark - GameFieldDimensionViewControllerDelegate

-(void)fieldDimensionControllerRequestsClose {
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
    [self populateViewAnimated: YES];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
     self.popover = nil;
     [self populateViewAnimated: YES];
}

@end
