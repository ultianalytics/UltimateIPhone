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

@property (strong, nonatomic) FieldDimensions* fieldDimensions;

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
        [self saveChanges];
    }
}

-(void)saveChanges {
    self.game.fieldDimensions = self.fieldDimensions;
    
}

@end
