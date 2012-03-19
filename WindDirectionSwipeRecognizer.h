//
//  WindDirectionSwipeRecognizer.h
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WindDirectionSwipeRecognizer : UISwipeGestureRecognizer
@property (nonatomic, strong) UITouch* touch;

-(int)getDegrees;

@end
