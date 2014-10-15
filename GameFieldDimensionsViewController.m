//
//  GameFieldDimensionsViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/14/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldDimensionsViewController.h"
#import "FieldDimensions.h"

@interface GameFieldDimensionsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *fieldTypeSegmentedControl;

@end

@implementation GameFieldDimensionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateView];
}

-(void)populateView {
    int typeIndex;
    switch (self.game.fieldDimensions.type) {
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
}

-(void)populateFieldDimensions {
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
            break;
    }
    self.game.fieldDimensions.type = fdType;
}

- (IBAction)fieldTypeChanged:(id)sender {
    [self populateFieldDimensions];
}

@end
