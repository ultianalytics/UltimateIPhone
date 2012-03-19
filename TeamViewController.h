//
//  FirstViewController.h
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView* playersTableView;
@property (nonatomic, strong) IBOutlet UITextField* teamNameField;
@property (nonatomic, strong) IBOutlet UISegmentedControl* teamTypeSegmentedControl;

-(void)goToAddItem;
-(IBAction)nameChanged: (id) sender;
-(IBAction)teamTypeChanged: (id) sender;

@end
