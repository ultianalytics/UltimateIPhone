//
//  WindViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@class Game;
@class ArrowView;

@interface WindViewController : UltimateViewController
@property (nonatomic, strong) Game* game;

@property (nonatomic, strong) IBOutlet UISegmentedControl* playStartSideSegmentedControl;
@property (nonatomic, strong) IBOutlet UIView* directionView;
@property (nonatomic, strong) IBOutlet UIView* directionSwipeView;  // transparent view on top of other view to enlarge swipe zone
@property (nonatomic, strong) IBOutlet ArrowView* directionArrowView;
@property (nonatomic, strong) IBOutlet UIButton* askWeatherServiceButton;
@property (nonatomic, retain) IBOutlet UISlider* speedSlider;
@property (nonatomic, retain) IBOutlet UILabel* speedLabel;

-(void)populateViewFromModel;
-(IBAction)startDirectionChanged:(id)sender;
-(IBAction)askWeatherStationClicked:(id)sender;
-(void)saveChanges;
-(void)populateSpeedLabel;
-(IBAction)speedSliderChanged: (id)sender;
-(IBAction)speedSliderChangeEnded: (id)sender;

@end
