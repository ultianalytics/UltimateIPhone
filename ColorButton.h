//
//  ColorButton.h
//  Numbers
//
//  Created by james on 8/22/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ColorButton : UIButton {}

@property (nonatomic, strong) UIColor* highColor;
@property (nonatomic, strong) UIColor* lowColor;
@property (nonatomic, strong) UIColor* highDisabledColor;
@property (nonatomic, strong) UIColor* lowDisabledColor; 
@property (nonatomic, strong) UIColor* borderColor;
@property (nonatomic, strong) UIColor* borderDisabledColor; 
@property (nonatomic, strong) UIColor* buttonStyleNormalTextColor; 
@property (nonatomic, strong) UIColor* buttonStyleHighlightTextColor; 
@property (nonatomic, strong) UIColor* labelStyleNormalTextColor; 
@property (nonatomic, strong) UIColor* labelStyleDisabledTextColor; 
@property (nonatomic) BOOL isLabelStyle;

- (void)initCharacteristics;
- (void)initializeGradient;

@end
