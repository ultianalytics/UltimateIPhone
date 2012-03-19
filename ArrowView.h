//
//  ArrowView.h
//  Ultimate
//
//  Created by Jim Geppert on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrowView : UIView
@property (nonatomic) int degrees;

-(CGPoint) getPointAt: (int) degrees onCircleCenter: (CGPoint) centerPoint withRadius: (int) radius;
-(void) drawArrow: (CGContextRef) context from: (CGPoint) from to: (CGPoint) to;
-(void) drawSimpleLine: (CGContextRef) context from: (CGPoint) from to: (CGPoint) to; 

@end
