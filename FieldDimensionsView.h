//
//  FieldDimensionsView.h
//  InstrumentsTest
//
//  Created by Jim Geppert on 10/17/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldDimensions.h"

@interface FieldDimensionsView : UIView

@property (nonatomic, strong) FieldDimensions* fieldDimensions;
@property (nonatomic, strong) UIColor* lineColor;

@end
