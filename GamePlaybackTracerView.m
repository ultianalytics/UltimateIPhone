//
//  GamePlaybackTracerView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/13/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GamePlaybackTracerView.h"
#import "UIView+Convenience.h"
#import "ColorMaster.h"

#define kArrowHeadWidth  12
#define kArrowHeadLength 16

@interface GamePlaybackTracerView ()

@property (nonatomic) CGPoint arrowCenter;
@property (nonatomic) CGFloat arrowLength;
@property (nonatomic) float radians;
@property (nonatomic, strong) UIColor* arrowColor;

@end

@implementation GamePlaybackTracerView

-(void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.endInset = 46.0f;
    self.arrowColor = [UIColor whiteColor];
    self.isOurEvent = NO;
}


#pragma mark - UIView overrides

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib {
    [self commonInit];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self calculateArrowCoordinates];
    [self.layer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    [super drawLayer:layer inContext:context];
    CGContextSaveGState(context);
    
    // transform center of drawing to middle of line
    CGContextTranslateCTM(context, self.arrowCenter.x,self.arrowCenter.y) ;
    // rotate the drawing so it will point from source to destination.
    CGContextRotateCTM(context, self.radians) ;
    
    // line properties
    CGContextSetStrokeColorWithColor(context, self.arrowColor.CGColor);
    CGContextSetFillColorWithColor(context, self.arrowColor.CGColor);
    CGContextSetLineWidth(context, 1);
    
    // find line begin/end (always drawing it at 90 degrees since transform will rotate it)
    CGPoint lineBeginPoint = CGPointMake(-self.arrowLength/2, 0);
    CGPoint lineEndPoint = CGPointMake(self.arrowLength/2, 0);
    
    // draw the line
    float dashAndSpaceLengths[] = {5,5};
    CGContextSetLineDash(context, 0, dashAndSpaceLengths, 2);
    CGContextMoveToPoint(context, lineBeginPoint.x, lineBeginPoint.y);
    CGContextAddLineToPoint(context, lineEndPoint.x, lineEndPoint.y);
    CGContextStrokePath(context);
    
    // draw the arrow head
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextMoveToPoint(context, lineEndPoint.x - kArrowHeadLength, lineEndPoint.y - (kArrowHeadWidth / 2));
    CGContextAddLineToPoint(context, lineEndPoint.x, lineEndPoint.y);
    CGContextAddLineToPoint(context, lineEndPoint.x - kArrowHeadLength, lineEndPoint.y + (kArrowHeadWidth / 2));
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
}

-(void)calculateArrowCoordinates {
    CGPoint rectTopLeft = CGPointMake(MIN(self.sourcePoint.x, self.destinationPoint.x), MIN(self.sourcePoint.y, self.destinationPoint.y));
    CGPoint rectBottomRight = CGPointMake(MAX(self.sourcePoint.x, self.destinationPoint.x), MAX(self.sourcePoint.y, self.destinationPoint.y));
    CGRect rectBetweenPoints = CGRectMake(rectTopLeft.x, rectTopLeft.y, rectBottomRight.x - rectTopLeft.x, rectBottomRight.y - rectTopLeft.y);
    self.arrowCenter = CGPointMake(CGRectGetMidX(rectBetweenPoints), CGRectGetMidY(rectBetweenPoints));
    
    CGFloat halfArrowDistance =  sqrtf(powf(self.arrowCenter.x - rectTopLeft.x, 2) + powf(self.arrowCenter.y - rectTopLeft.y, 2));
    self.arrowLength = (halfArrowDistance - self.endInset) * 2;
    
    self.radians = atan2f( self.destinationPoint.y - self.arrowCenter.y , self.destinationPoint.x - self.arrowCenter.x);
//    NSLog(@"arrow coordinates: center=%f,%f length=%f radians=%f", self.arrowCenter.x, self.arrowCenter.y, self.arrowLength, self.radians);
}


-(void)setSourcePoint:(CGPoint)sourcePoint {
    _sourcePoint = sourcePoint;
    [self setNeedsLayout];
}

-(void)setDestinationPoint:(CGPoint)destinationPoint {
    _destinationPoint = destinationPoint;
    [self setNeedsLayout];
}

-(void)setIsOurEvent:(BOOL)isOurEvent {
    _isOurEvent = isOurEvent;
    self.arrowColor = isOurEvent ? [ColorMaster applicationTintColor] : [UIColor redColor];
    [self setNeedsDisplay];
}

@end
