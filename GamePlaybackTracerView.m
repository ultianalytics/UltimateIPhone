//
//  GamePlaybackTracerView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/13/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GamePlaybackTracerView.h"
#import "UIView+Convenience.h"


@interface GamePlaybackTracerView ()

@property (nonatomic) CGPoint arrowCenter;
@property (nonatomic) CGFloat arrowLength;
@property (nonatomic) float radians;

@end

@implementation GamePlaybackTracerView

-(void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.endInset = 20.0f;
    self.arrowColor = [UIColor whiteColor];
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

    CGContextSetStrokeColorWithColor(context, self.arrowColor.CGColor);
    
    // transform center of drawing to middle of line
    CGContextTranslateCTM(context, self.arrowCenter.x,self.arrowCenter.y) ;
    // will always draw the line 90 degrees.  the rotation transform will angle it correctly
    CGContextRotateCTM(context, self.radians) ;
    
    CGFloat lineWidth = 2;
    
    CGContextSetStrokeColorWithColor(context, self.arrowColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    
    CGPoint point1 = CGPointMake(-self.arrowLength/2, 0);
    CGPoint point2 = CGPointMake(self.arrowLength/2, 0);

    
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
}

-(void)calculateArrowCoordinates {
    CGPoint rectTopLeft = CGPointMake(MIN(self.sourcePoint.x, self.destinationPoint.x), MIN(self.sourcePoint.y, self.destinationPoint.y));
    CGPoint rectBottomRight = CGPointMake(MAX(self.sourcePoint.x, self.destinationPoint.x), MIN(self.sourcePoint.y, self.destinationPoint.y));
    CGRect rectBetweenPoints = CGRectMake(rectTopLeft.x, rectTopLeft.y, rectBottomRight.x - rectTopLeft.x, rectBottomRight.y - rectTopLeft.y);
    self.arrowCenter = CGPointMake(CGRectGetMidX(rectBetweenPoints), CGRectGetMidY(rectBetweenPoints));
    
    CGFloat halfArrowDistance =  sqrtf(powf(self.arrowCenter.x - rectTopLeft.x, 2) + powf(self.arrowCenter.y - rectTopLeft.y, 2));
    self.arrowLength = (halfArrowDistance - self.endInset) * 2;
    
    self.radians = atan2f( self.destinationPoint.y - self.arrowCenter.y , self.destinationPoint.x - self.arrowCenter.x);
//    NSLog(@"arrow coordinates: center=%f,%f length=%f radians=%f", self.arrowCenter.x, self.arrowCenter.y, self.arrowLength, self.radians);
}

@end
