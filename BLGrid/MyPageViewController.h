//
//  MyPageViewController.h
//  MultiViewControllerTest
//
//  Created by Jim Geppert on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPageViewController : UIViewController

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *doitButton;
@property (strong, nonatomic) UIPopoverController *popover;
- (IBAction)popupPressed:(id)sender;

@end
