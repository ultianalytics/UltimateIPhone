//
//  ColorButton.h
//  Numbers
//
//  Created by james on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ColorButton : UIButton {
    CAGradientLayer* gradientLayer;
    UIColor* highColor;
    UIColor* lowColor;
    UIColor* highDisabledColor;
    UIColor* lowDisabledColor;
    UIColor* borderColor;
    UIColor* borderDisabledColor;
}
@property (nonatomic, retain) CAGradientLayer* gradientLayer;
@property (nonatomic, retain) UIColor* highColor;
@property (nonatomic, retain) UIColor* lowColor;
@property (nonatomic, retain) UIColor* highDisabledColor;
@property (nonatomic, retain) UIColor* lowDisabledColor; 
@property (nonatomic, retain) UIColor* borderColor;
@property (nonatomic, retain) UIColor* borderDisabledColor; 

- (void)initCharacteristics;
- (void)initializeGradient;

@end
