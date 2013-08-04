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

-(void)layoutSubviews {
    [super layoutSubviews];
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
}

-(NSString*)getSelection {
    return [self titleForSegmentAtIndex:self.selectedSegmentIndex];
}

-(void)setSelectedSegmentIndex: (NSInteger) selectedSegmentIndex {
    super.selectedSegmentIndex = selectedSegmentIndex;
}

// private methods

-(void)setup {
    self.tintColor = [ColorMaster getSegmentControlLightTintColor];
    [self addTarget:self action:@selector(updateView) forControlEvents:UIControlEventValueChanged];
}


@end
