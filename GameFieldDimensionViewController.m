//
//  GameFieldDimensionViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/19/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldDimensionViewController.h"

@interface GameFieldDimensionViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic) int firstDimension;
@property (nonatomic) int lastDimension;
@property (nonatomic) int initialDimension;

@end

@implementation GameFieldDimensionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeFirstAndLast];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pickerView selectRow:self.initialDimension - self.firstDimension inComponent:0 animated:NO];
}

-(CGSize)preferredContentSize {
    return self.view.frame.size;
}

-(void) initializeFirstAndLast {
    switch (self.dimensionType) {
        case DimensionTypeEndZone:
            self.firstDimension = 5;
            self.lastDimension = 30;
            self.initialDimension = MAX(self.fieldDimensions.endZoneLength, self.firstDimension);
            break;
        case DimensionTypeCentralZone:
            self.firstDimension = 20;
            self.lastDimension = 100;
            self.initialDimension = MAX(self.fieldDimensions.centralZoneLength, self.firstDimension);
            break;
        case DimensionTypeWidth:
            self.firstDimension = 20;
            self.lastDimension = 60;
            self.initialDimension = MAX(self.fieldDimensions.width, self.firstDimension);
            break;
        case DimensionTypeBrickMarkDistance:
            self.firstDimension = 5;
            self.lastDimension = 30;
            self.initialDimension = MAX(self.fieldDimensions.brickMarkDistance, self.firstDimension);
            break;
        default:
            break;
    }
    
}

- (IBAction)doneTapped:(id)sender {
    if (self.delegate) {
        [self.delegate fieldDimensionControllerRequestsClose];
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.lastDimension - self.firstDimension;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    int value = self.firstDimension + row;
    return [NSString stringWithFormat:@"%d", value];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    int selectedDimension = row + self.firstDimension;
    switch (self.dimensionType) {
        case DimensionTypeEndZone:
            self.fieldDimensions.endZoneLength = selectedDimension;
            break;
        case DimensionTypeCentralZone:
            self.fieldDimensions.centralZoneLength = selectedDimension;
            break;
        case DimensionTypeWidth:
            self.fieldDimensions.width = selectedDimension;
            break;
        case DimensionTypeBrickMarkDistance:
            self.fieldDimensions.brickMarkDistance = selectedDimension;
            break;
        default:
            break;
    }
}



@end
