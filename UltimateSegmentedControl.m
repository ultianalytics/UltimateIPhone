//
//  UltimateSegmentedControl.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/19/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "UltimateSegmentedControl.h"
#import "ColorMaster.h"

@implementation UltimateSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tintColor = [ColorMaster getSegmentControlLightTintColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.tintColor = [ColorMaster getSegmentControlLightTintColor];
    }
    return self; 
}

-(void)setSelection: (NSString*) selectionTitle {
    // find the segment with this title and set it as the selection
    for (int i = 0; i < self.numberOfSegments; i++) {
        NSString* segmentTitle =  [self titleForSegmentAtIndex:i];
        if ([segmentTitle isEqualToString:selectionTitle]) {
            self.selectedSegmentIndex = i;
            break;
        }
    }
    // find the selected subview button (expected to find a UIBarButtonItem) and set it's color
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    for (UIView* segment in self.subviews ) {
        if ([segment respondsToSelector:@selector(setTintColor:)]) {
            for (UIView* labelSegment in segment.subviews) {
                if ([labelSegment respondsToSelector:@selector(text)]) {
                    NSString* title = [labelSegment performSelector:@selector(text)];
                    if ([title isEqualToString:selectionTitle]) {
                        [segment performSelector:@selector(setTintColor:) withObject:[ColorMaster getSegmentControlDarkTintColor]];
                        if ([labelSegment respondsToSelector:@selector(textColor)]) {
                            [labelSegment performSelector:@selector(textColor) withObject:[UIColor whiteColor]];
                        }
                    } else {
                        [segment performSelector:@selector(setTintColor:) withObject:[ColorMaster getSegmentControlLightTintColor]];
                        if ([labelSegment respondsToSelector:@selector(textColor)]) {
                            [labelSegment performSelector:@selector(textColor) withObject:[UIColor blackColor]];
                        }                        
                    }
                }
            }
        }
    }
}

@end
