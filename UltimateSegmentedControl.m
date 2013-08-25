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

+ (void)initialize {
    if (self == [UltimateSegmentedControl class]) {
        UltimateSegmentedControl *appearance = [self appearance];
        [appearance setCornerRadius:5.0f];
        [appearance setSelectedColor:[UIColor blackColor]];
        [appearance setDeselectedColor:[UIColor lightGrayColor]];
        [appearance setDividerColor:[UIColor whiteColor]];
        [appearance setSelectedFont:[UIFont boldSystemFontOfSize:15.0]];
        [appearance setDeselectedFont:[UIFont systemFontOfSize:15.0]];
        [appearance setSelectedFontColor:[UIColor whiteColor]];
        [appearance setDeselectedFontColor:[UIColor whiteColor]];
    }
}

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
    
}




@end
