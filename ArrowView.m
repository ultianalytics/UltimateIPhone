//
//  ArrowView.m
//  Ultimate
//
//  Created by Jim Geppert on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArrowView.h"
#define kArrowHalfLength 50

@implementation ArrowView
@synthesize degrees;

-(CGPoint) getPointAt: (int) pointDegrees onCircleCenter: (CGPoint) centerPoint withRadius: (int) radius {
    // 0 is normally 3 o'clock so adjust it to 12 o'clock
    int radianDegrees = pointDegrees < 90 ? pointDegrees + 270 : pointDegrees - 90;
    float radians = (float)(radianDegrees) * M_PI / (float)180;
    return CGPointMake(centerPoint.x + round(radius * cos(radians)),centerPoint.y + round(radius * sin(radians)));
}


- (void)drawRect:(CGRect)rect { 
   if (self.degrees >= 0 ) {
        CGContextRef context = UIGraphicsGetCurrentContext(); 
        CGPoint centerPoint = CGPointMake(round(self.frame.size.width / 2), round(self.frame.size.height / 2));
        int endPointDegrees = self.degrees;
        CGPoint endPoint = [self getPointAt:endPointDegrees onCircleCenter:centerPoint withRadius:kArrowHalfLength];
        int startPointDegrees = self.degrees >= 180 ? degrees - 180 : degrees + 180;
        CGPoint startPoint = [self getPointAt:startPointDegrees onCircleCenter:centerPoint withRadius:kArrowHalfLength];
        //[self drawSimpleLine:context from:startPoint to:endPoint];
        [self drawArrow:context from:startPoint to:endPoint];
        [self setNeedsDisplay];
    }
}

- (void) drawSimpleLine: (CGContextRef) context from: (CGPoint) from to: (CGPoint) to {
    CGContextSetLineWidth(context, 2.0); 
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor); 
    CGContextMoveToPoint(context, from.x, from.y); 
    CGContextAddLineToPoint(context, to.x, to.y); 
    CGContextStrokePath(context); 
}

- (void) drawArrow: (CGContextRef) context from: (CGPoint) from to: (CGPoint) to {
    double slopy, cosy, siny;
    // Arrow size
    double length = 20.0;  
    double width = 40.0;
    
    slopy = atan2((from.y - to.y), (from.x - to.x));
    cosy = cos(slopy);
    siny = sin(slopy);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    
    //draw a line between the 2 endpoint
    CGContextMoveToPoint(context, from.x - length * cosy, from.y - length * siny );
    CGContextAddLineToPoint(context, to.x + length * cosy, to.y + length * siny);
    //paints a line along the current path
    CGContextSetLineWidth(context, 20.0); 
    CGContextStrokePath(context);
    
    // draw the arrowhead
    CGContextSetLineWidth(context, 1.0); 
    CGContextMoveToPoint(context, to.x, to.y);
    CGContextAddLineToPoint(context,
                            to.x +  (length * cosy - ( width / 2.0 * siny )),
                            to.y +  (length * siny + ( width / 2.0 * cosy )) );
    CGContextAddLineToPoint(context,
                            to.x +  (length * cosy + width / 2.0 * siny),
                            to.y -  (width / 2.0 * cosy - length * siny) );
    CGContextClosePath(context);
    CGContextFillPath(context);
    CGContextStrokePath(context);
}


@end
