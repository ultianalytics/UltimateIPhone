//
//  UltimateSegmentedControl.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/19/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "UltimateSegmentedControl.h"
#import "ColorMaster.h"

// private methods definitiosn (using class extenstions)
@interface UltimateSegmentedControl() 

-(void)setup;
-(void)updateView;
-(void)updateViewWithSelection: (NSString*) title;
    
@end



@implementation UltimateSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self setup];
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
    [self updateViewWithSelection:selectionTitle];
}

-(NSString*)getSelection {
    return [self titleForSegmentAtIndex:self.selectedSegmentIndex];
}

-(void)setSelectedSegmentIndex: (NSInteger) selectedSegmentIndex {
    super.selectedSegmentIndex = selectedSegmentIndex;
    [self updateView];
}

// private methods

-(void)setup {
    self.tintColor = [ColorMaster getSegmentControlLightTintColor]; 
    [self addTarget:self action:@selector(updateView) forControlEvents:UIControlEventValueChanged];
    [self updateView];
}

-(void)updateView {
    NSString* selectionTitle = [self titleForSegmentAtIndex:self.selectedSegmentIndex];
    [self updateViewWithSelection:selectionTitle];
}

-(void)updateViewWithSelection: (NSString*) selectionTitle {
    // find the selected subview button (probably a UIBarButtonItem but we don't find to a particular class) and set it's color
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    for (UIView* segment in self.subviews ) {
        if ([segment respondsToSelector:@selector(setTintColor:)]) {
            for (UIView* labelSegment in segment.subviews) {
                if ([labelSegment respondsToSelector:@selector(text)]) {
                    NSString* title = [labelSegment performSelector:@selector(text)];
                    if ([title isEqualToString:selectionTitle]) {
                        [segment performSelector:@selector(setTintColor:) withObject:[ColorMaster getSegmentControlDarkTintColor]];
                    } else {
                        [segment performSelector:@selector(setTintColor:) withObject:[ColorMaster getSegmentControlLightTintColor]];
                    }
                }
            }
        }
    }
}

@end
