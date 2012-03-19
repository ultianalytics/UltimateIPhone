//
//  ColorButton.m
//  Numbers
//
//  Created by james on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorButton.h"
#import "ColorMaster.h"


@implementation ColorButton

@synthesize highColor, highDisabledColor, lowColor, lowDisabledColor, gradientLayer, borderColor, borderDisabledColor; 

- (void)awakeFromNib {
    [self initializeGradient];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeGradient];
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
    [gradientLayer setPosition:
     CGPointMake([self bounds].size.width/2,
                 [self bounds].size.height/2)];
    
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

- (void)initCharacteristics {
    self.highColor = [ColorMaster getNormalButtonHighColor];  
    self.lowColor = [ColorMaster getNormalButtonLowColor];  
    self.highDisabledColor = [ColorMaster getNormalButtonSelectedHighColor];
    self.lowDisabledColor = [ColorMaster getNormalButtonSelectedLowColor]; 
    self.borderColor = self.highColor;
    self.borderDisabledColor = self.lowDisabledColor;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
}

- (void)drawRect:(CGRect)rect;
{
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
    gradientLayer.locations =
    [NSArray arrayWithObjects: [NSNumber numberWithFloat: .4], [NSNumber numberWithFloat: 1], nil];
    
    // draw
    [super drawRect:rect];
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
