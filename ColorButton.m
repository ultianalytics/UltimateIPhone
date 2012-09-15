//
//  ColorButton.m
//  Numbers
//
//  Created by james on 8/22/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "ColorButton.h"
#import "ColorMaster.h"

@interface ColorButton()

@property (nonatomic, strong) CAGradientLayer* gradientLayer;

@end

@implementation ColorButton

@synthesize highColor, highDisabledColor, lowColor, lowDisabledColor, gradientLayer, borderColor, borderDisabledColor, isLabelStyle, buttonStyleNormalTextColor,buttonStyleHighlightTextColor,labelStyleNormalTextColor,labelStyleDisabledTextColor;

- (void)awakeFromNib {
    [self initCharacteristics];
    [self initStyle];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initCharacteristics];
        [self initStyle];
    }
    return self;
}

- (void)initCharacteristics {
    self.isLabelStyle = NO;
    self.highColor = [ColorMaster getNormalButtonHighColor];
    self.lowColor = [ColorMaster getNormalButtonLowColor];
    self.highDisabledColor = [ColorMaster getNormalButtonSelectedHighColor];
    self.lowDisabledColor = [ColorMaster getNormalButtonSelectedLowColor];
    self.buttonStyleNormalTextColor = [UIColor whiteColor];
    self.buttonStyleHighlightTextColor = [UIColor blackColor];
    self.labelStyleNormalTextColor = [UIColor blackColor];
    self.labelStyleDisabledTextColor = [UIColor grayColor];
    
}

-(void)initializeLayerForButtonStyle {
    [self.gradientLayer removeFromSuperlayer];
    [self initializeGradient];
    [[self layer] insertSublayer:gradientLayer atIndex:0];
    
    // Adjust the primary layer
    // Set the layer's corner radius
    [[self layer] setCornerRadius:8.0f];
    // Turn on masking
    [[self layer] setMasksToBounds:YES];
    // Display a border around the button
    // with a 1.0 pixel width
    [[self layer] setBorderWidth:1.0f];
    [self setNeedsDisplay];
}

- (void)initializeGradient {
    // Initialize the gradient layer
    self.gradientLayer = [[CAGradientLayer alloc] init];
    // Set its bounds to be the same of its parent
    [self.gradientLayer setBounds:[self bounds]];
    // Center the layer inside the parent layer
    [self.gradientLayer setPosition: CGPointMake([self bounds].size.width/2, [self bounds].size.height/2)];
    
}

-(void)setIsLabelStyle:(BOOL)shouldBeLabelStyle {
    isLabelStyle = shouldBeLabelStyle;
    [self initStyle];
}

-(void)initStyle {
    if (isLabelStyle) {
        [self setTitleColor:self.labelStyleNormalTextColor forState:UIControlStateNormal];
        [self setTitleColor:self.labelStyleDisabledTextColor forState:UIControlStateHighlighted];
        [self setTitleColor:self.labelStyleDisabledTextColor forState:UIControlStateSelected];
        [[self layer] setBorderWidth:0.0f];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.gradientLayer removeFromSuperlayer];
    } else {
        self.borderColor = self.highColor;
        self.borderDisabledColor = self.lowDisabledColor;
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self setTitleColor:self.buttonStyleNormalTextColor forState:UIControlStateNormal];
        [self setTitleColor:self.buttonStyleHighlightTextColor forState:UIControlStateHighlighted];
        [self setTitleColor:self.buttonStyleNormalTextColor forState:UIControlStateSelected];
        [self initializeLayerForButtonStyle];
    }
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect;
{
    if (self.isLabelStyle) {
        [super drawRect:rect];
    } else {
        // set the gradient colors according to state: normal vs. pressed
        NSArray* gradientColors;
        if (self.enabled) {
            gradientColors = [NSArray arrayWithObjects: (id)[highColor CGColor], (id)[lowColor CGColor], nil];
            [[self layer] setBorderColor: [self.borderColor CGColor]];
        } else {
            gradientColors = [NSArray arrayWithObjects: (id)[lowDisabledColor CGColor], (id)[highDisabledColor CGColor], nil];
            [[self layer] setBorderColor: [self.borderDisabledColor CGColor]];
        }
        [gradientLayer setColors: gradientColors];
        
        // set locations of gradient changes
        gradientLayer.locations = [NSArray arrayWithObjects: [NSNumber numberWithFloat: .4], [NSNumber numberWithFloat: 1], nil];
        
        // draw
        [super drawRect:rect];
    }
}

-(void)layoutSubviews {
    if (!isLabelStyle) {
        [self initializeLayerForButtonStyle];
    }
    [super layoutSubviews];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
}


@end
