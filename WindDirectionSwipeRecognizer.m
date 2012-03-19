//
//  WindDirectionSwipeRecognizer.m
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WindDirectionSwipeRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation WindDirectionSwipeRecognizer 
@synthesize touch;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touch = [touches anyObject];
    [super touchesBegan:touches withEvent:event];
}


-(int)getDegrees {
    CGPoint point0 = [self.touch previousLocationInView:[self view]];
    CGPoint point1 = [self.touch locationInView:[self view]];
    
    //NSLog(@"Swipe - start location: %f,%f and end location:  %f,%f ", point0.x, point0.y, point1.x, point1.y);
    
    // radius: calculate distance between 2 points (http://www.teacherschoice.com.au/maths_library/analytical%20geometry/alg_15.htm)
    float radius = sqrt(pow((point0.x - point1.x), 2) + pow((point0.y - point1.y), 2));
    // calulate the angle (http://beradrian.wordpress.com/2009/03/23/calculating-the-angle-between-two-points-on-a-circle/)
    CGPoint pointTemp = CGPointMake(point0.x, point0.y - radius);
    float radians = 2 * atan2(point1.y - pointTemp.y, point1.x - pointTemp.x);
    // convert to degrees
    return radians * (180 / M_PI);
}

@end
