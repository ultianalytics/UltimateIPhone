//
//  UltimateSegmentedControl.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/19/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UltimateSegmentedControl : UISegmentedControl

// public
-(void)setSelection: (NSString*) title;
-(NSString*)getSelection;

// private
-(void)setup;
-(void)updateViewWithSelection: (NSString*) title;


@end
