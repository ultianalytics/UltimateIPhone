//
//  ColorButton.m
//  Numbers
//
//  Created by james on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorButton.h"
#import "ColorMaster.h"

@interface ColorButton()

@property (nonatomic, strong) CAGradientLayer* gradientLayer;

@end

@implementation ColorButton

@synthesize highColor, highDisabledColor, lowColor, lowDisabledColor, gradientLayer, borderColor, borderDisabledColor, isLabelStyle, buttonStyleNormalTextColor,buttonStyleHighlightTextColor,labelStyleNormalTextColor,labelStyleDisabledTextColor; 

- (void)awakeFromNib {
    [self initializeGradient];
    [self setIsLabelStyle: self.isLabelStyle];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeGradient];
        [self setIsLabelStyle: self.isLabelStyle];
    }
    return self;
}

- (void)initializeGradient {
    [self initCharacteristics];
    
    // Initialize the gradient layer
    gradientLayer = [[CAGradientLayer alloc] init];
    // Set its bounds to be the same of its parent
    [gradientLayer setBounds:[self bounds]];
    // Center the layer inside the parent layer
    [gradientLayer setPosition: CGPointMake([self bounds].size.width/2, [self bounds].size.height/2)];
    
}

- (void)initCharacteristics {
    self.isLabelStyle = NO;
    self.highColor = [ColorMaster getNormalButtonHighColor];  
    self.lowColor = [ColorMaster getNormalButtonLowColor];  
    self.highDisabledColor = [ColorMaster getNormalButtonSelectedHighColor];
    self.lowDisabledColor = [ColorMaster getNormalButtonSelectedLowColor]; 
    self.borderColor = self.highColor;
    self.borderDisabledColor = self.lowDisabledColor;
    self.buttonStyleNormalTextColor = [UIColor whiteColor];
    self.buttonStyleHighlightTextColor = [UIColor blackColor];
    self.labelStyleNormalTextColor = [UIColor blackColor];
    self.labelStyleDisabledTextColor = [UIColor grayColor];  

}

-(void)setIsLabelStyle:(BOOL)shouldBeLabelStyle {
    isLabelStyle = shouldBeLabelStyle;
    if (shouldBeLabelStyle) {
        [self setTitleColor:self.labelStyleNormalTextColor forState:UIControlStateNormal];
        [self setTitleColor:self.labelStyleDisabledTextColor forState:UIControlStateHighlighted];
        [self setTitleColor:self.labelStyleDisabledTextColor forState:UIControlStateSelected];
        [[self layer] setBorderWidth:0.0f];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.gradientLayer removeFromSuperlayer];
    } else {
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self setTitleColor:self.buttonStyleNormalTextColor forState:UIControlStateNormal];
        [self setTitleColor:self.buttonStyleHighlightTextColor forState:UIControlStateHighlighted];
        [self setTitleColor:self.buttonStyleNormalTextColor forState:UIControlStateSelected];
        // Insert the layer at position zero to make sure the 
        // text of the button is not obscured
        [[self layer] insertSublayer:gradientLayer atIndex:0];
        // Set the layer's corner radius
        [[self layer] setCornerRadius:8.0f];
        // Turn on masking
        [[self layer] setMasksToBounds:YES];
        // Display a border around the button 
        // with a 1.0 pixel width
        [[self layer] setBorderWidth:1.0f];
    }
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
