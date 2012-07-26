//
//  MyTabWithButtonsViewController.h
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyTabButtonsDelegate <NSObject>

-(void)previousButtonSelected;
-(void)nextButtonSelected;

@end

@interface MyTabWithButtonsViewController : UIViewController

@property (nonatomic, weak) id<MyTabButtonsDelegate> delegate;
@property (nonatomic, retain) UIButton *previousButton;
@property (nonatomic, retain) UIButton *nextButton;

-(IBAction)previousButtonSelected:(id)sender;
-(IBAction)nextButtonSelected:(id)sender;

@end
